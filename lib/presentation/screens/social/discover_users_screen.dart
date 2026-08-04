import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../providers/app_state_providers.dart';

import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/shared/user_avatar.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_user_match_card.dart';

class DiscoverUsersScreen extends ConsumerStatefulWidget {
  const DiscoverUsersScreen({super.key});

  @override
  ConsumerState<DiscoverUsersScreen> createState() => _DiscoverUsersScreenState();
}

class _DiscoverUsersScreenState extends ConsumerState<DiscoverUsersScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final users = ref.watch(matchedUsersProvider);
    final pending = ref.watch(pendingFriendshipsProvider);

    return VibraPageScaffold(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Text(l10n.socialTitle, style: Theme.of(context).textTheme.displaySmall),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: VibraSectionHeader(
              title: l10n.socialDiscoverUsers,
              subtitle: l10n.socialHighCompatibility,
              actionLabel: l10n.socialRequestsCount(pending.length),
              onActionTap: () => context.push('/friends'),
            ),
          ),
          SliverList.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return VibraUserMatchCard(
                user: user,
                onTap: () => context.push('/user-profile', extra: user),
                trailing: IconButton(
                  onPressed: () => context.push('/chat'),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: VibraSectionHeader(
              title: l10n.socialPendingFriendships,
              subtitle: l10n.socialRequestsToManage,
            ),
          ),
          SliverList.builder(
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final friendship = pending[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: const UserAvatar(radius: 20),
                title: Text(l10n.socialRequestFrom(friendship.requesterId)),
                trailing: FilledButton.tonal(
                  onPressed: () => context.push('/friends'),
                  child: Text(l10n.socialOpen),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
