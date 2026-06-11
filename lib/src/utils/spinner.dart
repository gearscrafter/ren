import 'dart:async';
import 'dart:io';

class Spinner {
  static const _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  static const _interval = Duration(milliseconds: 80);

  static const _cyan = '\x1B[36m';
  static const _dim = '\x1B[2m';
  static const _reset = '\x1B[0m';
  static const _clearLine = '\r\x1B[K';

  Timer? _timer;
  int _frameIndex = 0;
  String _label = '';
  bool _active = false;

  void start([String label = '']) {
    if (_active) return;
    _label = label;
    _active = true;
    _frameIndex = 0;

    _timer = Timer.periodic(_interval, (_) => _render());
  }

  void update(String label) {
    _label = label;
    if (!_active) start(label);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _active = false;
    if (stdout.hasTerminal) {
      stdout.write(_clearLine);
    }
  }

  void succeed(String message) {
    stop();
    print('  ${_cyan}✓$_reset $message');
  }

  void fail(String message) {
    stop();
    print('  \x1B[31m✗$_reset $message');
  }

  void _render() {
    if (!stdout.hasTerminal) return;
    final frame = _frames[_frameIndex % _frames.length];
    _frameIndex++;
    stdout.write(
      '$_clearLine  ${_cyan}$frame$_reset  ${_dim}$_label$_reset',
    );
  }
}
