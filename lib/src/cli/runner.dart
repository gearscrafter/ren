import 'package:args/args.dart';
import 'package:ren/src/cli/commands/analyze_command.dart';
import 'package:ren/src/reporter/console_reporter.dart';

class RenRunner {
  static const String _version = '0.1.0';

  final ArgParser _parser;

  RenRunner() : _parser = _buildParser();

  static ArgParser _buildParser() {
    final parser = ArgParser();

    parser.addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage information.',
    );

    parser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Show the current version of ren.',
    );

    parser.addOption(
      'project',
      abbr: 'p',
      defaultsTo: '.',
      help: 'Path to the Flutter project to analyze.',
      valueHelp: 'path',
    );

    parser.addOption(
      'features',
      defaultsTo: null,
      help: 'Relative path to the features root (e.g. lib/ui/screens).',
      valueHelp: 'path',
    );

    parser.addOption(
      'format',
      abbr: 'f',
      defaultsTo: 'console',
      allowed: ['console', 'json'],
      allowedHelp: {
        'console': 'Human-readable ANSI output (default).',
        'json': 'Machine-readable JSON — suitable for CI/CD.',
      },
      help: 'Output format.',
    );

    parser.addOption(
      'fail-on',
      defaultsTo: null,
      allowed: ['low', 'medium', 'high', 'critical'],
      allowedHelp: {
        'low': 'Fail if any feature is LOW or above.',
        'medium': 'Fail if any feature is MEDIUM or above.',
        'high': 'Fail if any feature is HIGH or above.',
        'critical': 'Fail only if any feature is CRITICAL.',
      },
      help: 'Exit with code 1 if any feature reaches this gravity level.',
      valueHelp: 'level',
    );

    parser.addOption(
      'exclude',
      defaultsTo: null,
      help: 'Comma-separated list of paths to exclude from analysis.',
      valueHelp: 'path1,path2',
    );

    return parser;
  }

  Future<void> run(List<String> arguments) async {
    try {
      final results = _parser.parse(arguments);

      if (results['help'] as bool) {
        _printUsage();
        return;
      }

      if (results['version'] as bool) {
        ConsolerReporter.printVersion(_version);
        return;
      }

      await AnalyzeCommand(results).execute();
    } on FormatException catch (e) {
      ConsolerReporter.printError(e.message);
      _printUsage();
    }
  }

  void _printUsage() {
    ConsolerReporter.printBanner();
    print('');
    print('  Usage: ren [options]');
    print('');
    print('  Options:');
    print(_parser.usage);
    print('');
    print('  Examples:');
    print('    ren');
    print('    ren --project ./my_app');
    print('    ren --project ./my_app --features lib/ui/screens');
    print('    ren --format json > report.json');
    print('    ren --fail-on high');
  }
}
