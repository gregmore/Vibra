import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/vibra_ai.dart';
import 'core_providers.dart';

/// VIBRA AI (docs/vibra-ai.md).
final aiStatusProvider = FutureProvider.autoDispose<AiStatus>(
  (ref) => ref.watch(supabaseVibraAiDatasourceProvider).status(),
);

class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.sending = false,
    this.error,
  });
  final List<AiMessage> messages;
  final bool sending;

  /// 'rate_limited' | 'consent_required' | 'unavailable' | 'failed'.
  final String? error;
}

/// The conversation lives only in memory on this device.
class AiChatController extends AutoDisposeNotifier<AiChatState> {
  @override
  AiChatState build() => const AiChatState();

  Future<void> send(String text) async {
    final q = text.trim();
    if (q.isEmpty || state.sending) return;
    final messages = [...state.messages, AiMessage.user(q)];
    state = AiChatState(messages: messages, sending: true);
    try {
      final answer = await ref
          .read(supabaseVibraAiDatasourceProvider)
          .ask(messages);
      state = AiChatState(messages: [...messages, AiMessage.assistant(answer)]);
    } catch (e) {
      final m = '$e';
      state = AiChatState(
        messages: messages,
        error: m.contains('rate_limited')
            ? 'rate_limited'
            : m.contains('consent_required')
            ? 'consent_required'
            : m.contains('assistant_unavailable')
            ? 'unavailable'
            : 'failed',
      );
    }
  }

  void clear() => state = const AiChatState();
}

final aiChatProvider =
    NotifierProvider.autoDispose<AiChatController, AiChatState>(
      AiChatController.new,
    );
