import 'dart:io';
import 'package:path/path.dart' as p;
import 'ren_config.dart';

/// Loads and parses `ren.yaml` from the project root.
///
/// Returns [RenConfig.empty] if no config file is found.
class ConfigLoader {
  static const _fileName = 'ren.yaml';

  final String projectPath;
  final String _normalizedPath;

  ConfigLoader({required this.projectPath})
      : _normalizedPath = p.normalize(p.absolute(projectPath));

  RenConfig load() {
    final file = File(p.join(_normalizedPath, _fileName));

    if (!file.existsSync()) {
      return RenConfig.empty;
    }

    try {
      final content = _parse(file.readAsStringSync());
      return content;
    } catch (e) {
      return RenConfig.empty;
    }
  }

  RenConfig _parse(String content) {
    final lines = content.split('\n');

    String? features;
    String? failOn;
    final ignore = <String>[];
    final weights = <String, int>{};
    final customRules = <CustomRule>[];

    var section = '';

    for (var raw in lines) {
      final line = raw.trimRight();
      if (line.trim().isEmpty || line.trim().startsWith('#')) continue;

      if (!line.startsWith(' ') && !line.startsWith('\t')) {
        section = line.trim().replaceAll(':', '');
        continue;
      }

      final trimmed = line.trim();

      switch (section) {
        case 'features':
          features = _parseScalar(raw);

        case 'fail_on':
          failOn = _parseScalar(raw);

        case 'ignore':
          if (trimmed.startsWith('- ')) {
            ignore.add(trimmed.substring(2).trim());
          }

        case 'weights':
          final parts = trimmed.split(':');
          if (parts.length == 2) {
            final key = parts[0].trim();
            final value = int.tryParse(parts[1].trim());
            if (value != null) weights[key] = value;
          }

        case 'custom_rules':
          _parseCustomRule(trimmed, customRules);
      }
    }

    return RenConfig(
      features: features,
      failOn: failOn,
      ignore: ignore,
      weights: weights,
      customRules: customRules,
    );
  }

  String? _parseScalar(String line) {
    final parts = line.split(':');
    if (parts.length >= 2) {
      return parts.sublist(1).join(':').trim();
    }
    return null;
  }

  final Map<String, String> _currentRule = {};

  void _parseCustomRule(String line, List<CustomRule> rules) {
    if (line.startsWith('- name:')) {
      if (_currentRule.isNotEmpty) _flushRule(rules);
      _currentRule['name'] = line.substring(7).trim();
    } else if (line.startsWith('reason:')) {
      _currentRule['reason'] = line.substring(7).trim();
    } else if (line.startsWith('weight:')) {
      _currentRule['weight'] = line.substring(7).trim();
    }

    if (_currentRule.containsKey('name') &&
        _currentRule.containsKey('reason') &&
        _currentRule.containsKey('weight')) {
      _flushRule(rules);
    }
  }

  void _flushRule(List<CustomRule> rules) {
    final name = _currentRule['name'];
    final reason = _currentRule['reason'];
    final weight = int.tryParse(_currentRule['weight'] ?? '');

    if (name != null && reason != null && weight != null) {
      rules.add(CustomRule(name: name, reason: reason, weight: weight));
    }
    _currentRule.clear();
  }
}
