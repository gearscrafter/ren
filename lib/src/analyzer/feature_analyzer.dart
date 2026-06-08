import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import '../scanner/feature.dart';
import '../analyzer/ast_visitor.dart';
import '../analyzer/pattern.dart';

/// Maximum possible weight for a single file — used to normalize the score.
/// Represents a theoretical worst case: all heavy widgets in one file.
const _maxWeightPerFile = 100;

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
  Future<FeatureResult> analyze(RenFeature feature) async {
    final allPatterns = <RenPattern>[];

    for (final filePath in feature.files) {
      final patterns = await _analyzeFile(filePath);
      allPatterns.addAll(patterns);
    }

    final score = _calculateScore(allPatterns, feature.fileCount);

    return FeatureResult(
      feature: feature,
      patterns: allPatterns,
      gravityScore: score,
    );
  }

  Future<List<RenPattern>> _analyzeFile(String filePath) async {
    try {
      final content = File(filePath).readAsStringSync();
      final result = parseString(content: content, throwIfDiagnostics: false);
      final visitor = GravityVisitor(filePath: filePath);
      result.unit.visitChildren(visitor);

      return visitor.patterns.map((p) {
        final lineInfo = result.unit.lineInfo;
        final location = lineInfo.getLocation(p.line);
        return RenPattern(
          name: p.name,
          reason: p.reason,
          weight: p.weight,
          file: p.file,
          line: location.lineNumber,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Normalizes total weight to a 0–100 score.
  int _calculateScore(List<RenPattern> patterns, int fileCount) {
    if (patterns.isEmpty) return 0;

    final totalWeight = patterns.fold(0, (sum, p) => sum + p.weight);
    final maxPossible = (_maxWeightPerFile * fileCount).clamp(1, 999999);
    final score = ((totalWeight / maxPossible) * 100).round();

    return score.clamp(0, 100);
  }
}
