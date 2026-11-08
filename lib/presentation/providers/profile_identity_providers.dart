import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/profile_identity.dart';
import 'core_providers.dart';

/// Someone's musical identity as the caller may see it (or my own).
final profileIdentityProvider = FutureProvider.autoDispose
    .family<ProfileIdentity?, String>(
      (ref, userId) =>
          ref.watch(supabaseProfileIdentityDatasourceProvider).identity(userId),
    );
