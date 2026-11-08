import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/community_widgets.dart';
import '../../widgets/whos_going_section.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/circle.dart';
import '../../../domain/entities/concert_match.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/circle_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_bottom_sheet.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_editorial_event.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/circle_widgets.dart';
import 'circles_screen.dart';

/// One circle: profile, group chat, shared playlist, shared events, members.
class CircleScreen extends ConsumerWidget {
  const CircleScreen({required this.circleId, super.key});

  final String circleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final circles = ref.watch(myCirclesProvider);
    final circle = ref.watch(circleByIdProvider(circleId));
    if (circle == null) {
      return VibraPageScaffold(
        appBar: AppBar(),
        child: circles.isLoading
            ? const VibraLoadingView()
            : VibraErrorView(
                error: circles.error,
                title: l10n.circlesTitle,
                message: l10n.circlesLoadError,
                retryLabel: l10n.commonRetry,
                onRetry: () => ref.invalidate(myCirclesProvider),
              ),
      );
    }
    return DefaultTabController(
      length: 4,
      child: VibraPageScaffold(
        appBar: AppBar(
          title: Text(circle.name),
          actions: [_CircleMenu(circle: circle)],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.circlesTabChat),
              Tab(text: l10n.circlesTabPlaylist),
              Tab(text: l10n.circlesTabEvents),
              Tab(text: l10n.circlesTabMembers),
            ],
          ),
        ),
        child: Column(
          children: [
            _Profile(circle: circle),
            if (circle.eventId != null) _ConcertHeader(circle: circle),
            Expanded(
              child: TabBarView(
                children: [
                  _Chat(circle: circle),
                  _Playlist(circle: circle),
                  _Events(circle: circle),
                  _Members(circle: circle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.circle});
  final Circle circle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final detail = circle.artistName ?? circle.topic;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VibraSpacing.pagePadding,
        VibraSpacing.md,
        VibraSpacing.pagePadding,
        VibraSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              circleBasisLabel(l10n, circle.basis),
              ?detail,
              l10n.circlesMembers(circle.memberCount, circle.maxMembers),
            ].join(' · ').toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: t.accentPrimary,
              letterSpacing: 1.2,
            ),
          ),
          if (circle.description.isNotEmpty) ...[
            const SizedBox(height: VibraSpacing.xs),
            Text(
              circle.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleMenu extends ConsumerWidget {
  const _CircleMenu({required this.circle});
  final Circle circle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final source = ref.read(supabaseCirclesDatasourceProvider);
    return PopupMenuButton<String>(
      onSelected: (value) async {
        try {
          switch (value) {
            case 'mute':
              await source.setMuted(circle.id, !circle.muted);
              ref.invalidate(myCirclesProvider);
            case 'edit':
              await _edit(context, ref);
            case 'leave':
              final ok = await showDialog<bool>(
                context: context,
                builder: (d) => AlertDialog(
                  content: Text(l10n.circlesLeaveConfirm(circle.name)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(d).pop(false),
                      child: Text(l10n.commonCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(d).pop(true),
                      child: Text(l10n.circlesLeave),
                    ),
                  ],
                ),
              );
              if (ok != true) return;
              await source.leave(circle.id);
              ref.invalidate(myCirclesProvider);
              if (context.mounted) context.pop();
          }
        } catch (e) {
          if (context.mounted) circleSnack(context, circleErrorText(l10n, e));
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'mute',
          child: Text(circle.muted ? l10n.circlesUnmute : l10n.circlesMute),
        ),
        if (circle.isAdmin)
          PopupMenuItem(value: 'edit', child: Text(l10n.circlesEdit)),
        PopupMenuItem(value: 'leave', child: Text(l10n.circlesLeave)),
      ],
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final name = TextEditingController(text: circle.name);
    final description = TextEditingController(text: circle.description);
    final save = await VibraBottomSheet.show<bool>(
      context,
      builder: (sheet) => VibraBottomSheet(
        title: l10n.circlesEdit,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: name,
              maxLength: 50,
              decoration: InputDecoration(labelText: l10n.circlesName),
            ),
            TextField(
              controller: description,
              maxLength: 300,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(labelText: l10n.circlesDescription),
            ),
            VibraButton(
              label: l10n.circlesSave,
              tone: VibraButtonTone.signal,
              expanded: true,
              onPressed: () => Navigator.of(sheet).pop(true),
            ),
          ],
        ),
      ),
    );
    if (save == true) {
      await ref
          .read(supabaseCirclesDatasourceProvider)
          .update(
            circle.id,
            name: name.text.trim(),
            description: description.text.trim(),
          );
      ref.invalidate(myCirclesProvider);
    }
    name.dispose();
    description.dispose();
  }
}

class _Chat extends ConsumerStatefulWidget {
  const _Chat({required this.circle});
  final Circle circle;

  @override
  ConsumerState<_Chat> createState() => _ChatState();
}

class _ChatState extends ConsumerState<_Chat> {
  final _text = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final body = _text.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(supabaseCirclesDatasourceProvider)
          .send(widget.circle.id, body);
      _text.clear();
    } catch (e) {
      if (mounted) circleSnack(context, circleErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Long-press: report or block (others), delete (own), remove or
  /// restore (admins).
  Future<void> _messageActions(
    BuildContext context,
    CircleMessage m,
    bool mine,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final admin = widget.circle.isAdmin;
    final action = await VibraBottomSheet.show<String>(
      context,
      builder: (sheet) => VibraBottomSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (value, label) in [
              if (mine) ('delete', l10n.communitiesDelete),
              if (!mine) ('report', l10n.socialReportAction),
              if (!mine) ('block', l10n.socialBlockUser),
              if (admin && !mine && m.heldForReview)
                ('restore', l10n.communitiesRestore),
              if (admin && !mine) ('remove', l10n.groupRemoveAdmin),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(label),
                onTap: () => Navigator.of(sheet).pop(value),
              ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    final source = ref.read(supabaseCirclesDatasourceProvider);
    try {
      switch (action) {
        case 'report':
          await reportInCircle(
            context,
            ref,
            circleId: widget.circle.id,
            reportedId: m.senderId,
            messageId: m.id,
          );
        case 'block':
          await blockCommunityAuthor(context, ref, m.senderId);
        case 'restore':
          await source.restoreMessage(m.id);
        case 'delete' || 'remove':
          await source.removeMessage(m.id);
      }
      ref.invalidate(circleMessagesProvider(widget.circle.id));
    } catch (e) {
      if (context.mounted) circleSnack(context, circleErrorText(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final me = ref.read(supabaseCirclesDatasourceProvider).currentUserId;
    final names = {
      for (final m
          in ref.watch(circleMembersProvider(widget.circle.id)).valueOrNull ??
              const <CircleMember>[])
        m.person.id: m.person.name,
    };
    final locale = Localizations.localeOf(context).toString();
    return Column(
      children: [
        Expanded(
          child: ref
              .watch(circleMessagesProvider(widget.circle.id))
              .when(
                loading: () => const VibraLoadingView(),
                error: (e, _) => VibraErrorView(
                  error: e,
                  title: l10n.circlesTabChat,
                  message: l10n.circlesLoadError,
                ),
                data: (messages) => messages.isEmpty
                    ? Center(
                        child: Text(
                          l10n.circlesChatEmpty,
                          style: TextStyle(color: t.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(VibraSpacing.lg),
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final m = messages[i];
                          final mine = m.senderId == me;
                          return GestureDetector(
                            onLongPress: () =>
                                _messageActions(context, m, mine),
                            child: Align(
                              alignment: mine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 300,
                                ),
                                margin: const EdgeInsets.only(
                                  bottom: VibraSpacing.sm,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: VibraSpacing.md,
                                  vertical: VibraSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: mine
                                      ? t.accentFill
                                      : t.surfaceElevated,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!mine)
                                      Text(
                                        names[m.senderId] ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(color: t.accentPrimary),
                                      ),
                                    if (m.heldForReview)
                                      Text(
                                        l10n.groupHeld,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: mine
                                                  ? t.onAccent
                                                  : t.warning,
                                            ),
                                      ),
                                    Text(
                                      m.body,
                                      style: TextStyle(
                                        color: mine
                                            ? t.onAccent
                                            : t.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      DateFormat.Hm(
                                        locale,
                                      ).format(m.createdAt.toLocal()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: mine
                                                ? t.onAccent.withValues(
                                                    alpha: .7,
                                                  )
                                                : t.textMuted,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.xs,
              VibraSpacing.sm,
              VibraSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    maxLength: 2000,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: l10n.circlesMessageHint,
                      counterText: '',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.circlesMessageHint,
                  onPressed: _sending ? null : _send,
                  icon: Icon(Icons.send_rounded, color: t.accentPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Playlist extends ConsumerWidget {
  const _Playlist({required this.circle});
  final Circle circle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final me = ref.read(supabaseCirclesDatasourceProvider).currentUserId;
    return ref
        .watch(circlePlaylistProvider(circle.id))
        .when(
          loading: () => const VibraLoadingView(),
          error: (e, _) => VibraErrorView(
            error: e,
            title: l10n.circlesTabPlaylist,
            message: l10n.circlesLoadError,
          ),
          data: (items) => ListView(
            padding: const EdgeInsets.all(VibraSpacing.pagePadding),
            children: [
              VibraButton(
                label: l10n.circlesAddTrack,
                leadingIcon: Icons.add_rounded,
                tone: VibraButtonTone.outline,
                size: VibraButtonSize.compact,
                onPressed: () => _add(context, ref),
              ),
              const SizedBox(height: VibraSpacing.md),
              if (items.isEmpty) Text(l10n.circlesPlaylistEmpty),
              for (final item in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.music_note_rounded),
                  title: Text(
                    item.title ?? Uri.tryParse(item.url)?.host ?? item.url,
                  ),
                  subtitle: Text(
                    [
                      ?item.artist,
                      if (item.addedByUsername != null)
                        '@${item.addedByUsername}',
                    ].join(' · '),
                  ),
                  onTap: () {
                    final uri = Uri.tryParse(item.url);
                    if (uri != null && uri.scheme == 'https') {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  trailing: item.addedBy == me || circle.isAdmin
                      ? IconButton(
                          tooltip: l10n.circlesRemove,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () async {
                            try {
                              await ref
                                  .read(supabaseCirclesDatasourceProvider)
                                  .removeFromPlaylist(item.id);
                              ref.invalidate(circlePlaylistProvider(circle.id));
                            } catch (e) {
                              if (context.mounted) {
                                circleSnack(context, circleErrorText(l10n, e));
                              }
                            }
                          },
                        )
                      : null,
                ),
            ],
          ),
        );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final url = TextEditingController();
    final title = TextEditingController();
    final artist = TextEditingController();
    final ok = await VibraBottomSheet.show<bool>(
      context,
      builder: (sheet) => VibraBottomSheet(
        title: l10n.circlesAddTrack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: url,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: l10n.communitiesComposerLinkHint,
              ),
            ),
            TextField(
              controller: title,
              maxLength: 120,
              decoration: InputDecoration(
                hintText: l10n.communitiesComposerTrackHint,
              ),
            ),
            TextField(
              controller: artist,
              maxLength: 80,
              decoration: InputDecoration(
                hintText: l10n.communitiesComposerArtistHint,
              ),
            ),
            VibraButton(
              label: l10n.circlesSave,
              tone: VibraButtonTone.signal,
              expanded: true,
              onPressed: () => Navigator.of(sheet).pop(true),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      try {
        await ref
            .read(supabaseCirclesDatasourceProvider)
            .addToPlaylist(
              circle.id,
              url: url.text.trim(),
              title: title.text.trim(),
              artist: artist.text.trim(),
            );
        ref.invalidate(circlePlaylistProvider(circle.id));
      } catch (e) {
        if (context.mounted) circleSnack(context, circleErrorText(l10n, e));
      }
    }
    url.dispose();
    title.dispose();
    artist.dispose();
  }
}

class _Events extends ConsumerWidget {
  const _Events({required this.circle});
  final Circle circle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(circleEventsProvider(circle.id))
        .when(
          loading: () => const VibraLoadingView(),
          error: (e, _) => VibraErrorView(
            error: e,
            title: l10n.circlesTabEvents,
            message: l10n.circlesLoadError,
          ),
          data: (events) => ListView(
            padding: const EdgeInsets.all(VibraSpacing.pagePadding),
            children: [
              _Plans(circle: circle),
              const SizedBox(height: VibraSpacing.xl),
              VibraButton(
                label: l10n.circlesShareEvent,
                leadingIcon: Icons.event_available_rounded,
                tone: VibraButtonTone.outline,
                size: VibraButtonSize.compact,
                onPressed: () => _share(context, ref),
              ),
              const SizedBox(height: VibraSpacing.md),
              if (events.isEmpty) Text(l10n.circlesEventsEmpty),
              for (final e in events)
                VibraEventRow(
                  event: e,
                  onTap: () => context.push('/event-detail', extra: e),
                ),
            ],
          ),
        );
  }

  /// Shares one of the user's own saved or "going" events with the circle.
  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final mine = ref.read(myEventsProvider);
    final upcoming = [
      ...mine.going,
      ...mine.saved,
    ].where((e) => e.eventDate.isAfter(DateTime.now())).toList();
    final eventId = await VibraBottomSheet.show<String>(
      context,
      builder: (sheet) => VibraBottomSheet(
        title: l10n.circlesShareEvent,
        child: upcoming.isEmpty
            ? Text(l10n.circlesNoSavedEvents)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final e in upcoming.take(20))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.artistName ?? e.name),
                      subtitle: Text(e.venueName ?? e.city ?? ''),
                      onTap: () => Navigator.of(sheet).pop(e.id),
                    ),
                ],
              ),
      ),
    );
    if (eventId == null) return;
    try {
      await ref
          .read(supabaseCirclesDatasourceProvider)
          .setEvent(circle.id, eventId, true);
      ref.invalidate(circleEventsProvider(circle.id));
    } catch (e) {
      if (context.mounted) circleSnack(context, circleErrorText(l10n, e));
    }
  }
}

class _Members extends ConsumerWidget {
  const _Members({required this.circle});
  final Circle circle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final me = ref.read(supabaseCirclesDatasourceProvider).currentUserId;
    final pending =
        ref.watch(circlePendingInvitesProvider(circle.id)).valueOrNull ??
        const [];
    return ref
        .watch(circleMembersProvider(circle.id))
        .when(
          loading: () => const VibraLoadingView(),
          error: (e, _) => VibraErrorView(
            error: e,
            title: l10n.circlesTabMembers,
            message: l10n.circlesLoadError,
          ),
          data: (members) => ListView(
            padding: const EdgeInsets.all(VibraSpacing.pagePadding),
            children: [
              if (circle.isAdmin) ...[
                VibraButton(
                  label: l10n.circlesInvite,
                  leadingIcon: Icons.person_add_alt_rounded,
                  tone: VibraButtonTone.signal,
                  size: VibraButtonSize.compact,
                  onPressed: () => _invite(context, ref),
                ),
                const SizedBox(height: VibraSpacing.md),
              ],
              for (final m in members)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () =>
                      context.push('/user-profile', extra: m.person.id),
                  leading: VibraAvatar(
                    imageUrl: m.person.avatarUrl,
                    name: m.person.name,
                  ),
                  title: Text(m.person.name),
                  subtitle: m.isAdmin || m.eventStatus != null
                      ? Text(
                          [
                            if (m.isAdmin) l10n.circlesAdmin,
                            if (m.eventStatus != null)
                              attendanceStatusLabel(l10n, m.eventStatus!),
                          ].join(' · '),
                          style: TextStyle(color: t.accentPrimary),
                        )
                      : null,
                  trailing: m.person.id == me
                      ? null
                      : PopupMenuButton<String>(
                          onSelected: (action) async {
                            switch (action) {
                              case 'report':
                                await reportInCircle(
                                  context,
                                  ref,
                                  circleId: circle.id,
                                  reportedId: m.person.id,
                                );
                                return;
                              case 'block':
                                await blockCommunityAuthor(
                                  context,
                                  ref,
                                  m.person.id,
                                );
                                return;
                              case 'ban':
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (d) => AlertDialog(
                                    content: Text(
                                      l10n.groupBanConfirm(m.person.name),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(d).pop(false),
                                        child: Text(l10n.commonCancel),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(d).pop(true),
                                        child: Text(l10n.groupBan),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok != true) return;
                            }
                            try {
                              await ref
                                  .read(supabaseCirclesDatasourceProvider)
                                  .manageMember(circle.id, m.person.id, action);
                              ref.invalidate(circleMembersProvider(circle.id));
                              ref.invalidate(myCirclesProvider);
                            } catch (e) {
                              if (context.mounted) {
                                circleSnack(context, circleErrorText(l10n, e));
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            if (circle.isAdmin && !m.isAdmin)
                              PopupMenuItem(
                                value: 'make_admin',
                                child: Text(l10n.circlesMakeAdmin),
                              ),
                            if (circle.isAdmin) ...[
                              PopupMenuItem(
                                value: 'remove',
                                child: Text(l10n.circlesRemoveMember),
                              ),
                              PopupMenuItem(
                                value: 'ban',
                                child: Text(l10n.groupBan),
                              ),
                            ],
                            PopupMenuItem(
                              value: 'report',
                              child: Text(l10n.groupReportMember),
                            ),
                            PopupMenuItem(
                              value: 'block',
                              child: Text(l10n.socialBlockUser),
                            ),
                          ],
                        ),
                ),
              for (final p in pending)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: VibraAvatar(
                    imageUrl: p.person.avatarUrl,
                    name: p.person.name,
                  ),
                  title: Text(p.person.name),
                  subtitle: Text(
                    l10n.circlesPending,
                    style: TextStyle(color: t.textMuted),
                  ),
                  trailing: circle.isAdmin
                      ? IconButton(
                          tooltip: l10n.circlesRevoke,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () async {
                            await ref
                                .read(supabaseCirclesDatasourceProvider)
                                .revoke(p.id);
                            ref.invalidate(
                              circlePendingInvitesProvider(circle.id),
                            );
                          },
                        )
                      : null,
                ),
            ],
          ),
        );
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final chosen = await VibraBottomSheet.show<Set<String>>(
      context,
      builder: (_) => _InviteSheet(circleId: circle.id),
    );
    if (chosen == null || chosen.isEmpty) return;
    final source = ref.read(supabaseCirclesDatasourceProvider);
    var sent = 0;
    Object? lastError;
    for (final id in chosen) {
      try {
        await source.invite(circle.id, id);
        sent++;
      } catch (e) {
        lastError = e;
      }
    }
    ref.invalidate(circlePendingInvitesProvider(circle.id));
    ref.invalidate(circleInviteCandidatesProvider(circle.id));
    if (!context.mounted) return;
    circleSnack(
      context,
      lastError != null && sent == 0
          ? circleErrorText(l10n, lastError)
          : l10n.circlesInvitesSent(sent),
    );
  }
}

/// Only people the server says may be invited (connections and mutual
/// musical matches). Each one receives an invitation to accept or decline.
class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet({required this.circleId});
  final String circleId;

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final candidates = ref.watch(
      circleInviteCandidatesProvider(widget.circleId),
    );
    return VibraBottomSheet(
      title: l10n.circlesInvite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.circlesInviteHint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
          const SizedBox(height: VibraSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: candidates.when(
              loading: () => const VibraLoadingIndicator(),
              error: (_, _) => Text(l10n.circlesLoadError),
              data: (people) => people.isEmpty
                  ? Text(l10n.circlesInviteNone)
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (final p in people)
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _selected.contains(p.id),
                            onChanged: (v) => setState(
                              () => v == true
                                  ? _selected.add(p.id)
                                  : _selected.remove(p.id),
                            ),
                            secondary: VibraAvatar(
                              imageUrl: p.avatarUrl,
                              name: p.name,
                            ),
                            title: Text(p.name),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: VibraSpacing.sm),
          VibraButton(
            label: l10n.circlesInviteSend,
            tone: VibraButtonTone.signal,
            expanded: true,
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.of(context).pop(Set.of(_selected)),
          ),
        ],
      ),
    );
  }
}

/// Group activities (dinner, meeting point, ...). Only members see them;
/// any place is free text a member chose to write.
class _Plans extends ConsumerWidget {
  const _Plans({required this.circle});
  final Circle circle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final me = ref.read(supabaseCirclesDatasourceProvider).currentUserId;
    final plans =
        ref.watch(circlePlansProvider(circle.id)).valueOrNull ??
        const <CirclePlan>[];
    final locale = Localizations.localeOf(context).toString();
    final source = ref.read(supabaseCirclesDatasourceProvider);
    Future<void> run(Future<void> Function() action) async {
      try {
        await action();
        ref.invalidate(circlePlansProvider(circle.id));
      } catch (e) {
        if (context.mounted) circleSnack(context, circleErrorText(l10n, e));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.circlePlans, style: theme.textTheme.titleMedium),
            ),
            TextButton.icon(
              onPressed: () => _add(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.circleAddPlan),
            ),
          ],
        ),
        if (plans.isEmpty)
          Text(l10n.circlePlansEmpty, style: TextStyle(color: t.textSecondary)),
        for (final plan in plans)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(plan.title),
            subtitle: Text(
              [
                if (plan.startsAt != null)
                  DateFormat.MMMd(
                    locale,
                  ).add_Hm().format(plan.startsAt!.toLocal()),
                ?plan.note,
                l10n.circlePlanPeople(plan.participants),
              ].join(' · '),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilterChip(
                  label: Text(
                    plan.joined ? l10n.circlePlanJoined : l10n.circlePlanIn,
                  ),
                  selected: plan.joined,
                  onSelected: (_) => run(() => source.togglePlan(plan.id)),
                ),
                if (plan.createdBy == me || circle.isAdmin)
                  IconButton(
                    tooltip: l10n.circlesRemove,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => run(() => source.removePlan(plan.id)),
                  ),
              ],
            ),
          ),
        Text(
          l10n.circlePlanPrivacy,
          style: theme.textTheme.bodySmall?.copyWith(color: t.textMuted),
        ),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final title = TextEditingController();
    final note = TextEditingController();
    DateTime? when;
    final ok = await VibraBottomSheet.show<bool>(
      context,
      builder: (sheet) => StatefulBuilder(
        builder: (context, setState) => VibraBottomSheet(
          title: l10n.circleAddPlan,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: title,
                maxLength: 80,
                decoration: InputDecoration(labelText: l10n.circlePlanTitle),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_rounded),
                title: Text(
                  when == null
                      ? l10n.circlePlanWhen
                      : DateFormat.MMMd(
                          Localizations.localeOf(context).toString(),
                        ).add_Hm().format(when!),
                ),
                onTap: () async {
                  final now = DateTime.now();
                  final day = await showDatePicker(
                    context: context,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                    initialDate: now,
                  );
                  if (day == null || !context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 20, minute: 0),
                  );
                  if (time == null) return;
                  setState(
                    () => when = DateTime(
                      day.year,
                      day.month,
                      day.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                },
              ),
              TextField(
                controller: note,
                maxLength: 300,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.circlePlanNote),
              ),
              VibraButton(
                label: l10n.circlesSave,
                tone: VibraButtonTone.signal,
                expanded: true,
                onPressed: () => Navigator.of(sheet).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true && title.text.trim().isNotEmpty) {
      try {
        await ref
            .read(supabaseCirclesDatasourceProvider)
            .addPlan(
              circle.id,
              title: title.text.trim(),
              startsAt: when,
              note: note.text.trim(),
              eventId: circle.eventId,
            );
        ref.invalidate(circlePlansProvider(circle.id));
      } catch (e) {
        if (context.mounted) circleSnack(context, circleErrorText(l10n, e));
      }
    }
    title.dispose();
    note.dispose();
  }
}

/// Report a member or one of their messages to Vibra's moderation.
Future<void> reportInCircle(
  BuildContext context,
  WidgetRef ref, {
  required String circleId,
  required String reportedId,
  String? messageId,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final reason = await VibraBottomSheet.show<String>(
    context,
    builder: (sheet) => VibraBottomSheet(
      title: l10n.socialReportAction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (value, label) in [
            ('spam', l10n.socialReportSpam),
            ('harassment', l10n.socialReportHarassment),
            ('inappropriate', l10n.socialReportInappropriate),
          ])
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              onTap: () => Navigator.of(sheet).pop(value),
            ),
        ],
      ),
    ),
  );
  if (reason == null || !context.mounted) return;
  try {
    await ref
        .read(supabaseCirclesDatasourceProvider)
        .report(
          circleId: circleId,
          reportedId: reportedId,
          reason: reason,
          messageId: messageId,
        );
    if (context.mounted) circleSnack(context, l10n.communitiesReported);
  } catch (_) {
    if (context.mounted) circleSnack(context, l10n.socialReportFailed);
  }
}

/// Concert groups: the event and the caller's status, shared with members.
class _ConcertHeader extends ConsumerWidget {
  const _ConcertHeader({required this.circle});
  final Circle circle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final events =
        ref.watch(circleEventsProvider(circle.id)).valueOrNull ?? const [];
    final event = events.where((e) => e.id == circle.eventId).firstOrNull;
    final members =
        ref.watch(circleMembersProvider(circle.id)).valueOrNull ?? const [];
    final me = ref.read(supabaseCirclesDatasourceProvider).currentUserId;
    final mine = members
        .where((m) => m.person.id == me)
        .firstOrNull
        ?.eventStatus;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VibraSpacing.pagePadding,
        0,
        VibraSpacing.pagePadding,
        VibraSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event != null)
            VibraEventRow(
              event: event,
              onTap: () => context.push('/event-detail', extra: event),
            ),
          Row(
            children: [
              Text(
                l10n.groupYourStatus,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: t.textSecondary),
              ),
              const SizedBox(width: VibraSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final status in const [
                        'interested',
                        'maybe',
                        'going',
                      ])
                        Padding(
                          padding: const EdgeInsets.only(
                            right: VibraSpacing.xs,
                          ),
                          child: ChoiceChip(
                            label: Text(attendanceStatusLabel(l10n, status)),
                            selected: mine == status,
                            onSelected: (_) async {
                              try {
                                await ref
                                    .read(supabaseCirclesDatasourceProvider)
                                    .setEventStatus(
                                      circle.id,
                                      mine == status ? null : status,
                                    );
                                ref.invalidate(
                                  circleMembersProvider(circle.id),
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  circleSnack(
                                    context,
                                    circleErrorText(l10n, e),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Text(
            l10n.groupStatusHint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: t.textMuted),
          ),
        ],
      ),
    );
  }
}
