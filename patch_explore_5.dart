import 'dart:io';

void main() {
  final file = File('lib/presentation/screens/explore/explore_screen.dart');
  var content = file.readAsStringSync();

  // 1. Change filteredEvents.map to asMap().entries.map
  content = content.replaceAll(
    'markers: filteredEvents.map((e) {',
    'markers: filteredEvents.asMap().entries.map((entry) {\n                            final index = entry.key;\n                            final e = entry.value;',
  );

  // 2. Change ValueKey(e.id) to ValueKey('${e.id}_$index')
  content = content.replaceAll(
    'key: ValueKey(e.id),',
    'key: ValueKey(\'\${e.id}_\$index\'),',
  );

  // 3. Update the parsing in onClusterTap
  final oldParsing = '''final eventIds = cluster.markers
                                  .map((m) => (m.key as ValueKey<String>).value)
                                  .toSet();''';
  final newParsing = '''final eventIds = cluster.markers
                                  .map((m) {
                                    final keyVal = (m.key as ValueKey<String>).value;
                                    return keyVal.split('_').first;
                                  })
                                  .toSet();''';

  content = content.replaceAll(oldParsing, newParsing);

  file.writeAsStringSync(content);
}
