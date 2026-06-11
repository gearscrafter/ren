import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ren/ren.dart';
import 'package:ren/src/analyzer/feature_analyzer.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ren_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('FeatureScanner', () {
    test('returns strategy=none when no lib/ exists', () async {
      final scanner = FeatureScanner(projectPath: tempDir.path);
      final result = await scanner.scan();

      expect(result.strategy, DetectionStrategy.none);
      expect(result.features, isEmpty);
    });

    test('uses fallback when lib/ exists but no features/ folder', () async {
      _createFile(tempDir, 'lib/main.dart');
      _createFile(tempDir, 'lib/app.dart');

      final scanner = FeatureScanner(projectPath: tempDir.path);
      final result = await scanner.scan();

      expect(result.strategy, DetectionStrategy.fallback);
      expect(result.features.length, 1);
      expect(result.features.first.name, 'app');
      expect(result.features.first.fileCount, 2);
    });

    test('detects features under lib/features/', () async {
      _createFile(tempDir, 'lib/features/auth/login_page.dart');
      _createFile(tempDir, 'lib/features/auth/auth_bloc.dart');
      _createFile(tempDir, 'lib/features/checkout/checkout_page.dart');
      _createFile(tempDir, 'lib/features/home/home_page.dart');

      final scanner = FeatureScanner(projectPath: tempDir.path);
      final result = await scanner.scan();

      expect(result.strategy, DetectionStrategy.featureFolder);
      expect(result.features.length, 3);

      final names = result.features.map((f) => f.name).toList();
      expect(names, containsAll(['auth', 'checkout', 'home']));

      final auth = result.features.firstWhere((f) => f.name == 'auth');
      expect(auth.fileCount, 2);
    });

    test('detects features under lib/modules/ as alternate root', () async {
      _createFile(tempDir, 'lib/modules/profile/profile_page.dart');
      _createFile(tempDir, 'lib/modules/settings/settings_page.dart');

      final scanner = FeatureScanner(projectPath: tempDir.path);
      final result = await scanner.scan();

      expect(result.strategy, DetectionStrategy.featureFolder);
      expect(result.features.length, 2);
    });

    test('ignores hidden directories inside features/', () async {
      _createFile(tempDir, 'lib/features/auth/login.dart');
      _createFile(tempDir, 'lib/features/.dart_tool/something.dart');

      final scanner = FeatureScanner(projectPath: tempDir.path);
      final result = await scanner.scan();

      final names = result.features.map((f) => f.name).toList();
      expect(names, contains('auth'));
      expect(names, isNot(contains('.dart_tool')));
    });

    test('counts total files correctly', () async {
      _createFile(tempDir, 'lib/features/auth/a.dart');
      _createFile(tempDir, 'lib/features/auth/b.dart');
      _createFile(tempDir, 'lib/features/home/c.dart');

      final scanner = FeatureScanner(projectPath: tempDir.path);
      final result = await scanner.scan();

      expect(result.totalFiles, 3);
    });

    test('features are sorted alphabetically', () async {
      _createFile(tempDir, 'lib/features/zebra/z.dart');
      _createFile(tempDir, 'lib/features/alpha/a.dart');
      _createFile(tempDir, 'lib/features/mango/m.dart');

      final scanner = FeatureScanner(projectPath: tempDir.path);
      final result = await scanner.scan();

      final names = result.features.map((f) => f.name).toList();
      expect(names, ['alpha', 'mango', 'zebra']);
    });

    test('returns error when custom features path does not exist', () async {
      _createFile(tempDir, 'lib/main.dart');

      final scanner = FeatureScanner(
        projectPath: tempDir.path,
        customFeaturesPath: 'lib/ui/screens',
      );
      final result = await scanner.scan();

      expect(result.strategy, DetectionStrategy.none);
      expect(result.error, isNotNull);
      expect(result.features, isEmpty);
    });

    test('uses custom features path when provided', () async {
      _createFile(tempDir, 'lib/ui/screens/home/home_page.dart');
      _createFile(tempDir, 'lib/ui/screens/profile/profile_page.dart');

      final scanner = FeatureScanner(
        projectPath: tempDir.path,
        customFeaturesPath: 'lib/ui/screens',
      );
      final result = await scanner.scan();

      expect(result.strategy, DetectionStrategy.featureFolder);
      expect(result.features.length, 2);

      final names = result.features.map((f) => f.name).toList();
      expect(names, containsAll(['home', 'profile']));
    });

    test('custom path takes priority over auto-detection', () async {
      _createFile(tempDir, 'lib/features/auth/auth.dart');
      _createFile(tempDir, 'lib/ui/screens/home/home.dart');

      final scanner = FeatureScanner(
        projectPath: tempDir.path,
        customFeaturesPath: 'lib/ui/screens',
      );
      final result = await scanner.scan();

      final names = result.features.map((f) => f.name).toList();
      expect(names, contains('home'));
      expect(names, isNot(contains('auth')));
    });
  }); // end FeatureScanner

  group('FeatureAnalyzer', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ren_analyzer_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('returns score 0 for empty feature', () async {
      final feature = RenFeature(
        name: 'empty',
        path: tempDir.path,
        files: [],
      );

      final analyzer = FeatureAnalyzer(projectPath: tempDir.path);
      final result = await analyzer.analyze(feature);

      expect(result.gravityScore, 0);
      expect(result.patterns, isEmpty);
      expect(result.level, GravityLevel.low);
    });

    test('detects Opacity in source file', () async {
      final file = _createDartFile(tempDir, 'opacity_test.dart', '''
import 'package:flutter/material.dart';
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Opacity(opacity: 0.5, child: Container());
  }
}
''');

      final feature = RenFeature(
        name: 'test',
        path: tempDir.path,
        files: [file.path],
      );

      final analyzer = FeatureAnalyzer(projectPath: tempDir.path);
      final result = await analyzer.analyze(feature);

      expect(result.patterns, isNotEmpty);
      expect(result.patterns.any((p) => p.name == 'Opacity'), isTrue);
    });

    test('detects ListView in source file', () async {
      final file = _createDartFile(tempDir, 'list_test.dart', '''
import 'package:flutter/material.dart';
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return ListView(children: [Container()]);
  }
}
''');

      final feature = RenFeature(
        name: 'test',
        path: tempDir.path,
        files: [file.path],
      );

      final analyzer = FeatureAnalyzer(projectPath: tempDir.path);
      final result = await analyzer.analyze(feature);

      expect(result.patterns.any((p) => p.name == 'ListView'), isTrue);
    });

    test('does NOT flag ListView.builder', () async {
      final file = _createDartFile(tempDir, 'list_builder_test.dart', '''
import 'package:flutter/material.dart';
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => Container(),
    );
  }
}
''');

      final feature = RenFeature(
        name: 'test',
        path: tempDir.path,
        files: [file.path],
      );

      final analyzer = FeatureAnalyzer(projectPath: tempDir.path);
      final result = await analyzer.analyze(feature);

      expect(result.patterns.any((p) => p.name == 'ListView'), isFalse);
    });

    test('score is clamped between 0 and 100', () async {
      final analyzer = FeatureAnalyzer(projectPath: tempDir.path);

      final empty = RenFeature(name: 'empty', path: tempDir.path, files: []);
      final emptyResult = await analyzer.analyze(empty);
      expect(emptyResult.gravityScore, greaterThanOrEqualTo(0));
      expect(emptyResult.gravityScore, lessThanOrEqualTo(100));
    });

    test('level maps correctly to score ranges', () {
      expect(_levelFor(0), GravityLevel.low);
      expect(_levelFor(20), GravityLevel.low);
      expect(_levelFor(21), GravityLevel.medium);
      expect(_levelFor(45), GravityLevel.medium);
      expect(_levelFor(46), GravityLevel.high);
      expect(_levelFor(70), GravityLevel.high);
      expect(_levelFor(71), GravityLevel.critical);
      expect(_levelFor(100), GravityLevel.critical);
    });
  }); // end FeatureAnalyzer
}

void _createFile(Directory base, String relativePath) {
  final file = File(p.join(base.path, relativePath));
  file.createSync(recursive: true);
  file.writeAsStringSync('// test file\n');
}

File _createDartFile(Directory base, String name, String content) {
  final file = File(p.join(base.path, name));
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
  return file;
}

GravityLevel _levelFor(int score) {
  return switch (score) {
    <= 20 => GravityLevel.low,
    <= 45 => GravityLevel.medium,
    <= 70 => GravityLevel.high,
    _ => GravityLevel.critical,
  };
}
