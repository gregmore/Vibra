import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/direct_message_permission.dart';
import 'app_state_providers.dart';
import 'core_providers.dart';

/// Rechecks when friendship acceptance arrives, without disclosing private GPS.
final directMessagePermissionProvider = FutureProvider.autoDispose
    .family<DirectMessagePermission, String>((ref, otherUserId) async {
      ref.watch(pendingFriendshipsProvider);
      final source = ref.watch(supabaseDatasourceProvider);
      final accountId = source.currentUser?.id;
      var active = true;
      final subscription = source.authStateChanges.listen((event) {
        if (event.session?.user.id != accountId) ref.invalidateSelf();
      });
      ref.onDispose(() {
        active = false;
        subscription.cancel();
      });
      if (accountId == null) {
        throw const AuthException(message: 'Utente non autenticato');
      }
      final permission = await ref
          .watch(supabaseSocialDatasourceProvider)
          .getMessagePermission(receiverId: otherUserId);
      if (!active || source.currentUser?.id != accountId) {
        throw const AuthException(message: 'La sessione è cambiata.');
      }
      return permission;
    });
