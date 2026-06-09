/// Represents a single costly pattern detected in a Dart source file.
class RenPattern {
  /// Human-readable name of the pattern.
  final String name;

  /// Why this pattern is costly.
  final String reason;

  /// Gravity weight — how much this pattern contributes to the score.
  final int weight;

  /// File where the pattern was found.
  final String file;

  /// Line number inside the file (1-based).
  final int line;

  /// Detection level — indicates whether this pattern was detected in isolation
  /// or as part of a costly combination with a parent widget.
  ///
  /// - [PatternLevel.presence] — widget detected on its own (base weight).
  /// - [PatternLevel.context] — widget detected inside a costly parent (weight × 1.5).
  /// - [PatternLevel.risk] — widget detected inside a critical parent (weight × 2.5).
  final PatternLevel level;

  /// The parent widget that triggered a compound rule, if any.
  ///
  /// For example, if `Opacity` is detected inside `AnimatedBuilder`,
  /// this field contains `'AnimatedBuilder'`.
  /// `null` when [level] is [PatternLevel.presence].
  final String? context;

  const RenPattern({
    required this.name,
    required this.reason,
    required this.weight,
    required this.file,
    required this.line,
    this.level = PatternLevel.presence,
    this.context,
  });
}


enum PatternLevel {
  presence,
  context,
  risk,
}