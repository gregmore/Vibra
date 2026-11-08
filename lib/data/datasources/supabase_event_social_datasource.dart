import '../../core/constants/db_tables.dart';
import '../../domain/entities/concert_match.dart';
import '../../domain/entities/event_social.dart';
import 'supabase_datasource.dart';

/// Who's Going? (docs/whos-going.md).
class SupabaseEventSocialDatasource {
  const SupabaseEventSocialDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  /// The catalogue id of an event (null when nobody has saved it yet and it
  /// only exists at the provider).
  Future<String?> catalogueId({
    required String source,
    required String externalId,
  }) async {
    final row = await _supabase.client
        .from(DbTables.events)
        .select('id')
        .eq('source', source)
        .eq('external_id', externalId)
        .maybeSingle();
    return row?['id'] as String?;
  }

  Future<EventSocial> social(String eventId) async => EventSocial.fromJson(
    await _supabase.client.rpc(
      'get_event_social',
      params: {'p_event': eventId},
    ),
  );

  Future<MyAttendance> mine(String eventId) async => MyAttendance.fromJson(
    await _supabase.client.rpc(
      'get_my_attendance',
      params: {'p_event': eventId},
    ),
  );

  Future<void> setVisibility(
    String eventId,
    AttendanceVisibility visibility, {
    bool makeDefault = false,
  }) => _supabase.client.rpc(
    'set_attendance_visibility',
    params: {
      'p_event': eventId,
      'p_visibility': visibility.name,
      'p_make_default': makeDefault,
    },
  );

  Future<ConcertMatch> concertMatches(String eventId) async =>
      ConcertMatch.fromJson(
        await _supabase.client.rpc(
          'get_concert_matches',
          params: {'p_event': eventId},
        ),
      );
}
