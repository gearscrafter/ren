import 'package:ren/src/cli/runner.dart';

Future<void> main(List<String> arguments) async {
  final runner = RenRunner();
  await runner.run(arguments);
}
