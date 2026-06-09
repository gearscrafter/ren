import 'package:args/args.dart';
import 'package:ren/src/reporter/console_reporter.dart';

class VersionCommand {
  static const String _version = '0.1.0';

  static ArgParser buildParser() => ArgParser();

  Future<void> execute() async {
    ConsolerReporter.printVersion(_version);
  }
}
