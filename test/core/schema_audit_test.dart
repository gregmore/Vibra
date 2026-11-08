import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Schema rules (docs/architecture.md) checked against every migration from
/// this development cycle onward: RLS on public tables, an explicit delete
/// rule on every foreign key, and an index on every foreign-key column.
void main() {
  final files =
      Directory('supabase/migrations')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final all = files.map((f) => f.readAsStringSync()).join('\n');
  final recent = files
      .where((f) => f.uri.pathSegments.last.compareTo('20261105') >= 0)
      .map((f) => f.readAsStringSync())
      .join('\n');

  final tablePattern = RegExp(
    r'CREATE TABLE (?:IF NOT EXISTS )?(public|vibra_private)\.(\w+) \((.*?)\n\);',
    dotAll: true,
  );
  final fkPattern = RegExp(
    r'^\s*(\w+) \w+[^\n]*REFERENCES (\S+)\(\w+\)( ON DELETE (CASCADE|SET NULL|RESTRICT))?',
    multiLine: true,
  );

  /// Columns that lead some index, unique constraint or primary key.
  Set<String> leading(String schema, String table, String body) {
    final out = <String>{};
    final full = RegExp.escape('$schema.$table');
    for (final m in RegExp(
      'CREATE (?:UNIQUE )?INDEX (?:IF NOT EXISTS )?\\w+\\s+ON $full(?: USING \\w+)? \\(([^)]*)\\)',
    ).allMatches(all)) {
      out.add(m.group(1)!.split(',').first.trim().split(' ').first);
    }
    for (final m in RegExp(
      r'(?:PRIMARY KEY|UNIQUE) \(([^)]*)\)',
    ).allMatches(body)) {
      out.add(m.group(1)!.split(',').first.trim());
    }
    for (final m in RegExp(
      r'^\s*(\w+) [^\n]*\b(PRIMARY KEY|UNIQUE)\b',
      multiLine: true,
    ).allMatches(body)) {
      out.add(m.group(1)!);
    }
    return out;
  }

  final tables = tablePattern.allMatches(recent).toList();

  test('there are tables to check', () {
    expect(tables.length, greaterThan(30));
  });

  test('every public table has RLS enabled', () {
    for (final t in tables.where((t) => t.group(1) == 'public')) {
      expect(
        all,
        contains('ALTER TABLE public.${t.group(2)} ENABLE ROW LEVEL SECURITY'),
        reason: t.group(2),
      );
    }
  });

  test('every foreign key says what happens on delete', () {
    for (final t in tables) {
      for (final fk in fkPattern.allMatches(t.group(3)!)) {
        expect(
          fk.group(4),
          isNotNull,
          reason: '${t.group(2)}.${fk.group(1)} → ${fk.group(2)}',
        );
      }
    }
  });

  test('every foreign-key column is indexed', () {
    final missing = <String>[];
    for (final t in tables) {
      final indexed = leading(t.group(1)!, t.group(2)!, t.group(3)!);
      for (final fk in fkPattern.allMatches(t.group(3)!)) {
        if (!indexed.contains(fk.group(1))) {
          missing.add('${t.group(2)}.${fk.group(1)}');
        }
      }
    }
    expect(missing, isEmpty);
  });

  test('SECURITY DEFINER functions never trust current_user', () {
    // Inside a definer function current_user is the owner, so a role check
    // on it silently never matches (use auth.role() or auth.uid()).
    final definer = RegExp(
      r'CREATE (?:OR REPLACE )?FUNCTION ([\w.]+)\([^)]*\)[^$]*?SECURITY DEFINER[^$]*?\$\$(.*?)\$\$;',
      dotAll: true,
    );
    final offenders = [
      for (final m in definer.allMatches(recent))
        if (RegExp(r'\bcurrent_user\b').hasMatch(m.group(2)!)) m.group(1)!,
    ];
    expect(offenders, isEmpty);
  });

  test('vibra_private is never exposed through the API', () {
    final config = File('supabase/config.toml').readAsStringSync();
    expect(config, contains('schemas = ["public", "graphql_public"]'));
  });

  test('no server secret is referenced from the app', () {
    final dart = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.readAsStringSync())
        .join('\n');
    for (final secret in [
      'SERVICE_ROLE',
      'service_role_key',
      'SPOTIFY_CLIENT_SECRET',
      'TICKETMASTER_API_KEY',
      'ANTHROPIC_API_KEY',
      'FIREBASE_SERVICE_ACCOUNT',
      'VIBRA_CATALOGUE_JOB_SECRET',
    ]) {
      expect(dart, isNot(contains(secret)), reason: secret);
    }
  });
}
