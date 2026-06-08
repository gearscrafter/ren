import 'dart:io';
import 'package:path/path.dart' as p;
import 'feature.dart';

/// Scans a Flutter project and discovers features by folder structure.
class FeatureScanner {
  static const _featureRoots = ['features', 'modules', 'feature'];

  final String projectPath;
  final String? customFeaturesPath;
  final List<String> excludedPaths;

  FeatureScanner({
    required this.projectPath,
    this.customFeaturesPath,
    this.excludedPaths = const [],
  });

  Future<ScanResult> scan() async {
    final libDir = Directory(p.join(projectPath, 'lib'));

    if (!libDir.existsSync()) {
      return ScanResult(
        features: [],
        strategy: DetectionStrategy.none,
        featureRoot: null,
      );
    }

    if (customFeaturesPath != null) {
      final candidate = Directory(p.join(projectPath, customFeaturesPath!));
      if (!candidate.existsSync()) {
        return ScanResult(
          features: [],
          strategy: DetectionStrategy.none,
          featureRoot: null,
          error: 'Features path not found: $customFeaturesPath',
        );
      }
      final features = await _scanFeatureRoot(candidate);
      return ScanResult(
        features: features,
        strategy: DetectionStrategy.featureFolder,
        featureRoot: candidate.path,
      );
    }

    for (final rootName in _featureRoots) {
      final candidate = Directory(p.join(libDir.path, rootName));
      if (candidate.existsSync()) {
        final features = await _scanFeatureRoot(candidate);
        if (features.isNotEmpty) {
          return ScanResult(
            features: features,
            strategy: DetectionStrategy.featureFolder,
            featureRoot: candidate.path,
          );
        }
      }
    }

    final allFiles = await _dartFilesIn(libDir);
    return ScanResult(
      features: [
        RenFeature(name: 'app', path: libDir.path, files: allFiles),
      ],
      strategy: DetectionStrategy.fallback,
      featureRoot: libDir.path,
    );
  }

  Future<List<RenFeature>> _scanFeatureRoot(Directory root) async {
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
      features.add(RenFeature(
        name: name,
        path: dir.path,
        files: files,
      ));
    }

    return features;
  }

  Future<List<String>> _dartFilesIn(Directory dir) async {
    final dartFiles = <String>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        if (_isExcluded(entity.path)) continue;
        dartFiles.add(entity.path);
      }
    }
    dartFiles.sort();
    return dartFiles;
  }

  bool _isExcluded(String filePath) {
    final normalizedFile = filePath.replaceAll('\\', '/');
    for (final excluded in excludedPaths) {
      final normalizedExcluded =
          p.join(projectPath, excluded).replaceAll('\\', '/');
      if (normalizedFile.startsWith(normalizedExcluded)) return true;
    }
    return false;
  }
}

class ScanResult {
  final List<RenFeature> features;
  final DetectionStrategy strategy;
  final String? featureRoot;
  final String? error;

  const ScanResult({
    required this.features,
    required this.strategy,
    required this.featureRoot,
    this.error,
  });

  bool get isEmpty => features.isEmpty;
  int get totalFiles => features.fold(0, (sum, f) => sum + f.fileCount);
}

enum DetectionStrategy {
  featureFolder,
  fallback,
  none,
}
