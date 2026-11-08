import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../../core/errors/exceptions.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/vibra_ai.dart';
import '../mappers/domain_mappers.dart';
import '../models/event_model.dart';
import 'supabase_datasource.dart';

/// VIBRA AI (docs/vibra-ai.md). Optional: every call degrades to
/// "unavailable" so no other feature depends on it. The conversation stays
/// in the app; only recent turns are sent with each question.
class SupabaseVibraAiDatasource {
  const SupabaseVibraAiDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    if (_supabase.currentUser == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    try {
      final response = await _supabase.client.functions.invoke(
        'vibra-ai',
        body: body,
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on FunctionException catch (e) {
      final details = e.details;
      throw ServerException(
        message: details is Map ? '${details['error']}' : 'assistant_failed',
        statusCode: e.status,
        endpoint: 'vibra-ai',
      );
    }
  }

  /// Unreachable or not deployed: reported as unavailable, never an error.
  Future<AiStatus> status() async {
    try {
      final r = await _call({'action': 'status'});
      return AiStatus(
        available: r['available'] == true,
        consent: r['consent'] == true,
      );
    } catch (_) {
      return const AiStatus(available: false, consent: false);
    }
  }

  Future<void> setConsent(bool enabled) => _supabase.client.rpc(
    'set_ai_assistant_consent',
    params: {'p_enabled': enabled},
  );

  Future<AiAnswer> ask(List<AiMessage> conversation) async {
    final turns = [
      for (final m in conversation)
        if (m.text.trim().isNotEmpty)
          {'role': m.fromUser ? 'user' : 'assistant', 'content': m.text},
    ];
    final start = turns.length > 10 ? turns.length - 10 : 0;
    return AiAnswer.fromJson(
      await _call({'action': 'ask', 'messages': turns.sublist(start)}),
    );
  }

  /// A verified concert from the catalogue (to open its page).
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
