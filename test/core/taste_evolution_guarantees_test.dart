import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Taste Evolution (docs/taste-evolution.md): real history only, owner
/// only, and the user can turn it off.
void main() {
  final sql = File(
    'supabase/migrations/20261122000000_taste_evolution.sql',
  ).readAsStringSync();

  String section(String from) =>
      sql.substring(sql.indexOf(from), sql.indexOf(r'$$;', sql.indexOf(from)));

  test('comparisons read the caller own snapshots only', () {
    final read = section('FUNCTION public.get_taste_evolution(');
    expect(read, contains('SECURITY INVOKER'));
    expect(read, contains('s.user_id = me'));
    expect(read, isNot(contains('INSERT')));
    // The baseline is a real snapshot; a short history is reported as such.
    expect(read, contains("'full_period'"));
    expect(read, contains("'oldest_on'"));
  });

  test('turning history off deletes past snapshots and stops keeping them', () {
    expect(sql, contains('taste_history boolean NOT NULL DEFAULT true'));
    final off = section('FUNCTION public.set_taste_history(');
    expect(off, contains('DELETE FROM public.musical_dna_snapshots'));
    final save = section('FUNCTION public.save_musical_dna(');
    expect(save, contains('captured_on < current_date;'));
    expect(save, contains('current_date - 400'));
  });
}
