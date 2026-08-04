import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../domain/usecases/social_usecases.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/app_state_providers.dart';
import '../../providers/usecase_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_user_match_card.dart';
import 'package:vibra/l10n/app_localizations.dart';
import '../../widgets/shared/user_avatar.dart';
import '../../widgets/vibra_glassmorphic_card.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  Widget _buildEmptyState(BuildContext context, String title, String subtitle, IconData icon) {
    return VibraGlassmorphicCard(
      margin: const EdgeInsets.symmetric(horizontal: VibraSpacing.pagePadding, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VibraColors.surfaceVariant.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 42, color: VibraColors.accent.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: VibraColors.textSecondary,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final friends = ref.watch(friendsProvider);
    final pending = ref.watch(pendingFriendshipsProvider);
    final matchedUsers = ref.watch(matchedUsersProvider);

    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.friendsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      child: CustomScrollView(
        slivers: [
          const SliverPadding(padding: EdgeInsets.only(top: 8)),
          SliverToBoxAdapter(
            child: VibraSectionHeader(
              title: l10n.friendsYourFriends,
              subtitle: l10n.friendsYourConnections,
            ).animate().fadeIn(duration: 300.ms),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          
          if (friends.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyState(
                context,
                l10n.friendsNoFriendsYet,
                l10n.friendsGoToExplore,
                Icons.people_outline_rounded,
              ),
            )
          else
            SliverList.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return VibraUserMatchCard(
                  user: friend,
                  onTap: () => context.push('/user-profile', extra: friend),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () {
                          context.push(
                            '/chat',
                            extra: {
                              'otherUserId': friend.user.id,
                              'otherDisplayName': friend.user.displayName ?? friend.user.username,
                            },
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_rounded, size: 20, color: VibraColors.accent),
                        style: IconButton.styleFrom(
                          backgroundColor: VibraColors.accent.withValues(alpha: 0.15),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 20, color: VibraColors.textSecondary),
                        onSelected: (value) async {
                          if (value == 'delete') {
                            try {
                              await ref.read(softDeleteChatUseCaseProvider).call(friend.user.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat eliminata')));
                              }
                            } catch (_) {}
                          } else if (value == 'mute') {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat silenziata')));
                            }
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'mute', child: Text('Silenzia Chat')),
                          PopupMenuItem(value: 'delete', child: Text('Elimina Chat', style: TextStyle(color: VibraColors.error))),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
              },
            ),
            
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          
          if (pending.isNotEmpty)
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                  final pendingReceived = pending.where((p) => p.receiverId == currentUserId).toList();
                  final pendingSent = pending.where((p) => p.requesterId == currentUserId).toList();
  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (pendingReceived.isNotEmpty) ...[
                        VibraSectionHeader(
                          title: l10n.friendsReceivedRequests,
                          subtitle: l10n.friendsAcceptOrReject,
                        ).animate().fadeIn(duration: 300.ms),
                        const SizedBox(height: 12),
                        ...pendingReceived.map((request) {
                          MatchedUserPreview? friendUser;
                          for (final u in matchedUsers) {
                            if (u.user.id == request.requesterId) {
                              friendUser = u;
                              break;
                            }
                          }
                          final displayName = friendUser?.user.displayName ??
                              friendUser?.user.username ??
                              AppLocalizations.of(context)!.userGeneric;
  
                          return VibraGlassmorphicCard(
                            margin: const EdgeInsets.symmetric(horizontal: VibraSpacing.pagePadding, vertical: 6),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                UserAvatar.fromUser(friendUser?.user, radius: 26),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          color: VibraColors.textPrimary, 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        )
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.friendsWantsToConnect,
                                        style: const TextStyle(color: VibraColors.textSecondary, fontSize: 13)
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton.filled(
                                      iconSize: 20,
                                      style: IconButton.styleFrom(backgroundColor: VibraColors.error.withValues(alpha: 0.2)),
                                      onPressed: () async {
                                        try {
                                          await ref.read(respondFriendshipUseCaseProvider).call(
                                            RespondFriendshipParams(
                                              friendshipId: request.id,
                                              status: 'rejected',
                                            ),
                                          );
                                          ref.invalidate(pendingFriendshipsProvider);
                                          ref.invalidate(matchedUsersProvider);
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsError(e.toString()))));
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.close_rounded, color: VibraColors.error),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filled(
                                      iconSize: 20,
                                      style: IconButton.styleFrom(backgroundColor: VibraColors.accentWarm),
                                      onPressed: () async {
                                        try {
                                          await ref.read(respondFriendshipUseCaseProvider).call(
                                            RespondFriendshipParams(
                                              friendshipId: request.id,
                                              status: 'accepted',
                                            ),
                                          );
                                          ref.invalidate(pendingFriendshipsProvider);
                                          ref.invalidate(matchedUsersProvider);
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsError(e.toString()))));
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                        }),
                        const SizedBox(height: 32),
                      ],
  
                      if (pendingSent.isNotEmpty) ...[
                        VibraSectionHeader(
                          title: l10n.friendsSentRequests,
                          subtitle: l10n.friendsWaitingForReply,
                        ).animate().fadeIn(duration: 300.ms),
                        const SizedBox(height: 12),
                        ...pendingSent.map((request) {
                          MatchedUserPreview? receiverUser;
                          for (final u in matchedUsers) {
                            if (u.user.id == request.receiverId) {
                              receiverUser = u;
                              break;
                            }
                          }
                          final displayName = receiverUser?.user.displayName ??
                              receiverUser?.user.username ??
                              AppLocalizations.of(context)!.userGeneric;
  
                          return VibraGlassmorphicCard(
                            margin: const EdgeInsets.symmetric(horizontal: VibraSpacing.pagePadding, vertical: 6),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                UserAvatar.fromUser(receiverUser?.user, radius: 26),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          color: VibraColors.textPrimary, 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        )
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.friendsPendingApproval,
                                        style: const TextStyle(color: VibraColors.textSecondary, fontSize: 13)
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                        }),
                      ],
                    ],
                  );
                }
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 160)),
        ],
      ),
    );
  }
}
