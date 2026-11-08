import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/safety.dart';
import 'core_providers.dart';

final safetyOverviewProvider = FutureProvider.autoDispose<SafetyOverview>(
  (ref) => ref.watch(supabaseSafetyDatasourceProvider).overview(),
);

final blockedUsersProvider = FutureProvider.autoDispose<List<BlockedUser>>(
  (ref) => ref.watch(supabaseSafetyDatasourceProvider).blocked(),
);
