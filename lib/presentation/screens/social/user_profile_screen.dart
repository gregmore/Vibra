import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared/user_avatar.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../providers/app_state_providers.dart';
import '../../providers/usecase_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';

class UserProfileScreen extends ConsumerWidget {
  final String? userId;

  const UserProfileScreen({
    super.key,
    this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final matches = ref.watch(matchedUsersProvider);
    final resolvedUser = userId != null 
        ? matches.where((m) => m.user.id == userId).firstOrNull 
        : matches.firstOrNull;

    if (resolvedUser == null) {
      return VibraPageScaffold(
        appBar: null,
        child: VibraEmptyView(
          title: l10n.userProfileNotAvailableTitle,
          message: l10n.userProfileNotAvailableMessage,
        ),
      );
    }

    final displayUser = resolvedUser;
    final theme = Theme.of(context);

    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.userProfileTitle)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              UserAvatar.fromUser(displayUser.user, radius: 42),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayUser.user.displayName ?? displayUser.user.username, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text('@${displayUser.user.username}', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(l10n.userProfileCompatibility(displayUser.compatibility.toString()), style: theme.textTheme.labelLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(displayUser.user.bio ?? '', style: theme.textTheme.bodyLarge),
          if (displayUser.topArtists.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(l10n.userProfileTopArtists, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: displayUser.topArtists.map((artist) => Chip(label: Text(artist))).toList(),
            ),
          ],
          const SizedBox(height: 18),
          Text('${l10n.userProfileEvents}: ${displayUser.attendingEvents}',
              style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
          Row(
            children: [
              if (!displayUser.isFriend)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(requestFriendshipUseCaseProvider).call(displayUser.user.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.userProfileFriendRequestSent)),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.settingsError(e.toString()))),
                          );
                        }
                      }
                    },
                    child: Text(l10n.userProfileSendRequest),
                  ),
                ),
              if (!displayUser.isFriend)
                const SizedBox(width: 10),
              if (displayUser.isFriend)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.push(
                        '/chat',
                        extra: {
                          'otherUserId': displayUser.user.id,
                          'otherDisplayName': displayUser.user.displayName ?? displayUser.user.username,
                        },
                      );
                    },
                    child: Text(l10n.userProfileOpenChat),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
