import 'package:ren/src/analyzer/feature_analyzer.dart';
import 'package:ren/src/analyzer/pattern.dart';

/// Centralizes all terminal output for Ren.
class ConsolerReporter {
  static const _reset = '\x1B[0m';
  static const _bold = '\x1B[1m';
  static const _dim = '\x1B[2m';
  static const _cyan = '\x1B[36m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _red = '\x1B[31m';
  static const _gray = '\x1B[90m';
  static const _blue = '\x1B[34m';

  static String _c(String code, String text) => '$code$text$_reset';

  static void printBanner() {
    print(
      '  ${_c(_bold, _c(_cyan, '◈ ren'))}  '
      '${_c(_dim, '· Flutter Feature Gravity Analyzer')}',
    );
  }

  static void printDivider() {
    print(_c(_gray, '  ${'─' * 52}'));
  }

  static void printInfo(String message) {
    print('  ${_c(_dim, message)}');
  }

  static void printSuccess(String message) {
    print('  ${_c(_green, '✓')} $message');
  }

  static void printWarning(String message) {
    for (final line in message.split('\n')) {
      print('  ${_c(_yellow, '⚠')} $line');
    }
  }

  static void printError(String message) {
    print('  ${_c(_red, '✗')} $message');
  }

  static void printVersion(String version) {
    printBanner();
    print('');
    print('  ${_c(_dim, 'version')} $version');
    print('');
  }

  static void printFeature({
    required String name,
    required int fileCount,
    required String path,
  }) {
    final nameCol = name.padRight(20);
    final filesCol =
        _c(_blue, '$fileCount file${fileCount == 1 ? '' : 's'}').padRight(20);
    final pathCol = _c(_gray, _shortenPath(path));

    print('  ${_c(_cyan, '◦')} $nameCol $filesCol $pathCol');
  }

  static String _shortenPath(String path) {
    final libIndex = path.indexOf('lib/');
    if (libIndex != -1) return path.substring(libIndex);
    final libIndex2 = path.indexOf('lib\\');
    if (libIndex2 != -1) return path.substring(libIndex2);
    return path;
  }

  static void printFeatureResult(FeatureResult result) {
    final level = result.level;

    final levelColor = switch (level) {
      GravityLevel.low      => _green,
      GravityLevel.medium   => _yellow,
      GravityLevel.high     => '\x1B[38;5;208m',
      GravityLevel.critical => _red,
    };

    final levelLabel = switch (level) {
      GravityLevel.low      => 'LOW     ',
      GravityLevel.medium   => 'MEDIUM  ',
      GravityLevel.high     => 'HIGH    ',
      GravityLevel.critical => 'CRITICAL',
    };

    final bar = _gravityBar(result.gravityScore);
    final nameCol = result.feature.name.padRight(20);
    final score = '${result.gravityScore}%'.padLeft(4);

    print(
      '  ${_c(levelColor, '◦')} $nameCol '
      '${_c(levelColor, bar)}  '
      '${_c(levelColor, levelLabel)}  '
      '${_c(_bold, score)}',
    );

    if (result.patterns.isEmpty) return;
    for (final pattern in result.patterns) {
      final levelIcon = switch (pattern.level) {
        PatternLevel.presence => _c(_gray, '↳'),
        PatternLevel.context  => _c(_yellow, '↳'),
        PatternLevel.risk     => _c(_red, '↳'),
      };

      final contextTag = pattern.context != null
          ? _c(_dim, ' [inside ${pattern.context}]')
          : '';

      print(
        '    $levelIcon ${_c(_dim, pattern.name.padRight(22))}'
        '$contextTag '
        '${_c(_gray, pattern.reason)}',
      );
    }

    print('');
    print('    ${_c(_dim, 'Top contributors:')}');

    final contributions = <String, int>{};
    for (final pattern in result.patterns) {
      contributions[pattern.name] =
          (contributions[pattern.name] ?? 0) + pattern.weight;
    }

    final sorted = contributions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted.take(5)) {
      final dots = '·' * (30 - entry.key.length).clamp(1, 30);
      print(
        '    ${_c(_dim, entry.key)} '
        '${_c(_gray, dots)} '
        '${_c(levelColor, '+${entry.value}')}',
      );
    }

    print('');
  }

  static String _gravityBar(int score) {
    final filled = (score / 20).round().clamp(0, 5);
    final empty = 5 - filled;
    return '●' * filled + '○' * empty;
  }
}
