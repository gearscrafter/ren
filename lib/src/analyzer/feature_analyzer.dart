import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:ren/src/analyzer/leak_visitor.dart';
import 'package:ren/src/analyzer/rules/widget_rules.dart';
import 'package:ren/src/config/ren_config.dart';
import '../scanner/feature.dart';
import '../analyzer/ast_visitor.dart';
import '../analyzer/pattern.dart';

/// Result of analyzing a single [RenFeature].
class FeatureResult {
  final RenFeature feature;
  final List<RenPattern> patterns;
  final int gravityScore; // 0–100

  const FeatureResult({
    required this.feature,
    required this.patterns,
    required this.gravityScore,
  });

  GravityLevel get level => switch (gravityScore) {
        <= 20 => GravityLevel.low,
        <= 45 => GravityLevel.medium,
        <= 70 => GravityLevel.high,
        _ => GravityLevel.critical,
      };
}

enum GravityLevel { low, medium, high, critical }

/// Analyzes one [RenFeature] and returns a [FeatureResult] with patterns
/// and a gravity score.
class FeatureAnalyzer {
  final RenConfig config;

  FeatureAnalyzer({this.config = RenConfig.empty});
  Future<FeatureResult> analyze(RenFeature feature) async {
    final rules = effectiveRules(config);
    final allPatterns = <RenPattern>[];

    for (final filePath in feature.files) {
      final patterns = await _analyzeFile(filePath, rules);
      allPatterns.addAll(patterns);
    }

    final score = _calculateScore(allPatterns, feature.fileCount);

    return FeatureResult(
      feature: feature,
      patterns: allPatterns,
      gravityScore: score,
    );
  }

  Future<List<RenPattern>> _analyzeFile(
    String filePath,
    List<WidgetRule> rules,
  ) async {
    try {
      final content = File(filePath).readAsStringSync();
      final result = parseString(content: content, throwIfDiagnostics: false);

      final gravityVisitor = GravityVisitor(filePath: filePath, rules: rules);
      result.unit.visitChildren(gravityVisitor);

      final leakVisitor = LeakVisitor(filePath: filePath);
      result.unit.visitChildren(leakVisitor);

      final leakResourceNames = leakVisitor.patterns
          .map((p) => p.name.replaceAll(' leak', '').trim())
          .toSet();

      final filteredGravityPatterns = gravityVisitor.patterns
          .where((p) => !leakResourceNames.contains(p.name))
          .toList();

      final allPatterns = [
        ...filteredGravityPatterns,
        ...leakVisitor.patterns,
      ];

      return allPatterns.map((p) {
        final lineInfo = result.unit.lineInfo;
        final location = lineInfo.getLocation(p.line);
        return RenPattern(
          name: p.name,
          reason: p.reason,
          weight: p.weight,
          file: p.file,
          line: location.lineNumber,
          level: p.level,
          context: p.context,
          fix: p.fix,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Normalizes total weight to a 0–100 score.
  int _calculateScore(List<RenPattern> patterns, int fileCount) {
    if (patterns.isEmpty) return 0;

    final presencePatterns =
        patterns.where((p) => p.level == PatternLevel.presence);
    final contextPatterns =
        patterns.where((p) => p.level == PatternLevel.context);
    final riskPatterns = patterns.where((p) => p.level == PatternLevel.risk);

    const maxPresencePerFile = 80;
    const maxContextPerFile = 120;
    const maxRiskPerFile = 200;

    final presenceWeight = presencePatterns.fold(0, (s, p) => s + p.weight);
    final contextWeight = contextPatterns.fold(0, (s, p) => s + p.weight);
    final riskWeight = riskPatterns.fold(0, (s, p) => s + p.weight);

    final maxPossible = ((maxPresencePerFile * fileCount) +
            (maxContextPerFile * fileCount) +
            (maxRiskPerFile * fileCount))
        .clamp(1, 999999);

    final totalWeight = presenceWeight + contextWeight + riskWeight;
    final score = ((totalWeight / maxPossible) * 100).round();

    return score.clamp(0, 100);
  }
}
