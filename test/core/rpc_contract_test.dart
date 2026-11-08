import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Contract between the app and the database (docs/acceptance.md):
/// PostgREST matches RPC arguments by name, so a renamed parameter or a
/// function that was never granted fails only at run time. This checks
/// every `rpc('name', params: {...})` / `_rpc('name', {...})` call in lib/
/// against the functions defined in supabase/migrations.
void main() {
  final migrations =
      Directory('supabase/migrations')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  // name -> list of signatures (param name, has default).
  final signatures = <String, Map<String, List<(String, bool)>>>{};
  final granted = <String, Set<String>>{};
  final fnPattern = RegExp(
    r'CREATE (?:OR REPLACE )?FUNCTION public\.(\w+)\s*\((.*?)\)\s*RETURNS',
    dotAll: true,
    caseSensitive: false,
  );
  final grantPattern = RegExp(
    r'GRANT EXECUTE ON FUNCTION public\.(\w+)\([^)]*\) TO ([\w, ]+);',
    caseSensitive: false,
  );
  for (final file in migrations) {
    final sql = file.readAsStringSync();
    for (final m in fnPattern.allMatches(sql)) {
      final params = <(String, bool)>[];
      for (final raw in m.group(2)!.split(RegExp(r',(?![^(]*\))'))) {
        final arg = raw.trim();
        if (arg.isEmpty) continue;
        final tokens = arg.split(RegExp(r'\s+'));
        final name =
            const {
              'IN',
              'OUT',
              'INOUT',
              'VARIADIC',
            }.contains(tokens.first.toUpperCase())
            ? tokens[1]
            : tokens.first;
        params.add((
          name,
          RegExp(r'\bDEFAULT\b|=', caseSensitive: false).hasMatch(arg),
        ));
      }
      signatures.putIfAbsent(
        m.group(1)!,
        () => {},
      )[params.map((p) => p.$1).join(',')] = params;
    }
    for (final m in grantPattern.allMatches(sql)) {
      granted
          .putIfAbsent(m.group(1)!, () => {})
          .addAll(m.group(2)!.split(',').map((s) => s.trim()));
    }
  }

  final callPattern = RegExp(r"\b_?rpc\(\s*'(\w+)'(\s*,\s*(?:params:\s*)?\{)?");
  final calls = <({String where, String name, Set<String> keys})>[];
  for (final file
      in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
    final src = file.readAsStringSync();
    for (final m in callPattern.allMatches(src)) {
      final keys = <String>{};
      if (m.group(2) != null) {
        var depth = 1, j = m.end;
        final top = StringBuffer();
        while (depth > 0 && j < src.length) {
          final c = src[j];
          if ('{[('.contains(c)) depth++;
          if ('}])'.contains(c)) depth--;
          if (depth == 1 && !'{[('.contains(c)) top.write(c);
          j++;
        }
        // A key starts the map or follows a comma; quoted strings after
        // `?` or `:` are values (`everyone ? 'everyone' : 'connections'`).
        keys.addAll(
          RegExp(
            r"(?:^|,)\s*'(\w+)'\s*:",
          ).allMatches('$top').map((k) => k.group(1)!),
        );
      }
      final line = '\n'.allMatches(src.substring(0, m.start)).length + 1;
      calls.add((where: '${file.path}:$line', name: m.group(1)!, keys: keys));
    }
  }

  test('there are calls to check', () {
    expect(calls.length, greaterThan(80));
  });

  test('every RPC the app calls exists with matching parameter names', () {
    final problems = <String>[];
    for (final c in calls) {
      final sigs = signatures[c.name];
      if (sigs == null) {
        problems.add('${c.where} ${c.name}: no such function');
        continue;
      }
      final fits = sigs.values.any((params) {
        final names = {for (final p in params) p.$1};
        final required = {
          for (final p in params)
            if (!p.$2) p.$1,
        };
        return names.containsAll(c.keys) && c.keys.containsAll(required);
      });
      if (!fits) {
        problems.add(
          '${c.where} ${c.name}(${c.keys.join(', ')}) vs '
          '${sigs.keys.map((k) => '($k)').join(' | ')}',
        );
      }
    }
    expect(problems, isEmpty);
  });

  test('every RPC the app calls is granted to signed-in users', () {
    final missing = {
      for (final c in calls)
        if (!(granted[c.name] ?? const {}).contains('authenticated') &&
            !(granted[c.name] ?? const {}).contains('anon'))
          c.name,
    };
    expect(missing, isEmpty);
  });

  test('every Edge Function the app invokes exists', () {
    final names = <String>{};
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      names.addAll(
        RegExp(
          r"functions\.invoke\(\s*'([a-z-]+)'",
        ).allMatches(file.readAsStringSync()).map((m) => m.group(1)!),
      );
    }
    expect(names, isNotEmpty);
    for (final n in names) {
      expect(
        File('supabase/functions/$n/index.ts').existsSync(),
        isTrue,
        reason: n,
      );
    }
  });
}
