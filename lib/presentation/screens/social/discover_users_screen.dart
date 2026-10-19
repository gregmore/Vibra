import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/public_users_provider.dart';

import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_input.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/shared/user_avatar.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_user_match_card.dart';

class DiscoverUsersScreen extends ConsumerStatefulWidget {
  const DiscoverUsersScreen({super.key});

  @override
  ConsumerState<DiscoverUsersScreen> createState() =>
      _DiscoverUsersScreenState();
}

class _DiscoverUsersScreenState extends ConsumerState<DiscoverUsersScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      await Future.wait([
        if (AppConstants.spotifyEnabled)
          ref.read(matchedUsersProvider.notifier).refresh()
        else
          ref.refresh(publicUsersProvider(_query).future),
        ref.read(pendingFriendshipsProvider.notifier).refresh(),
      ]);
    } catch (_) {
      // Public search errors remain visible in the provider's error state.
    }
  }

  void _commitQuery(String value) {
    final query = String.fromCharCodes(value.trim().runes.take(100));
    setState(
      () => _query = AppConstants.spotifyEnabled ? query.toLowerCase() : query,
    );
  }

  void _changeQuery(String value) {
    _searchDebounce?.cancel();
    if (AppConstants.spotifyEnabled) {
      _commitQuery(value);
      return;
    }
    setState(() {}); // Update the clear action while the query is debounced.
    _searchDebounce = Timer(const Duration(milliseconds: 330), () {
      if (mounted) _commitQuery(value);
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _commitQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final publicUsers = AppConstants.spotifyEnabled
        ? null
        : ref.watch(publicUsersProvider(_query));
    final users = AppConstants.spotifyEnabled
        ? ref.watch(matchedUsersProvider).where((match) {
            return [
              match.user.username,
              match.user.displayName,
              ...match.topArtists,
            ].whereType<String>().any(
              (value) => value.toLowerCase().contains(_query),
            );
          }).toList()
        : publicUsers!.isLoading || publicUsers.hasError
        ? const <MatchedUserPreview>[]
        : publicUsers.asData?.value ?? const <MatchedUserPreview>[];
    final pending = ref.watch(pendingFriendshipsProvider);

    return VibraPageScaffold(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (GoRouter.maybeOf(context)?.canPop() ?? false)
                      BackButton(onPressed: () => context.pop()),
                    Expanded(
                      child: Text(
                        l10n.socialTitle,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    Row(
                      children: [
                        // Amici Shortcut
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: t.cardShadow.color,
                                    blurRadius: t.cardShadow.blurRadius,
                                    offset: t.cardShadow.offset,
                                  ),
                                ],
                              ),
                              child: IconButton.filledTonal(
                                icon: const Icon(
                                  Icons.people_alt_rounded,
                                  size: 20,
                                ),
                                tooltip: l10n.friendsTitle,
                                onPressed: () => context.push('/friends'),
                              ),
                            ),
                            if (pending.isNotEmpty)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: t.warning,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${pending.length}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: t.onAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // Messaggi Shortcut
                        Builder(
                          builder: (context) {
                            final unreadCount = ref.watch(
                              totalUnreadMessagesCountProvider,
                            );
                            final requestCount = ref
                                .watch(messageRequestsProvider)
                                .length;
                            final totalBadge = unreadCount + requestCount;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: t.cardShadow.color,
                                        blurRadius: t.cardShadow.blurRadius,
                                        offset: t.cardShadow.offset,
                                      ),
                                    ],
                                  ),
                                  child: IconButton.filledTonal(
                                    icon: const Icon(
                                      Icons.chat_bubble_rounded,
                                      size: 20,
                                    ),
                                    tooltip: l10n.navChat,
                                    onPressed: () => context.push('/messages'),
                                  ),
                                ),
                                if (totalBadge > 0)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.5),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        totalBadge > 9 ? '9+' : '$totalBadge',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: t.onAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(
              child: VibraSectionHeader(
                title: l10n.socialDiscoverUsers,
                subtitle: AppConstants.spotifyEnabled
                    ? l10n.socialHighCompatibility
                    : l10n.launchCommunitySubtitle,
                actionLabel: l10n.socialRequestsCount(pending.length),
                onActionTap: () => context.push('/friends'),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: VibraInput(
                  controller: _searchController,
                  hintText: AppConstants.spotifyEnabled
                      ? l10n.socialSearchHint
                      : l10n.launchCommunitySubtitle,
                  prefixIcon: Icons.search_rounded,
                  textInputAction: TextInputAction.search,
                  maxLength: AppConstants.spotifyEnabled ? null : 100,
                  onSubmitted: (value) {
                    _searchDebounce?.cancel();
                    _commitQuery(value);
                    FocusScope.of(context).unfocus();
                  },
                  onChanged: _changeQuery,
                  suffix: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.myEventsClearSearch,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clearSearch,
                        ),
                ),
              ),
            ),
            if (publicUsers?.isLoading == true)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            if (publicUsers?.hasError == true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: VibraSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.launchCommunityLoadError),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () =>
                              ref.invalidate(publicUsersProvider(_query)),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (users.isEmpty &&
                publicUsers?.isLoading != true &&
                publicUsers?.hasError != true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: VibraSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          !AppConstants.spotifyEnabled
                              ? l10n.launchCommunityEmptyTitle
                              : _query.isEmpty
                              ? l10n.socialDiscoverEmpty
                              : l10n.socialSearchEmpty,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          !AppConstants.spotifyEnabled
                              ? l10n.launchCommunityEmptyBody
                              : _query.isEmpty
                              ? l10n.socialDiscoverEmptyBody
                              : l10n.socialSearchEmptyBody,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: Icon(
                            _query.isEmpty && !AppConstants.spotifyEnabled
                                ? Icons.refresh_rounded
                                : _query.isEmpty
                                ? Icons.person_outline_rounded
                                : Icons.close_rounded,
                          ),
                          label: Text(
                            _query.isEmpty && !AppConstants.spotifyEnabled
                                ? l10n.commonRetry
                                : _query.isEmpty
                                ? l10n.navProfile
                                : l10n.myEventsClearSearch,
                          ),
                          onPressed: () {
                            if (_query.isEmpty) {
                              if (AppConstants.spotifyEnabled) {
                                context.push('/profile');
                              } else {
                                _refresh();
                              }
                            } else {
                              _clearSearch();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SliverList.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return VibraUserMatchCard(
                  user: user,
                  onTap: () =>
                      context.push('/user-profile', extra: user.user.id),
                  trailing: IconButton(
                    onPressed: () => context.push(
                      '/chat',
                      extra: {
                        'otherUserId': user.user.id,
                        'otherDisplayName':
                            user.user.displayName ?? user.user.username,
                      },
                    ),
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
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ),
            SliverList.builder(
              itemCount: pending.length,
              itemBuilder: (context, index) {
                final friendship = pending[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: t.surfaceElevated,
                    borderRadius: BorderRadius.circular(
                      VibraSpacing.radiusMedium,
                    ),
                    border: Border.all(color: t.borderDefault, width: 0.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: const UserAvatar(radius: 20),
                    title: Text(
                      l10n.socialRequestFrom(friendship.requesterId),
                      style: TextStyle(color: t.textPrimary),
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () => context.push('/friends'),
                      child: Text(l10n.socialOpen),
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}
