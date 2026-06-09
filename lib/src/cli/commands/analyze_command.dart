import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:ren/src/analyzer/feature_analyzer.dart';
import 'package:ren/src/config/config_loader.dart';
import 'package:ren/src/reporter/console_reporter.dart';
import 'package:ren/src/utils/spinner.dart';
import '../../scanner/feature_scanner.dart';

class AnalyzeCommand {
  final ArgResults _results;

  AnalyzeCommand(this._results);

  Future<void> execute() async {
    final rawPath = _results['project'] as String;
    final format = _results['format'] as String;
    final customFeatures = _results['features'] as String?;
    final failOn = _results['fail-on'] as String?;
    final excludeRaw = _results['exclude'] as String?;
    final excludedPaths =
        excludeRaw?.split(',').map((e) => e.trim()).toList() ?? [];
    final projectPath = p.absolute(rawPath);

    final config = ConfigLoader(projectPath: projectPath).load();

    final effectiveFeatures = customFeatures ?? config.features;
    final effectiveFailOn = failOn ?? config.failOn;
    final effectiveExclude =
        excludedPaths.isNotEmpty ? excludedPaths : config.ignore;

    final isJson = format == 'json';

    if (!isJson) {
      ConsolerReporter.printBanner();
      ConsolerReporter.printDivider();
    }

    if (!Directory(projectPath).existsSync()) {
      ConsolerReporter.printError('Project path not found: $projectPath');
      exit(1);
    }

    final pubspec = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      ConsolerReporter.printWarning(
        'No pubspec.yaml found at $projectPath\n'
        '  Make sure you point to a Flutter/Dart project root.',
      );
    }

    if (!isJson) {
      ConsolerReporter.printInfo('Project  : $projectPath');
      ConsolerReporter.printInfo('Format   : $format');
      if (effectiveFeatures != null) {
        ConsolerReporter.printInfo('Features : $effectiveFeatures');
      }
      if (effectiveExclude.isNotEmpty) {
        ConsolerReporter.printInfo('Exclude  : ${effectiveExclude.join(', ')}');
      }
      ConsolerReporter.printDivider();
    }

    final scanner = FeatureScanner(
      projectPath: projectPath,
      customFeaturesPath: effectiveFeatures,
      excludedPaths: effectiveExclude,
    );
    final result = await scanner.scan();

    if (result.error != null) {
      ConsolerReporter.printError(result.error!);
      exit(1);
    }

    if (result.isEmpty) {
      ConsolerReporter.printError(
        'No lib/ directory found. Is this a Dart project?',
      );
      exit(1);
    }

    final analyzer = FeatureAnalyzer(config: config);
    final featureResults = <FeatureResult>[];
    final spinner = Spinner();

    if (!isJson) {
      spinner.update('Scanning project...');
    }

    for (final feature in result.features) {
      if (!isJson) {
        spinner.update(feature.name);
      }
      featureResults.add(await analyzer.analyze(feature));
    }

    if (!isJson) {
      spinner.stop();
    }

    _printResults(featureResults, format, failOn: effectiveFailOn);
  }

  void _printResults(List<FeatureResult> results, String format,
      {String? failOn}) {
    if (format == 'json') {
      _printJson(results);
    } else {
      results.sort((a, b) => b.gravityScore.compareTo(a.gravityScore));

      for (final result in results) {
        ConsolerReporter.printFeatureResult(result);
      }

      ConsolerReporter.printDivider();

      final totalPatterns =
          results.fold(0, (sum, r) => sum + r.patterns.length);
      ConsolerReporter.printInfo(
        '${results.length} feature(s) · $totalPatterns pattern(s) detected',
      );
      print('');
    }

    if (failOn != null) {
      final threshold = GravityLevel.values.byName(failOn);
      final failing =
          results.where((r) => r.level.index >= threshold.index).toList();

      if (failing.isNotEmpty) {
        ConsolerReporter.printError(
          'Failed: ${failing.length} feature(s) at or above ${failOn.toUpperCase()}',
        );
        for (final f in failing) {
          ConsolerReporter.printInfo(
              '  · ${f.feature.name} — ${f.gravityScore}%');
        }
        exit(1);
      } else {
        ConsolerReporter.printSuccess(
          'All features below ${failOn.toUpperCase()} threshold.',
        );
      }
    }
  }

  void _printJson(List<FeatureResult> results) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  "version": "0.1.0",');
    buffer.writeln('  "timestamp": "${DateTime.now().toIso8601String()}",');
    buffer.writeln('  "summary": {');
    buffer.writeln('    "features": ${results.length},');
    buffer.writeln(
        '    "patterns": ${results.fold(0, (s, r) => s + r.patterns.length)},');
    buffer.writeln(
        '    "maxScore": ${results.map((r) => r.gravityScore).reduce((a, b) => a > b ? a : b)}');
    buffer.writeln('  },');
    buffer.writeln('  "features": [');

    for (var i = 0; i < results.length; i++) {
      final r = results[i];
      final comma = i < results.length - 1 ? ',' : '';
      buffer.writeln('    {');
      buffer.writeln('      "name": "${r.feature.name}",');
      buffer.writeln('      "fileCount": ${r.feature.fileCount},');
      buffer.writeln('      "gravityScore": ${r.gravityScore},');
      buffer.writeln('      "level": "${r.level.name}",');
      buffer.writeln('      "patterns": [');

      for (var j = 0; j < r.patterns.length; j++) {
        final pp = r.patterns[j];
        final patternComma = j < r.patterns.length - 1 ? ',' : '';
        buffer.writeln('        {');
        buffer.writeln('          "name": "${pp.name}",');
        buffer.writeln('          "weight": ${pp.weight},');
        buffer.writeln('          "line": ${pp.line},');
        buffer.writeln(
            '          "file": "${pp.file.replaceAll('\\', '/')}"');
        buffer.writeln('        }$patternComma');
      }

      buffer.writeln('      ]');
      buffer.writeln('    }$comma');
    }

    buffer.writeln('  ]');
    buffer.writeln('}');
    print(buffer.toString());
  }
}