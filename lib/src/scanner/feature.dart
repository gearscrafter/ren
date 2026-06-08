/// Represents a single feature detected in the project.
class RenFeature {
  /// Display name derived from the folder name.
  final String name;

  /// Absolute path to the feature's root directory.
  final String path;

  /// Dart source files that belong to this feature.
  final List<String> files;

  const RenFeature({
    required this.name,
    required this.path,
    required this.files,
  });

  int get fileCount => files.length;

  @override
  String toString() => 'RenFeature(name: $name, files: $fileCount)';
}
