import 'dart:io';

void main() {
  final file = File('pubspec.yaml');
  var content = file.readAsStringSync();

  if (!content.contains('dependency_overrides:')) {
    content +=
        '\ndependency_overrides:\n  flutter_map_marker_cluster:\n    path: ./packages/flutter_map_marker_cluster\n';
  } else if (!content.contains('flutter_map_marker_cluster:')) {
    content = content.replaceFirst(
      'dependency_overrides:',
      'dependency_overrides:\n  flutter_map_marker_cluster:\n    path: ./packages/flutter_map_marker_cluster',
    );
  }

  file.writeAsStringSync(content);
}
