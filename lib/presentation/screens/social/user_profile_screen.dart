import 'package:vibra/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/usecase_providers.dart';
import '../../providers/profile_identity_providers.dart';
import '../../widgets/music_story_widgets.dart';
import '../../widgets/profile_identity_widgets.dart';
import '../profile/safety_center_screen.dart';
import '../../widgets/common/vibra_match_indicator.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/vibra_glassmorphic_card.dart';
import '../../widgets/affinity_explanation_card.dart';

class UserProfileScreen extends ConsumerWidget {
  final String? userId;

  const UserProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetUserId =
        userId ?? ref.watch(matchedUsersProvider).firstOrNull?.user.id ?? '';

    if (targetUserId.isEmpty) {
      return VibraPageScaffold(
        appBar: null,
        child: VibraEmptyView(
          title: AppLocalizations.of(context)!.userProfileNotAvailableTitle,
          message: AppLocalizations.of(context)!.userProfileNotAvailableMessage,
        ),
      );
    }

    final userAsync = ref.watch(userProfileDetailProvider(targetUserId));
    final resolvedUser = userAsync.valueOrNull;

    if (userAsync.isLoading && resolvedUser == null) {
      return VibraPageScaffold(
        appBar: null,
        child: const Center(child: VibraLoadingIndicator()),
      );
    }

    if (resolvedUser == null) {
      return VibraPageScaffold(
        appBar: null,
        child: VibraEmptyView(
          title: AppLocalizations.of(context)!.userProfileNotAvailableTitle,
          message: AppLocalizations.of(context)!.userProfileNotAvailableMessage,
        ),
      );
    }

    final targetDisplayName =
        resolvedUser.user.displayName ?? resolvedUser.user.username;
    final targetUsername = resolvedUser.user.username;
    final targetBio = resolvedUser.user.bio;
    final targetAvatarUrl = resolvedUser.user.avatarUrl;
    final compatibility = resolvedUser.compatibility;
    final isFriend = resolvedUser.isFriend;

    final followStats = ref.watch(userFollowStatsProvider(targetUserId));
    final identity = ref
        .watch(profileIdentityProvider(targetUserId))
        .valueOrNull;
    final pendingFriendships = ref.watch(pendingFriendshipsProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final isMe = currentUserId == targetUserId;

    final isPendingSent = pendingFriendships.any(
      (p) => p.requesterId == currentUserId && p.receiverId == targetUserId,
    );
    final isPendingReceived = pendingFriendships.any(
      (p) => p.receiverId == currentUserId && p.requesterId == targetUserId,
    );

    final theme = Theme.of(context);

    return VibraPageScaffold(
      useGradient: false,
      appBar: AppBar(
        title: Text(targetDisplayName),
        actions: [
          if (!isMe)
            PopupMenuButton<String>(
              tooltip: AppLocalizations.of(context)!.storyMore,
              onSelected: (action) async {
                if (action == 'report') {
                  await reportUserFlow(context, ref, targetUserId);
                } else if (action == 'block') {
                  final blocked = await blockUserFlow(
                    context,
                    ref,
                    targetUserId,
                    targetDisplayName,
                  );
                  if (blocked && context.mounted && context.canPop()) {
                    context.pop();
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'report',
                  child: Text(AppLocalizations.of(context)!.safetyReportUser),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Text(AppLocalizations.of(context)!.socialBlockUser),
                ),
              ],
            ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // Profile Header Card
          VibraGlassmorphicCard(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SoundSignatureAvatar(
                  imageUrl: targetAvatarUrl,
                  name: targetDisplayName,
                  dna: identity?.dna,
                  radius: 46,
                ),
                SizedBox(height: 14),
                Text(
                  targetDisplayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '@$targetUsername',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.vibraTokens.textSecondary,
                  ),
                ),
                if (targetBio != null && targetBio.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    targetBio,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.vibraTokens.textPrimary.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 18),
                if (AppConstants.spotifyEnabled &&
                    !isMe &&
                    compatibility > 0) ...[
                  VibraMatchIndicator(
                    percentage: compatibility,
                    size: 104,
                    showTierLabel: true,
                    label: AppLocalizations.of(
                      context,
                    )!.socialAffinity.toUpperCase(),
                  ),
                  SizedBox(height: 20),
                ],

                // Stats Row: Follower, Seguiti
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      context: context,
                      label: AppLocalizations.of(context)!.profileFollowers,
                      value: '${followStats.followersCount}',
                      icon: Icons.people_outline_rounded,
                      iconColor: context.vibraTokens.accentPrimary,
                      onTap: () {
                        context.push(
                          '/follow-list',
                          extra: {
                            'userId': targetUserId,
                            'displayName': targetDisplayName,
                            'initialTabIndex': 0,
                          },
                        );
                      },
                    ),
                    _buildStatItem(
                      context: context,
                      label: AppLocalizations.of(context)!.profileFollowing,
                      value: '${followStats.followingCount}',
                      icon: Icons.person_add_outlined,
                      iconColor: context.vibraTokens.accentPrimary,
                      onTap: () {
                        context.push(
                          '/follow-list',
                          extra: {
                            'userId': targetUserId,
                            'displayName': targetDisplayName,
                            'initialTabIndex': 1,
                          },
                        );
                      },
                    ),
                  ],
                ),

                if (!isMe) ...[
                  SizedBox(height: 20),
                  // Actions Row: Segui & Amicizia & Chat
                  Row(
                    children: [
                      // Pulsante Segui / Seguito
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(
                                    userFollowStatsProvider(
                                      targetUserId,
                                    ).notifier,
                                  )
                                  .toggleFollow();
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.socialFollowUpdateError,
                                  ),
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: followStats.isFollowing
                                ? context.vibraTokens.surfaceMuted
                                : context.vibraTokens.accentFill,
                            foregroundColor: followStats.isFollowing
                                ? context.vibraTokens.textPrimary
                                : context.vibraTokens.onAccent,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            followStats.isFollowing
                                ? AppLocalizations.of(context)!.socialFollowing
                                : AppLocalizations.of(context)!.socialFollow,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: followStats.isFollowing
                                  ? context.vibraTokens.textPrimary
                                  : context.vibraTokens.onAccent,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),

                      // Pulsante Amicizia
                      Expanded(
                        child: isFriend
                            ? OutlinedButton.icon(
                                onPressed: () {
                                  context.push(
                                    '/chat',
                                    extra: {
                                      'otherUserId': targetUserId,
                                      'otherDisplayName': targetDisplayName,
                                    },
                                  );
                                },
                                icon: Icon(Icons.chat_bubble_rounded, size: 16),
                                label: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.socialMessageAction,
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              )
                            : isPendingSent
                            ? OutlinedButton(
                                onPressed: null,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.socialFriendRequestSentShort,
                                  style: TextStyle(
                                    color: context.vibraTokens.textSecondary,
                                  ),
                                ),
                              )
                            : isPendingReceived
                            ? FilledButton(
                                onPressed: () => context.push('/friends'),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      context.vibraTokens.accentSecondary,
                                  foregroundColor: context.vibraTokens.onAccent,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.commonReply,
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(requestFriendshipUseCaseProvider)
                                        .call(targetUserId);
                                    ref.invalidate(pendingFriendshipsProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.userProfileFriendRequestSent,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.socialFriendRequestError,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: Icon(Icons.person_add_rounded, size: 16),
                                label: Text(
                                  AppLocalizations.of(context)!.socialAddFriend,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      context.vibraTokens.accentFill,
                                  foregroundColor: context.vibraTokens.onAccent,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                      ),
                      SizedBox(width: 8),

                      // Shortcut Chat
                      IconButton.filledTonal(
                        tooltip: AppLocalizations.of(
                          context,
                        )!.socialMessageAction,
                        onPressed: () {
                          context.push(
                            '/chat',
                            extra: {
                              'otherUserId': targetUserId,
                              'otherDisplayName': targetDisplayName,
                            },
                          );
                        },
                        icon: Icon(Icons.chat_bubble_outline_rounded, size: 20),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

          // Why you match: the cached pair's explanation, when there is one.
          if (AppConstants.spotifyEnabled &&
              !isMe &&
              compatibility > 0 &&
              (resolvedUser.affinity?.hasExplanation ?? false)) ...[
            const SizedBox(height: 20),
            AffinityExplanationCard(
              score: compatibility,
              details: resolvedUser.affinity!,
            ),
          ],

          // Musical identity: each section as its owner allows (Musical
          // DNA, genres, artists, stats, songs, playlists, events,
          // communities, shared circles, activity).
          const SizedBox(height: 20),
          UserStoriesStrip(userId: targetUserId),
          if (identity != null) ...[
            const SizedBox(height: 20),
            IdentitySections(identity: identity),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    final content = Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: context.vibraTokens.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: context.vibraTokens.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: content,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: content,
    );
  }
}
