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

  const RenPattern({
    required this.name,
    required this.reason,
    required this.weight,
    required this.file,
    required this.line,
  });
}
