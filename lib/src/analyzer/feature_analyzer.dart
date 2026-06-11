import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:ren/src/analyzer/rules/widget_rules.dart';
import 'package:ren/src/config/ren_config.dart';
import '../scanner/feature.dart';
import '../analyzer/ast_visitor.dart';
import '../analyzer/leak_visitor.dart';
import '../analyzer/pattern.dart';

class FeatureResult {
  final RenFeature feature;
  final List<RenPattern> patterns;
  final int gravityScore;

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

class FeatureAnalyzer {
  final RenConfig config;
  final String projectPath;

  FeatureAnalyzer({
    this.config = RenConfig.empty,
    required this.projectPath,
  });

  AnalysisContextCollection? _buildContext() {
    try {
      return AnalysisContextCollection(
        includedPaths: [Directory(projectPath).absolute.path],
        resourceProvider: PhysicalResourceProvider.INSTANCE,
      );
    } catch (_) {
      return null;
    }
  }

  Future<FeatureResult> analyze(RenFeature feature) async {
    final rules = effectiveRules(config);
    final allPatterns = <RenPattern>[];
    final collection = _buildContext();

    for (final filePath in feature.files) {
      final patterns = await _analyzeFile(
        filePath,
        rules,
        collection: collection,
      );
      allPatterns.addAll(patterns);
    }

    final leakNames = allPatterns
        .where((p) => p.name.contains(' leak'))
        .map((p) => p.name.replaceAll(' leak', '').trim())
        .toSet();

    final deduplicated = allPatterns
        .where((p) => p.name.contains(' leak') || !leakNames.contains(p.name))
        .toList();

    final score = _calculateScore(deduplicated, feature.fileCount);

    return FeatureResult(
      feature: feature,
      patterns: deduplicated,
      gravityScore: score,
    );
  }

  Future<List<RenPattern>> _analyzeFile(
    String filePath,
    List<WidgetRule> rules, {
    AnalysisContextCollection? collection,
  }) async {
    try {
      late final dynamic result;
      bool resolved = false;

      if (collection != null) {
        try {
          final absPath = File(filePath).absolute.path;
          final context = collection.contextFor(absPath);
          final resolvedResult =
              await context.currentSession.getResolvedUnit(absPath);

          if (resolvedResult is ResolvedUnitResult) {
            result = resolvedResult;
            resolved = true;
          }
        } catch (_) {}
      }

      if (!resolved) {
        final content = File(filePath).readAsStringSync();
        result = parseString(content: content, throwIfDiagnostics: false);
      }

      final unit = resolved ? (result as ResolvedUnitResult).unit : result.unit;

      final gravityVisitor = GravityVisitor(filePath: filePath, rules: rules);
      unit.visitChildren(gravityVisitor);

      final leakVisitor = LeakVisitor(filePath: filePath);
      unit.visitChildren(leakVisitor);

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

      final lineInfo = unit.lineInfo;

      return allPatterns.map((p) {
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
