import 'package:args/args.dart';
import 'package:ren/src/cli/commands/analyze_command.dart';
import 'package:ren/src/cli/commands/init_command.dart';
import 'package:ren/src/reporter/console_reporter.dart';
import 'package:path/path.dart' as p;

class RenRunner {
  static const String _version = '0.2.2';

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

    parser.addFlag(
      'init',
      negatable: false,
      help: 'Scan project and generate ren.yaml.',
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
      'exclude',
      defaultsTo: null,
      help: 'Comma-separated list of paths to exclude.',
      valueHelp: 'path1,path2',
    );

    parser.addOption(
      'fail-on',
      defaultsTo: null,
      allowed: ['low', 'medium', 'high', 'critical'],
      help: 'Exit with code 1 if any feature reaches this level.',
      valueHelp: 'level',
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

      final projectPath = p.absolute(results['project'] as String);

      if (results['init'] as bool) {
        await InitCommand(projectPath: projectPath).execute();
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
    print('    ren                    # auto-discover features');
    print('    ren --init             # generate ren.yaml');
    print('    ren --fail-on high     # CI/CD mode');
    print('    ren --format json      # JSON output');
  }
}
