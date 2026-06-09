import 'dart:io';

import 'package:ren/src/cli/runner.dart';

Future<void> main(List<String> arguments) async {
  if (Platform.isWindows && arguments.isEmpty) {
    _printWindowsHint();
  }
  final runner = RenRunner();
  await runner.run(arguments);
}

void _printWindowsHint() {
  if (!stdout.hasTerminal) return;
  stderr.writeln(
    '\x1B[90m  Tip: On PowerShell, use \x1B[37mrenw\x1B[90m to avoid conflict '
    'with the built-in ren alias.\x1B[0m',
  );
}
