import 'dart:io';

void main() {
  final file = File('lib/presentation/screens/explore/explore_screen.dart');
  var content = file.readAsStringSync();

  // Find the start and end indices of the bottom sheet logic in MarkerClusterLayerOptions
  final startIndex = content.indexOf('MarkerClusterLayerOptions(');
  final endIndex = content.indexOf('maxClusterRadius: 40,');

  if (startIndex != -1 && endIndex != -1) {
    final oldText = content.substring(startIndex, endIndex);
    final newText =
        'MarkerClusterLayerOptions(\n                          spiderfyCluster: true,\n                          ';
    content = content.replaceFirst(oldText, newText);
  }

  file.writeAsStringSync(content);
}
