import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/music/genre_catalog.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/musical_dna.dart';
import '../../domain/entities/profile_identity.dart';
import '../../l10n/app_localizations.dart';
import '../localization/music_affinity_text.dart';
import '../providers/core_providers.dart';
import 'common/vibra_avatar.dart';
import 'common/vibra_image.dart';
import 'common/vibra_surface.dart';
import 'musical_dna_widgets.dart' show DnaStrip;

/// Profile: complete musical identity (docs/profile-identity.md).

/// One colour per genre family, used everywhere a profile's "sound
/// signature" is drawn, so a profile is recognisable at a glance.
const familyColors = <String, Color>{
  'hip-hop': Color(0xFF8B5CF6),
  'rnb': Color(0xFFEC4899),
  'electronic': Color(0xFF22D3EE),
  'rock': Color(0xFFEF4444),
  'metal': Color(0xFF94A3B8),
  'punk': Color(0xFFA3E635),
  'pop': Color(0xFFF472B6),
  'jazz': Color(0xFFF59E0B),
  'blues': Color(0xFF3B82F6),
  'reggae': Color(0xFF22C55E),
  'latin': Color(0xFFF97316),
  'afro': Color(0xFFFACC15),
  'country': Color(0xFFB45309),
  'folk': Color(0xFF84CC16),
  'classical': Color(0xFFE5E7EB),
  'soundtrack': Color(0xFF14B8A6),
  'gospel': Color(0xFFFBBF24),
  'world': Color(0xFF10B981),
};

Color familyColor(String key) => familyColors[key] ?? const Color(0xFF6366F1);

String genreKeyLabel(AppLocalizations l10n, String key) =>
    GenreCatalog.subgenre(key)?.label ?? genreFamilyLabel(l10n, key);

/// The avatar ringed by its owner's Musical DNA: one arc per genre family,
/// sized by its share. Without a visible DNA, the VIBRA gradient.
class SoundSignatureAvatar extends StatelessWidget {
  const SoundSignatureAvatar({
    required this.name,
    this.imageUrl,
    this.dna,
    this.radius = 48,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final MusicalDna? dna;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final families = dna?.families ?? const <DnaFamily>[];
    final l10n = AppLocalizations.of(context)!;
    final size = (radius + 9) * 2;
    return Semantics(
      label: families.isEmpty
          ? name
          : l10n.profileSignatureSemantics(
              name,
              families
                  .take(3)
                  .map((f) => genreFamilyLabel(l10n, f.key))
                  .join(', '),
            ),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _SignaturePainter(
            families: families,
            fallback: t.primaryGradient,
            gap: t.backgroundPrimary,
          ),
          child: Center(
            child: VibraAvatar(imageUrl: imageUrl, name: name, radius: radius),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.families,
    required this.fallback,
    required this.gap,
  });
  final List<DnaFamily> families;
  final Gradient fallback;
  final Color gap;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    final total = families.fold<double>(0, (s, f) => s + f.share);
    if (families.isEmpty || total <= 0) {
      paint.shader = fallback.createShader(rect);
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }
    var start = -math.pi / 2;
    const gapAngle = 0.05;
    for (final f in families.take(8)) {
      final sweep = (f.share / total) * math.pi * 2;
      if (sweep <= gapAngle) {
        start += sweep;
        continue;
      }
      paint.color = familyColor(f.key);
      canvas.drawArc(rect, start, sweep - gapAngle, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.families != families || old.gap != gap;
}

/// Name, handle, bio, top genres and relation, around the signature.
class IdentityHero extends StatelessWidget {
  const IdentityHero({
    required this.name,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.dna,
    this.relation,
    this.memberSince,
    this.actions = const [],
    super.key,
  });

  final String name;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final MusicalDna? dna;

  /// 'connection' | 'match' | null.
  final String? relation;
  final DateTime? memberSince;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final top = dna?.families.take(3).toList() ?? const <DnaFamily>[];
    return Column(
      children: [
        SoundSignatureAvatar(
          name: name,
          imageUrl: avatarUrl,
          dna: dna,
          radius: 48,
        ),
        const SizedBox(height: VibraSpacing.md),
        Text(
          name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '@$username',
          style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
        ),
        if (relation == 'connection' || relation == 'match') ...[
          const SizedBox(height: VibraSpacing.xs),
          Chip(
            visualDensity: VisualDensity.compact,
            avatar: Icon(
              relation == 'connection'
                  ? Icons.people_alt_rounded
                  : Icons.graphic_eq_rounded,
              size: 16,
              color: t.accentPrimary,
            ),
            label: Text(
              relation == 'connection'
                  ? l10n.profileRelationConnection
                  : l10n.profileRelationMatch,
            ),
          ),
        ],
        if (top.isNotEmpty) ...[
          const SizedBox(height: VibraSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: VibraSpacing.sm,
            runSpacing: VibraSpacing.xs,
            children: [
              for (final f in top)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: familyColor(f.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${genreFamilyLabel(l10n, f.key)} ${f.percent}%',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
            ],
          ),
        ],
        if (bio != null && bio!.trim().isNotEmpty) ...[
          const SizedBox(height: VibraSpacing.md),
          Text(
            bio!.trim(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
        if (memberSince != null) ...[
          const SizedBox(height: VibraSpacing.xs),
          Text(
            l10n.profileMemberSince(
              DateFormat.yMMM(
                Localizations.localeOf(context).toString(),
              ).format(memberSince!),
            ),
            style: theme.textTheme.labelSmall?.copyWith(color: t.textMuted),
          ),
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: VibraSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: VibraSpacing.sm,
            runSpacing: VibraSpacing.sm,
            children: actions,
          ),
        ],
      ],
    );
  }
}

Future<void> _open(String? url) async {
  final uri = url == null ? null : Uri.tryParse(url);
  if (uri != null && uri.scheme == 'https') {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

String sectionTitle(AppLocalizations l10n, ProfileSection s) => switch (s) {
  ProfileSection.genres => l10n.profileSectionGenres,
  ProfileSection.artists => l10n.profileSectionArtists,
  ProfileSection.stats => l10n.profileSectionStats,
  ProfileSection.savedSongs => l10n.profileSectionSavedSongs,
  ProfileSection.playlists => l10n.profileSectionPlaylists,
  ProfileSection.events => l10n.profileSectionEvents,
  ProfileSection.communities => l10n.profileSectionCommunities,
  ProfileSection.circles => l10n.profileSectionCircles,
  ProfileSection.activity => l10n.profileSectionActivity,
};

IconData sectionIcon(ProfileSection s) => switch (s) {
  ProfileSection.genres => Icons.category_outlined,
  ProfileSection.artists => Icons.mic_external_on_rounded,
  ProfileSection.stats => Icons.insights_rounded,
  ProfileSection.savedSongs => Icons.library_music_outlined,
  ProfileSection.playlists => Icons.queue_music_rounded,
  ProfileSection.events => Icons.event_rounded,
  ProfileSection.communities => Icons.groups_2_outlined,
  ProfileSection.circles => Icons.bubble_chart_outlined,
  ProfileSection.activity => Icons.bolt_rounded,
};

IconData levelIcon(SectionLevel l) => switch (l) {
  SectionLevel.public => Icons.public_rounded,
  SectionLevel.connections => Icons.people_alt_outlined,
  SectionLevel.private => Icons.lock_outline_rounded,
};

String levelLabel(AppLocalizations l10n, SectionLevel l) => switch (l) {
  SectionLevel.public => l10n.profileLevelPublic,
  SectionLevel.connections => l10n.profileLevelConnections,
  SectionLevel.private => l10n.profileLevelPrivate,
};

/// Every section of a musical identity the viewer may see, in order.
class IdentitySections extends ConsumerWidget {
  const IdentitySections({
    required this.identity,
    this.exclude = const {},
    this.showDna = true,
    super.key,
  });

  final ProfileIdentity identity;

  /// Sections the surrounding screen already shows.
  final Set<ProfileSection> exclude;
  final bool showDna;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final id = identity;

    Widget card(ProfileSection s, Widget child, {VoidCallback? onAll}) =>
        _SectionCard(
          title: sectionTitle(l10n, s),
          icon: sectionIcon(s),
          // The owner sees who can see each section.
          level: id.isMe ? id.levelOf(s) : null,
          onAll: onAll,
          child: child,
        );
    Widget empty(String text) => Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
    );
    bool show(ProfileSection s) => !exclude.contains(s);

    final dna = id.dna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDna && dna != null)
          _SectionCard(
            title: l10n.musicalDnaProfileTile,
            icon: Icons.donut_large_rounded,
            onAll: () => context.push(
              '/musical-dna',
              extra: id.isMe
                  ? null
                  : {'userId': id.userId, 'displayName': id.name},
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DnaStrip(families: dna.families, height: 12),
                const SizedBox(height: VibraSpacing.sm),
                Wrap(
                  spacing: VibraSpacing.md,
                  runSpacing: VibraSpacing.xs,
                  children: [
                    for (final f in dna.families.take(5))
                      Text(
                        '${genreFamilyLabel(l10n, f.key)} ${f.percent}%',
                        style: theme.textTheme.labelMedium,
                      ),
                  ],
                ),
              ],
            ),
          ),
        if (show(ProfileSection.genres) && id.genres != null)
          card(
            ProfileSection.genres,
            id.genres!.isEmpty && (dna?.subgenres.isEmpty ?? true)
                ? empty(l10n.profileNoGenres)
                : Wrap(
                    spacing: VibraSpacing.xs,
                    runSpacing: VibraSpacing.xs,
                    children: [
                      for (final g in {
                        ...id.genres!,
                        ...?dna?.subgenres.take(6).map((s) => s.key),
                      }.take(12))
                        Chip(
                          visualDensity: VisualDensity.compact,
                          avatar: CircleAvatar(
                            radius: 5,
                            backgroundColor: familyColor(
                              GenreCatalog.subgenre(g)?.family ?? g,
                            ),
                          ),
                          label: Text(genreKeyLabel(l10n, g)),
                        ),
                    ],
                  ),
          ),
        if (show(ProfileSection.artists) && id.artists != null)
          card(
            ProfileSection.artists,
            id.artists!.isEmpty
                ? empty(l10n.profileNoArtists)
                : Wrap(
                    spacing: VibraSpacing.xs,
                    runSpacing: VibraSpacing.xs,
                    children: [
                      for (final (i, a) in id.artists!.indexed)
                        ActionChip(
                          avatar: Text(
                            '${i + 1}',
                            style: theme.textTheme.labelSmall,
                          ),
                          label: Text(a.name),
                          onPressed: a.id == null
                              ? null
                              : () => _open(
                                  'https://open.spotify.com/artist/${a.id}',
                                ),
                        ),
                    ],
                  ),
          ),
        if (show(ProfileSection.stats) && id.stats != null)
          card(ProfileSection.stats, _StatsGrid(stats: id.stats!)),
        if (show(ProfileSection.savedSongs) && id.savedSongs != null)
          card(
            ProfileSection.savedSongs,
            id.savedSongs!.isEmpty
                ? empty(l10n.discoveriesEmpty)
                : Column(
                    children: [
                      for (final s in id.savedSongs!.take(5))
                        _MediaRow(
                          imageUrl: s.artworkUrl,
                          icon: Icons.music_note_rounded,
                          title: s.title,
                          subtitle: s.artist,
                          onTap: () => _open(s.url),
                        ),
                    ],
                  ),
            onAll: id.isMe ? () => context.push('/discoveries') : null,
          ),
        if (show(ProfileSection.playlists) && id.playlists != null)
          card(
            ProfileSection.playlists,
            id.playlists!.isEmpty
                ? empty(l10n.profileNoPlaylists)
                : Column(
                    children: [
                      for (final p in id.playlists!)
                        _MediaRow(
                          imageUrl: p.artworkUrl,
                          icon: Icons.queue_music_rounded,
                          title: p.title,
                          subtitle: p.subtitle,
                          onTap: () =>
                              context.push('/feed-post', extra: p.postId),
                        ),
                    ],
                  ),
          ),
        if (show(ProfileSection.events) && id.events != null)
          card(
            ProfileSection.events,
            id.events!.isEmpty
                ? empty(l10n.profileNoEvents)
                : Column(
                    children: [
                      for (final e in id.events!.take(5))
                        _MediaRow(
                          imageUrl: e.imageUrl,
                          icon: Icons.event_rounded,
                          title: e.name,
                          subtitle: [
                            DateFormat.MMMEd(locale).format(e.date.toLocal()),
                            ?e.city,
                            switch (e.status) {
                              'going' => l10n.profileEventGoing,
                              'maybe' => l10n.profileEventMaybe,
                              _ => l10n.profileEventInterested,
                            },
                          ].join(' · '),
                          onTap: () async {
                            final event = await ref
                                .read(supabaseProfileIdentityDatasourceProvider)
                                .event(e.id);
                            if (event != null && context.mounted) {
                              context.push('/event-detail', extra: event);
                            }
                          },
                        ),
                    ],
                  ),
          ),
        if (show(ProfileSection.communities) && id.communities != null)
          card(
            ProfileSection.communities,
            id.communities!.isEmpty
                ? empty(l10n.profileNoCommunities)
                : Wrap(
                    spacing: VibraSpacing.xs,
                    runSpacing: VibraSpacing.xs,
                    children: [
                      for (final c in id.communities!)
                        ActionChip(
                          avatar: const Icon(Icons.groups_2_outlined, size: 16),
                          label: Text(c.name),
                          onPressed: () =>
                              context.push('/community', extra: c.id),
                        ),
                    ],
                  ),
          ),
        if (show(ProfileSection.circles) && id.circles != null)
          card(
            ProfileSection.circles,
            id.circles!.isEmpty
                ? empty(
                    id.isMe
                        ? l10n.profileNoCircles
                        : l10n.profileNoSharedCircles,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!id.isMe)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: VibraSpacing.xs,
                          ),
                          child: empty(l10n.profileSharedCirclesNote),
                        ),
                      Wrap(
                        spacing: VibraSpacing.xs,
                        runSpacing: VibraSpacing.xs,
                        children: [
                          for (final c in id.circles!)
                            ActionChip(
                              avatar: const Icon(
                                Icons.bubble_chart_outlined,
                                size: 16,
                              ),
                              label: Text(c.name),
                              onPressed: () =>
                                  context.push('/circle', extra: c.id),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        if (show(ProfileSection.activity) && id.activity != null)
          card(
            ProfileSection.activity,
            id.activity!.isEmpty
                ? empty(l10n.profileNoActivity)
                : Column(
                    children: [
                      for (final a in id.activity!.take(8))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(switch (a.type) {
                            'vibe' => Icons.graphic_eq_rounded,
                            'community' => Icons.groups_2_outlined,
                            _ => Icons.dynamic_feed_rounded,
                          }, color: t.accentPrimary),
                          title: Text(
                            switch (a.type) {
                              'vibe' => l10n.profileActivityVibe(a.title),
                              'community' => l10n.profileActivityJoined(
                                a.title,
                              ),
                              _ => l10n.profileActivityPosted(a.title),
                            },
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            DateFormat.yMMMd(locale).format(a.at.toLocal()),
                          ),
                          onTap: () => switch (a.type) {
                            'vibe' => context.push('/daily-vibe'),
                            'community' => context.push(
                              '/community',
                              extra: a.id,
                            ),
                            _ => context.push('/feed-post', extra: a.id),
                          },
                        ),
                    ],
                  ),
            onAll: () => context.push(
              '/user-posts',
              extra: {
                'userId': id.userId,
                if (!id.isMe) 'displayName': id.name,
              },
            ),
          ),
        if (!id.isMe && id.hidden.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: VibraSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: t.textMuted),
                const SizedBox(width: VibraSpacing.xs),
                Expanded(child: empty(l10n.profileSomePrivate)),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.level,
    this.onAll,
  });
  final String title;
  final IconData icon;
  final Widget child;
  final SectionLevel? level;
  final VoidCallback? onAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.md),
      child: VibraSurface(
        padding: const EdgeInsets.fromLTRB(
          VibraSpacing.lg,
          VibraSpacing.md,
          VibraSpacing.sm,
          VibraSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: t.accentPrimary),
                const SizedBox(width: VibraSpacing.sm),
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                if (level != null)
                  Tooltip(
                    message: levelLabel(l10n, level!),
                    child: InkResponse(
                      onTap: () => context.push('/profile-privacy'),
                      child: Padding(
                        padding: const EdgeInsets.all(VibraSpacing.xs),
                        child: Icon(
                          levelIcon(level!),
                          size: 18,
                          color: t.textMuted,
                          semanticLabel: levelLabel(l10n, level!),
                        ),
                      ),
                    ),
                  ),
                if (onAll != null)
                  TextButton(onPressed: onAll, child: Text(l10n.commonAll)),
              ],
            ),
            const SizedBox(height: VibraSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(right: VibraSpacing.sm),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaRow extends StatelessWidget {
  const _MediaRow({
    required this.title,
    required this.icon,
    this.subtitle,
    this.imageUrl,
    this.onTap,
  });
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    dense: true,
    onTap: onTap,
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(VibraSpacing.radiusSmall),
      child: SizedBox.square(
        dimension: 44,
        child: VibraNetworkImage(
          url: imageUrl,
          cacheWidth: 120,
          fallbackIcon: icon,
        ),
      ),
    ),
    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: subtitle == null || subtitle!.isEmpty
        ? null
        : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
  );
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final tiles = [
      (stats.followers, l10n.profileFollowers),
      (stats.following, l10n.profileFollowing),
      (stats.genres, l10n.profileStatGenres),
      if (stats.diversity != null)
        (stats.diversity!, l10n.profileStatDiversity),
      (stats.discoveries, l10n.profileStatDiscoveries),
      (stats.posts, l10n.profileStatPosts),
      (stats.communities, l10n.profileSectionCommunities),
      if (stats.concerts != null) (stats.concerts!, l10n.profileStatConcerts),
    ];
    return Wrap(
      spacing: VibraSpacing.sm,
      runSpacing: VibraSpacing.sm,
      children: [
        for (final (value, label) in tiles)
          Container(
            width: 96,
            padding: const EdgeInsets.all(VibraSpacing.sm),
            decoration: BoxDecoration(
              color: t.surfaceMuted,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
