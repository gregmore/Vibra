import 'dart:io';

void main() {
  final file = File('lib/presentation/screens/explore/explore_screen.dart');
  var content = file.readAsStringSync();

  final oldTap = 'if (currentZoom >= 17.5) {';
  final newTap =
      'final bounds = cluster.bounds;\n                            final isSameLocation = bounds.southWest == bounds.northEast;\n                            if (currentZoom >= 17.5 || isSameLocation) {';

  content = content.replaceAll(oldTap, newTap);
  file.writeAsStringSync(content);
}
