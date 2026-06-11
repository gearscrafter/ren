/// Represents the configuration loaded from `ren.yaml`.
class RenConfig {
  /// Path to the features root relative to the project.
  /// Equivalent to `--features` flag.
  final String? features;

  /// Gravity level that causes a non-zero exit code.
  /// Equivalent to `--fail-on` flag.
  final String? failOn;

  /// Paths to exclude from analysis, relative to the project root.
  /// Equivalent to `--exclude` flag.
  final List<String> ignore;

  /// Custom weights for built-in patterns.
  /// Keys must match pattern names in widget_rules.dart.
  final Map<String, int> weights;

  /// Custom rules defined by the user.
  final List<CustomRule> customRules;

  const RenConfig({
    this.features,
    this.failOn,
    this.ignore = const [],
    this.weights = const {},
    this.customRules = const [],
  });

  static const empty = RenConfig();
}

/// A user-defined custom rule.
class CustomRule {
  final String name;
  final String reason;
  final int weight;
  final String? fix;

  const CustomRule({
    required this.name,
    required this.reason,
    required this.weight,
    this.fix,
  });
}
