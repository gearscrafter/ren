import 'package:test/test.dart';
import 'package:ren/src/cli/runner.dart';

void main() {
  group('RenRunner', () {
    test('runs without throwing on --help', () async {
      final runner = RenRunner();
      await expectLater(runner.run(['--help']), completes);
    });

    test('runs without throwing on --version', () async {
      final runner = RenRunner();
      await expectLater(runner.run(['--version']), completes);
    });

    test('runs without throwing on analyze --help', () async {
      final runner = RenRunner();
      await expectLater(runner.run(['analyze', '--help']), completes);
    });

    test('runs without throwing on unknown command', () async {
      final runner = RenRunner();
      await expectLater(runner.run(['unknown']), completes);
    });

    test('runs without throwing on no arguments', () async {
      final runner = RenRunner();
      await expectLater(runner.run([]), completes);
    });
  });
}
