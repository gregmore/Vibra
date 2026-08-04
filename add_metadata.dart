// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('lib/l10n/app_en.arb');
  final content = await file.readAsString();
  final json = jsonDecode(content) as Map<String, dynamic>;

  json['@myProfileMyEventsSubtitle'] = {
    'placeholders': {
      'count': {'type': 'String'},
    },
  };

  final formatted = const JsonEncoder.withIndent('  ').convert(json);
  await file.writeAsString(formatted);
}
