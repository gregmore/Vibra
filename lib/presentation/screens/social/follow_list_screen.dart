import 'package:vibra/l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/vibra_neon_avatar.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/usecase_providers.dart';
import '../../../domain/usecases/social_usecases.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/vibra_glassmorphic_card.dart';

class FollowListScreen extends ConsumerStatefulWidget {
  final String userId;
  final String displayName;
  final int initialTabIndex;

  const FollowListScreen({
    super.key,
    required this.userId,
    required this.displayName,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends ConsumerState<FollowListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];
  bool _isLoadingFollowers = true;
  bool _isLoadingFollowing = true;
  bool _followersFailed = false;
  bool _followingFailed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _loadFollowers();
    _loadFollowing();
  }

  Future<void> _loadFollowers() async {
    setState(() {
      _isLoadingFollowers = true;
      _followersFailed = false;
    });
    try {
      final list = await ref
          .read(getFollowersUseCaseProvider)
          .call(GetFollowListParams(userId: widget.userId));
      if (mounted) {
        setState(() {
          _followers = list;
          _isLoadingFollowers = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingFollowers = false;
          _followersFailed = true;
        });
      }
    }
  }

  Future<void> _loadFollowing() async {
    setState(() {
      _isLoadingFollowing = true;
      _followingFailed = false;
    });
    try {
      final list = await ref
          .read(getFollowingUseCaseProvider)
          .call(GetFollowListParams(userId: widget.userId));
      if (mounted) {
        setState(() {
          _following = list;
          _isLoadingFollowing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingFollowing = false;
          _followingFailed = true;
        });
      }
    }
  }

  Widget _loadError(Future<void> Function() retry) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        AppLocalizations.of(context)!.socialUsersLoadError,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: retry,
        child: Text(AppLocalizations.of(context)!.commonRetry),
      ),
    ],
  );

  Widget _buildUserTile(Map<String, dynamic> userRow) {
    final targetId = userRow['id']?.toString() ?? '';
    final username = userRow['username']?.toString().trim() ?? '';
    final name = userRow['display_name']?.toString().trim() ?? '';
    final displayName = name.isNotEmpty
        ? name
        : username.isNotEmpty
        ? username
        : AppLocalizations.of(context)!.userGeneric;
    final avatarUrl = userRow['avatar_url']?.toString();
    final bio = userRow['bio']?.toString();

    final followStats = ref.watch(userFollowStatsProvider(targetId));
    final myId = ref.read(supabaseDatasourceProvider).currentUser?.id;
    final isMe = myId == targetId;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ClipRRect(
        borderRadius: VibraSpacing.borderMedium,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: context.vibraTokens.surfaceElevated.withValues(alpha: 0.7),
              borderRadius: VibraSpacing.borderMedium,
              border: Border.all(
                color: context.vibraTokens.borderDefault,
                width: 0.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: VibraSpacing.borderMedium,
              child: ListTile(
                onTap: () => context.push('/user-profile', extra: targetId),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: VibraNeonAvatar(
                  imageUrl: avatarUrl ?? '',
                  radius: 24,
                  score: 0.8,
                  displayName: displayName,
                ),
                title: Text(
                  displayName,
                  style: TextStyle(
                    color: context.vibraTokens.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (username.isNotEmpty)
                      Text(
                        '@$username',
                        style: TextStyle(
                          color: context.vibraTokens.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    if (bio != null && bio.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.vibraTokens.textPrimary.withValues(
                            alpha: 0.8,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: isMe
                    ? null
                    : Container(
                        decoration: followStats.isFollowing
                            ? null
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.vibraTokens.accentPrimary
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                        child: FilledButton.tonal(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(
                                    userFollowStatsProvider(targetId).notifier,
                                  )
                                  .toggleFollow();
                            } catch (_) {
                              if (!mounted) return;
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
                                : context.vibraTokens.accentPrimary,
                            foregroundColor: followStats.isFollowing
                                ? context.vibraTokens.textPrimary
                                : context.vibraTokens.onAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            minimumSize: Size(0, 32),
                          ),
                          child: Text(
                            followStats.isFollowing
                                ? AppLocalizations.of(context)!.socialFollowing
                                : AppLocalizations.of(context)!.socialFollow,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: followStats.isFollowing
                                  ? context.vibraTokens.textPrimary
                                  : context.vibraTokens.onAccent,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final followStats = ref.watch(userFollowStatsProvider(widget.userId));

    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(
          widget.displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.vibraTokens.accentPrimary,
          indicatorWeight: 3,
          labelColor: context.vibraTokens.accentPrimary,
          unselectedLabelColor: context.vibraTokens.textSecondary,
          tabs: [
            Tab(
              text: AppLocalizations.of(
                context,
              )!.socialFollowersCount(followStats.followersCount),
            ),
            Tab(
              text: AppLocalizations.of(
                context,
              )!.socialFollowingCount(followStats.followingCount),
            ),
          ],
        ),
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          // Followers Tab
          RefreshIndicator(
            onRefresh: _loadFollowers,
            child: _isLoadingFollowers
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.vibraTokens.accentPrimary,
                    ),
                  )
                : _followersFailed
                ? _loadError(_loadFollowers)
                : _followers.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: VibraGlassmorphicCard(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: context.vibraTokens.accentPrimary
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.vibraTokens.accentPrimary
                                        .withValues(alpha: 0.2),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.people_outline_rounded,
                                size: 32,
                                color: context.vibraTokens.accentPrimary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.socialNoFollowers,
                              style: TextStyle(
                                color: context.vibraTokens.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.socialNoFollowersBody,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.vibraTokens.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    itemCount: _followers.length,
                    itemBuilder: (context, index) =>
                        _buildUserTile(_followers[index]),
                  ),
          ),

          // Following Tab
          RefreshIndicator(
            onRefresh: _loadFollowing,
            child: _isLoadingFollowing
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.vibraTokens.accentPrimary,
                    ),
                  )
                : _followingFailed
                ? _loadError(_loadFollowing)
                : _following.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: VibraGlassmorphicCard(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: context.vibraTokens.accentPrimary
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.vibraTokens.accentPrimary
                                        .withValues(alpha: 0.2),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_add_outlined,
                                size: 32,
                                color: context.vibraTokens.accentPrimary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.socialNoFollowing,
                              style: TextStyle(
                                color: context.vibraTokens.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.socialNoFollowingBody,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.vibraTokens.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    itemCount: _following.length,
                    itemBuilder: (context, index) =>
                        _buildUserTile(_following[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
