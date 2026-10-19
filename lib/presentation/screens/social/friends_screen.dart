import '../../../core/constants/app_constants.dart';
import '../../providers/public_friends_provider.dart';
import '../../widgets/common/vibra_state_views.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/usecase_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_user_match_card.dart';
import '../../widgets/shared/user_avatar.dart';
import '../../widgets/vibra_glassmorphic_card.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _updatingRequests = {};

  Future<void> _updateRequest(String id, Future<void> Function() action) async {
    if (_updatingRequests.contains(id)) return;
    setState(() => _updatingRequests.add(id));
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.friendsRequestUpdateError,
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _updatingRequests.remove(id));
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: VibraGlassmorphicCard(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.vibraTokens.accentPrimary.withValues(
                    alpha: 0.15,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: context.vibraTokens.accentPrimary,
                ),
              ),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.vibraTokens.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.vibraTokens.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (action != null) ...[SizedBox(height: 20), action],
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  void _showUnfriendDialog(MatchedUserPreview friend) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.vibraTokens.surfaceElevated,
        title: Text(
          AppLocalizations.of(context)!.friendsRemoveTitle,
          style: TextStyle(color: context.vibraTokens.textPrimary),
        ),
        content: Text(
          AppLocalizations.of(
            context,
          )!.friendsRemoveBody(friend.user.displayName ?? friend.user.username),
          style: TextStyle(color: context.vibraTokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.vibraTokens.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                // Find friendship ID
                final friendships = await ref
                    .read(listFriendshipsUseCaseProvider)
                    .call('accepted');
                final currentUserId = ref
                    .read(supabaseDatasourceProvider)
                    .currentUser
                    ?.id;
                final friendship = friendships.where((f) {
                  return (f.requesterId == currentUserId &&
                          f.receiverId == friend.user.id) ||
                      (f.receiverId == currentUserId &&
                          f.requesterId == friend.user.id);
                }).firstOrNull;

                if (friendship != null) {
                  await ref
                      .read(pendingFriendshipsProvider.notifier)
                      .deleteFriendship(friendship.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.friendsRemoved(
                            friend.user.displayName ?? friend.user.username,
                          ),
                        ),
                      ),
                    );
                  }
                }
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.friendsRemoveError,
                    ),
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.commonRemove),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    final publicFriends = AppConstants.spotifyEnabled
        ? null
        : ref.watch(publicFriendsProvider);
    final friendsLoading = publicFriends?.isLoading ?? false;
    final friendsFailed = publicFriends?.hasError ?? false;
    final pending = ref.watch(pendingFriendshipsProvider);
    final publicConnections = AppConstants.spotifyEnabled
        ? null
        : ref.watch(publicConnectionProfilesProvider);
    final matchedUsers = AppConstants.spotifyEnabled
        ? ref.watch(matchedUsersProvider)
        : publicConnections!.isLoading || publicConnections.hasError
        ? const <MatchedUserPreview>[]
        : publicConnections.valueOrNull ?? const <MatchedUserPreview>[];
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

    final pendingReceived = pending
        .where((p) => p.receiverId == currentUserId)
        .toList();
    final pendingSent = pending
        .where((p) => p.requesterId == currentUserId)
        .toList();

    final filteredFriends = friends.where((f) {
      if (_searchQuery.isEmpty) return true;
      final name = (f.user.displayName ?? f.user.username).toLowerCase();
      return name.contains(_searchQuery) ||
          f.user.username.toLowerCase().contains(_searchQuery);
    }).toList();

    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.friendsConnectionsTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.chat_outlined),
            tooltip: AppLocalizations.of(context)!.inboxMessages,
            onPressed: () => context.push('/messages'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.vibraTokens.surfaceElevated.withValues(
                      alpha: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.vibraTokens.borderDefault.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: context.vibraTokens.accentPrimary,
                    indicatorWeight: 3,
                    labelColor: context.vibraTokens.accentPrimary,
                    unselectedLabelColor: context.vibraTokens.textSecondary,
                    tabs: [
                      Tab(
                        text: friendsLoading || friendsFailed
                            ? AppLocalizations.of(context)!.friendsTitle
                            : AppLocalizations.of(
                                context,
                              )!.friendsCount(friends.length),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.friendsReceived),
                            if (pendingReceived.isNotEmpty) ...[
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.vibraTokens.accentSecondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${pendingReceived.length}',
                                  style: TextStyle(
                                    color: context.vibraTokens.onAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        text: AppLocalizations.of(
                          context,
                        )!.friendsSentCount(pendingSent.length),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          // ── TAB 1: I MIEI AMICI ─────────────────────────────────
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      style: TextStyle(color: context.vibraTokens.textPrimary),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.friendsSearchHint,
                        hintStyle: TextStyle(
                          color: context.vibraTokens.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: context.vibraTokens.textSecondary,
                        ),
                        filled: true,
                        fillColor: context.vibraTokens.surfaceElevated
                            .withValues(alpha: 0.7),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.vibraTokens.borderDefault.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.vibraTokens.borderDefault.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.vibraTokens.accentPrimary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: friendsLoading
                    ? const VibraLoadingView()
                    : friendsFailed
                    ? _buildEmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: AppLocalizations.of(context)!.friendsTitle,
                        subtitle: AppLocalizations.of(
                          context,
                        )!.friendsLoadError,
                        action: FilledButton.tonalIcon(
                          onPressed: () {
                            ref.invalidate(publicConnectionProfilesProvider);
                            ref.invalidate(publicFriendsProvider);
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(
                            AppLocalizations.of(context)!.commonRetry,
                          ),
                        ),
                      )
                    : filteredFriends.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.people_outline_rounded,
                        title: AppLocalizations.of(context)!.friendsNoneFound,
                        subtitle: AppLocalizations.of(context)!.friendsFindBody,
                        action: FilledButton.tonalIcon(
                          onPressed: () => context.push('/social'),
                          icon: Icon(Icons.explore_rounded),
                          label: Text(
                            AppLocalizations.of(context)!.friendsFindPeople,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(top: 4, bottom: 90),
                        itemCount: filteredFriends.length,
                        itemBuilder: (context, index) {
                          final friend = filteredFriends[index];
                          return VibraUserMatchCard(
                            user: friend,
                            onTap: () => context.push(
                              '/user-profile',
                              extra: friend.user.id,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton.filledTonal(
                                  onPressed: () {
                                    context.push(
                                      '/chat',
                                      extra: {
                                        'otherUserId': friend.user.id,
                                        'otherDisplayName':
                                            friend.user.displayName ??
                                            friend.user.username,
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.chat_bubble_rounded,
                                    size: 18,
                                    color: context.vibraTokens.accentPrimary,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: context
                                        .vibraTokens
                                        .accentPrimary
                                        .withValues(alpha: 0.15),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    size: 20,
                                    color: context.vibraTokens.textSecondary,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'unfriend') {
                                      _showUnfriendDialog(friend);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'unfriend',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person_remove_rounded,
                                            size: 18,
                                            color: context.vibraTokens.error,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.friendsRemoveTitle,
                                            style: TextStyle(
                                              color: context.vibraTokens.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          // ── TAB 2: RICHIESTE RICEVUTE ───────────────────────────
          pendingReceived.isEmpty
              ? _buildEmptyState(
                  icon: Icons.inbox_rounded,
                  title: AppLocalizations.of(context)!.friendsNoReceived,
                  subtitle: AppLocalizations.of(context)!.friendsNoReceivedBody,
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: pendingReceived.length,
                  itemBuilder: (context, index) {
                    final request = pendingReceived[index];
                    MatchedUserPreview? senderUser;
                    for (final u in matchedUsers) {
                      if (u.user.id == request.requesterId) {
                        senderUser = u;
                        break;
                      }
                    }
                    final displayName =
                        senderUser?.user.displayName ??
                        senderUser?.user.username ??
                        AppLocalizations.of(context)!.friendsVibraUser;

                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: context.vibraTokens.surface.withValues(
                          alpha: 0.7,
                        ),
                        borderRadius: VibraSpacing.borderMedium,
                        border: Border.all(
                          color: context.vibraTokens.borderDefault,
                          width: 0.5,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => context.push(
                          '/user-profile',
                          extra: request.requesterId,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: UserAvatar.fromUser(
                          senderUser?.user,
                          radius: 24,
                        ),
                        title: Text(
                          displayName,
                          style: TextStyle(
                            color: context.vibraTokens.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context)!.friendsWantsToConnect,
                          style: TextStyle(
                            color: context.vibraTokens.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton.filled(
                              iconSize: 18,
                              style: IconButton.styleFrom(
                                backgroundColor: context.vibraTokens.error
                                    .withValues(alpha: 0.15),
                              ),
                              onPressed: _updatingRequests.contains(request.id)
                                  ? null
                                  : () => _updateRequest(
                                      request.id,
                                      () => ref
                                          .read(
                                            pendingFriendshipsProvider.notifier,
                                          )
                                          .rejectFriendRequest(request.id),
                                    ),
                              icon: Icon(
                                Icons.close_rounded,
                                color: context.vibraTokens.error,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.vibraTokens.accentPrimary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: IconButton.filled(
                                iconSize: 18,
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      context.vibraTokens.accentPrimary,
                                ),
                                onPressed:
                                    _updatingRequests.contains(request.id)
                                    ? null
                                    : () => _updateRequest(
                                        request.id,
                                        () => ref
                                            .read(
                                              pendingFriendshipsProvider
                                                  .notifier,
                                            )
                                            .acceptFriendRequest(request.id),
                                      ),
                                icon: Icon(
                                  Icons.check_rounded,
                                  color: context.vibraTokens.onAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // ── TAB 3: RICHIESTE INVIATE ────────────────────────────
          pendingSent.isEmpty
              ? _buildEmptyState(
                  icon: Icons.send_rounded,
                  title: AppLocalizations.of(context)!.friendsNoSent,
                  subtitle: AppLocalizations.of(context)!.friendsNoSentBody,
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: pendingSent.length,
                  itemBuilder: (context, index) {
                    final request = pendingSent[index];
                    MatchedUserPreview? targetUser;
                    for (final u in matchedUsers) {
                      if (u.user.id == request.receiverId) {
                        targetUser = u;
                        break;
                      }
                    }
                    final displayName =
                        targetUser?.user.displayName ??
                        targetUser?.user.username ??
                        AppLocalizations.of(context)!.friendsVibraUser;

                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: context.vibraTokens.surface.withValues(
                          alpha: 0.7,
                        ),
                        borderRadius: VibraSpacing.borderMedium,
                        border: Border.all(
                          color: context.vibraTokens.borderDefault,
                          width: 0.5,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => context.push(
                          '/user-profile',
                          extra: request.receiverId,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: UserAvatar.fromUser(
                          targetUser?.user,
                          radius: 24,
                        ),
                        title: Text(
                          displayName,
                          style: TextStyle(
                            color: context.vibraTokens.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context)!.friendsWaitingForReply,
                          style: TextStyle(
                            color: context.vibraTokens.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: OutlinedButton(
                          onPressed: _updatingRequests.contains(request.id)
                              ? null
                              : () => _updateRequest(
                                  request.id,
                                  () => ref
                                      .read(pendingFriendshipsProvider.notifier)
                                      .cancelFriendRequest(request.id),
                                ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.vibraTokens.textSecondary,
                            side: BorderSide(
                              color: context.vibraTokens.borderDefault,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size(0, 32),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.commonCancel,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
