// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.length < 6) {
    print('Usage: dart update_translations.dart <key> <en> <it> <es> <fr> <de>');
    return;
  }

  final key = args[0];
  final map = {
    'en': args[1],
    'it': args[2],
    'es': args[3],
    'fr': args[4],
    'de': args[5],
  };

  for (var entry in map.entries) {
    final lang = entry.key;
    final value = entry.value;
    final file = File('lib/l10n/app_$lang.arb');
    if (!await file.exists()) {
      print('File not found: ${file.path}');
      continue;
    }

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    json[key] = value;
    
    final formatted = const JsonEncoder.withIndent('  ').convert(json);
    await file.writeAsString(formatted);
    print('Updated $lang');
  }
}
