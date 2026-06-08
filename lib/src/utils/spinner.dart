import 'dart:io';

class Spinner {
  static const _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  static const _cyan = '\x1B[36m';
  static const _dim = '\x1B[2m';
  static const _reset = '\x1B[0m';
  static const _clearLine = '\r\x1B[K';

  int _frame = 0;

  void start(String label) {
    stdout.write('  ${_c(_cyan, _frames[_frame])}  $label\n');
  }

  void update(String detail) {
    _frame = (_frame + 1) % _frames.length;
    stdout.write(
      '$_clearLine  ${_c(_cyan, _frames[_frame])}  ${_c(_dim, detail)}',
    );
  }

  void stop({String? finalMessage}) {
    stdout.write(_clearLine);
    if (finalMessage != null) {
      stdout.writeln(finalMessage);
    }
  }

  static String _c(String code, String text) => '$code$text$_reset';
}
