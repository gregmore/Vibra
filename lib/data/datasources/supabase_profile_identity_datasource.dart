import '../../core/errors/exceptions.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/profile_identity.dart';
import '../mappers/domain_mappers.dart';
import '../models/event_model.dart';
import 'supabase_datasource.dart';

/// Profile: complete musical identity (docs/profile-identity.md).
class SupabaseProfileIdentityDatasource {
  const SupabaseProfileIdentityDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  String? get currentUserId => _supabase.currentUser?.id;

  /// Null when the profile is not visible (blocked, other test segment).
  Future<ProfileIdentity?> identity(String userId) async {
    if (_supabase.currentUser == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    return ProfileIdentity.fromJson(
      await _supabase.client.rpc(
        'get_profile_identity',
        params: {'p_user': userId},
      ),
    );
  }

  Future<void> setLevel(ProfileSection section, SectionLevel level) =>
      _supabase.client.rpc(
        'set_profile_section_visibility',
        params: {'p_section': section.wire, 'p_level': level.name},
      );

  /// An event shown on a profile (to open its page).
  Future<Event?> event(String id) async {
    try {
      final row = await _supabase.client
          .from('events')
          .select()
          .eq('id', id)
          .maybeSingle();
      return row == null ? null : EventModel.fromJson(row).toEntity();
    } catch (_) {
      return null;
    }
  }
}
