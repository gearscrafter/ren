import 'dart:io';
import 'package:path/path.dart' as p;
import 'feature.dart';

/// Folders that are utilities/infrastructure — not features.
const _utilityFolders = {
  'utils',
  'helpers',
  'common',
  'shared',
  'core',
  'widgets',
  'theme',
  'constants',
  'extensions',
  'models',
  'entities',
  'dto',
  'generated',
  'l10n',
  'config',
  'di',
  'injection',
  'router',
  'navigation',
  'assets',
  'fonts',
  'images',
  'icons',
  'styles',
  'test',
  'mocks',
  'fakes',
  '_tools',
};

/// Minimum dart files for a folder to be considered a feature candidate.
const _minFilesThreshold = 2;

/// Result of auto-discovery.
class AutoDiscoveryResult {
  final String featureRoot;
  final List<RenFeature> features;
  final List<String> ignoredPaths;

  const AutoDiscoveryResult({
    required this.featureRoot,
    required this.features,
    required this.ignoredPaths,
  });
}

/// Scans lib/ and auto-discovers feature candidates without
/// requiring the user to specify a path.
class AutoDiscovery {
  static const _knownRoots = [
    'features',
    'modules',
    'feature',
    'screens',
    'pages',
  ];

  static const _knownRootPaths = [
    'ui/screens',
    'ui/pages',
    'ui/features',
    'presentation/pages',
    'presentation/screens',
    'presentation/features',
  ];

  final String projectPath;

  AutoDiscovery({required this.projectPath});

  Future<AutoDiscoveryResult?> discover() async {
    final libDir = Directory(p.join(projectPath, 'lib'));
    if (!libDir.existsSync()) return null;

    for (final root in _knownRoots) {
      final candidate = Directory(p.join(libDir.path, root));
      if (candidate.existsSync()) {
        final features = await _featuresFromRoot(candidate);
        if (features.isNotEmpty) {
          return AutoDiscoveryResult(
            featureRoot: _relativePath(candidate.path),
            features: features,
            ignoredPaths: [],
          );
        }
      }
    }

    for (final rootPath in _knownRootPaths) {
      final candidate =
          Directory(p.join(libDir.path, rootPath.replaceAll('/', p.separator)));
      if (candidate.existsSync()) {
        final features = await _featuresFromRoot(candidate);
        if (features.isNotEmpty) {
          return AutoDiscoveryResult(
            featureRoot: _relativePath(candidate.path),
            features: features,
            ignoredPaths: [],
          );
        }
      }
    }

    return await _discoverFromLib(libDir);
  }

  Future<AutoDiscoveryResult?> _discoverFromLib(Directory libDir) async {
    final candidates = <Directory>[];
    final ignored = <String>[];

    final entries = libDir
        .listSync(followLinks: false)
        .whereType<Directory>()
        .toList()
      ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

    for (final dir in entries) {
      final name = p.basename(dir.path);
      if (name.startsWith('.')) continue;

      if (_utilityFolders.contains(name.toLowerCase())) {
        ignored.add(_relativePath(dir.path));
        continue;
      }

      final fileCount = await _dartFileCount(dir);
      if (fileCount >= _minFilesThreshold) {
        candidates.add(dir);
      }
    }

    if (candidates.isEmpty) return null;

    if (candidates.length == 1) {
      final subFeatures = await _featuresFromRoot(candidates.first);
      if (subFeatures.length > 1) {
        return AutoDiscoveryResult(
          featureRoot: _relativePath(candidates.first.path),
          features: subFeatures,
          ignoredPaths: ignored,
        );
      }
    }

    final features = <RenFeature>[];
    for (final dir in candidates) {
      final files = await _dartFilesIn(dir);
      features.add(RenFeature(
        name: p.basename(dir.path),
        path: dir.path,
        files: files,
      ));
    }

    return AutoDiscoveryResult(
      featureRoot: _relativePath(libDir.path),
      features: features,
      ignoredPaths: ignored,
    );
  }

  Future<List<RenFeature>> _featuresFromRoot(Directory root) async {
    final features = <RenFeature>[];

    final entries = root
        .listSync(followLinks: false)
        .whereType<Directory>()
        .toList()
      ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

    for (final dir in entries) {
      final name = p.basename(dir.path);
      if (name.startsWith('.')) continue;

      final files = await _dartFilesIn(dir);
      if (files.isNotEmpty) {
        features.add(RenFeature(
          name: name,
          path: dir.path,
          files: files,
        ));
      }
    }

    return features;
  }

  Future<int> _dartFileCount(Directory dir) async {
    var count = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) count++;
    }
    return count;
  }

  Future<List<String>> _dartFilesIn(Directory dir) async {
    final files = <String>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity.path);
      }
    }
    files.sort();
    return files;
  }

  String _relativePath(String absolutePath) {
    final normalized = absolutePath.replaceAll('\\', '/');
    final projectNormalized = projectPath.replaceAll('\\', '/');
    if (normalized.startsWith(projectNormalized)) {
      return normalized.substring(projectNormalized.length + 1);
    }
    return absolutePath;
  }
}
