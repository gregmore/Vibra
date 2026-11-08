import 'dart:typed_data';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/env_config.dart';
import '../../core/services/private_media_url.dart';
import '../../core/theme/vibra_colors.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/music_story.dart';
import '../../l10n/app_localizations.dart';
import '../providers/core_providers.dart';
import '../providers/music_story_providers.dart';
import 'common/vibra_avatar.dart';
import 'common/vibra_image.dart';

/// Music Stories (docs/music-stories.md): shared story visuals.

/// The VIBRA story backgrounds: deep gradients that end in pure black.
LinearGradient storyGradient(String key) {
  const black = VibraPalette.ink950;
  final colors = switch (key) {
    'sunset' => const [Color(0xFFF97316), Color(0xFFDB2777), black],
    'ocean' => const [Color(0xFF0EA5E9), VibraPalette.indigoFill, black],
    'ember' => const [VibraPalette.error, Color(0xFF7C2D12), black],
    'mono' => const [VibraPalette.ink700, VibraPalette.ink900, black],
    _ => const [VibraPalette.violet, VibraPalette.indigoFill, black],
  };
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: colors,
    stops: const [0, 0.55, 1],
  );
}

String storyKindLabel(AppLocalizations l10n, StoryKind kind) => switch (kind) {
  StoryKind.nowPlaying => l10n.storyKindNowPlaying,
  StoryKind.artist => l10n.storyKindArtist,
  StoryKind.album => l10n.storyKindAlbum,
  StoryKind.playlist => l10n.storyKindPlaylist,
  StoryKind.concertPhoto => l10n.storyKindConcertPhoto,
  StoryKind.opinion => l10n.storyKindOpinion,
};

IconData storyKindIcon(StoryKind kind) => switch (kind) {
  StoryKind.nowPlaying => Icons.graphic_eq_rounded,
  StoryKind.artist => Icons.mic_external_on_rounded,
  StoryKind.album => Icons.album_rounded,
  StoryKind.playlist => Icons.queue_music_rounded,
  StoryKind.concertPhoto => Icons.photo_camera_rounded,
  StoryKind.opinion => Icons.format_quote_rounded,
};

/// Opens the item on its provider. Vibra never plays or hosts audio.
Future<void> openStoryItem(StoryItem item) async {
  final uri = Uri.tryParse(item.externalUrl);
  if (uri != null && uri.scheme == 'https') {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// The photo of a concert story, read with the viewer's session while the
/// story is visible to them (story-media is private).
class StoryPhoto extends StatelessWidget {
  const StoryPhoto({
    required this.path,
    this.bytes,
    this.bucket = 'story-media',
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? path;

  /// 'story-media' or 'feed-media'.
  final String bucket;
  final BoxFit fit;

  /// Local preview while composing.
  final List<int>? bytes;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final fallback = ColoredBox(
      color: t.surfaceMuted,
      child: Center(
        child: Icon(Icons.photo_camera_rounded, color: t.textMuted, size: 48),
      ),
    );
    if (bytes != null) {
      return Image.memory(
        Uint8List.fromList(bytes!),
        fit: fit,
        cacheWidth: 1080,
      );
    }
    final uri = storyMediaUri(path, EnvConfig.supabaseUrl, bucket: bucket);
    String? token;
    try {
      token = Supabase.instance.client.auth.currentSession?.accessToken;
    } catch (_) {
      token = null;
    }
    if (uri == null || token == null) return fallback;
    return Image.network(
      uri.toString(),
      headers: {
        'Authorization': 'Bearer $token',
        'apikey': EnvConfig.supabaseAnonKey,
      },
      fit: fit,
      cacheWidth: 1080,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : ColoredBox(color: t.surfaceMuted),
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// The story itself, at any size (full screen in the viewer, a 9:16
/// preview in the composer). Text is white on dark scrims in both themes:
/// stories are always dark.
class StoryCanvas extends StatelessWidget {
  const StoryCanvas({
    required this.kind,
    this.item,
    this.body,
    this.background = 'aurora',
    this.mediaPath,
    this.photoBytes,
    this.eventName,
    this.compact = false,
    this.showAction = true,
    this.onOpenItem,
    super.key,
  });

  final StoryKind kind;
  final StoryItem? item;
  final String? body;
  final String background;
  final String? mediaPath;
  final List<int>? photoBytes;
  final String? eventName;

  /// Composer preview: smaller type, no buttons.
  final bool compact;

  /// The "Listen on Spotify" button; the viewer draws it above its tap zones.
  final bool showAction;
  final VoidCallback? onOpenItem;

  factory StoryCanvas.of(
    MusicStory s, {
    VoidCallback? onOpenItem,
    bool showAction = true,
    Key? key,
  }) => StoryCanvas(
    key: key,
    showAction: showAction,
    kind: s.kind,
    item: s.item,
    body: s.body,
    background: s.background,
    mediaPath: s.mediaPath,
    eventName: s.eventName,
    onOpenItem: onOpenItem,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const white = VibraPalette.textOnDark;
    final scale = compact ? 0.55 : 1.0;
    final label = _Label(
      icon: storyKindIcon(kind),
      text: storyKindLabel(l10n, kind),
      compact: compact,
    );

    if (kind == StoryKind.concertPhoto) {
      return Stack(
        fit: StackFit.expand,
        children: [
          StoryPhoto(path: mediaPath, bytes: photoBytes),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0x00000000),
                  Color(0xCC000000),
                ],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          Positioned(
            left: VibraSpacing.lg * scale,
            right: VibraSpacing.lg * scale,
            bottom: (compact ? VibraSpacing.lg : 140) * scale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label,
                if (eventName != null) ...[
                  SizedBox(height: VibraSpacing.sm * scale),
                  Text(
                    eventName!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: white,
                      fontSize: 22 * scale,
                    ),
                  ),
                ],
                if (body != null) ...[
                  SizedBox(height: VibraSpacing.xs * scale),
                  Text(
                    body!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: white,
                      fontSize: 16 * scale,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    if (kind == StoryKind.opinion) {
      return DecoratedBox(
        decoration: BoxDecoration(gradient: storyGradient(background)),
        child: Padding(
          padding: EdgeInsets.all(VibraSpacing.xxl * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              label,
              SizedBox(height: VibraSpacing.lg * scale),
              Icon(
                Icons.format_quote_rounded,
                color: white.withValues(alpha: 0.5),
                size: 48 * scale,
              ),
              Text(
                body ?? '',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: white,
                  fontSize: (((body?.length ?? 0) > 140) ? 24 : 30) * scale,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Music items: blurred provider artwork behind a large cover.
    final it = item;
    final round = kind == StoryKind.artist;
    final cover = 240.0 * scale;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: storyGradient(background)),
        ),
        if (it?.artworkUrl != null)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Opacity(
              opacity: 0.55,
              child: VibraNetworkImage(url: it!.artworkUrl, cacheWidth: 200),
            ),
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x66000000), Color(0xE6000000)],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: VibraSpacing.xxl * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              label,
              SizedBox(height: VibraSpacing.xl * scale),
              Container(
                width: cover,
                height: cover,
                decoration: BoxDecoration(
                  shape: round ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: round
                      ? null
                      : BorderRadius.circular(VibraSpacing.radiusMedium),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x80000000),
                      blurRadius: 32,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: VibraNetworkImage(
                  url: it?.artworkUrl,
                  cacheWidth: 600,
                  fallbackIcon: storyKindIcon(kind),
                ),
              ),
              SizedBox(height: VibraSpacing.xl * scale),
              Text(
                it?.title ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: white,
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (it?.subtitle != null)
                Text(
                  it!.subtitle!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: VibraPalette.textOnDarkSecondary,
                    fontSize: 16 * scale,
                  ),
                ),
              if (body != null) ...[
                SizedBox(height: VibraSpacing.lg * scale),
                Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: white,
                    fontSize: 16 * scale,
                  ),
                ),
              ],
              if (!compact && showAction && it != null) ...[
                const SizedBox(height: VibraSpacing.xl),
                StoryItemAction(item: it, onOpen: onOpenItem),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Opens the item on its provider, with the attribution the provider requires.
class StoryItemAction extends StatelessWidget {
  const StoryItemAction({required this.item, this.onOpen, super.key});
  final StoryItem item;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          onPressed: onOpen ?? () => openStoryItem(item),
          style: FilledButton.styleFrom(
            backgroundColor: item.isSpotify
                ? VibraPalette.spotifyGreen
                : VibraPalette.white,
            foregroundColor: item.isSpotify
                ? VibraPalette.onSpotifyGreen
                : VibraPalette.textOnLight,
          ),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: Text(item.isSpotify ? l10n.vibeListen : l10n.vibeOpen),
        ),
        if (item.isSpotify) ...[
          const SizedBox(height: VibraSpacing.xs),
          Text(
            l10n.storyAttribution,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: VibraPalette.textOnDarkSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text, required this.compact});
  final IconData icon;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = compact ? 0.7 : 1.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: VibraSpacing.md * s,
        vertical: VibraSpacing.xs * s,
      ),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14 * s, color: VibraPalette.textOnDark),
          SizedBox(width: VibraSpacing.xs * s),
          Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: VibraPalette.textOnDark,
              letterSpacing: 1.1,
              fontSize: 11 * s,
            ),
          ),
        ],
      ),
    );
  }
}

/// An avatar with the story ring: the VIBRA gradient while unseen, a quiet
/// border once seen.
class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    required this.name,
    this.imageUrl,
    this.unseen = true,
    this.radius = 30,
    this.add = false,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final bool unseen;
  final double radius;

  /// Shows a "+" badge (your own bubble).
  final bool add;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: unseen ? t.primaryGradient : null,
            border: unseen
                ? null
                : Border.all(color: t.borderDefault, width: 1.5),
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.backgroundPrimary,
            ),
            child: VibraAvatar(imageUrl: imageUrl, name: name, radius: radius),
          ),
        ),
        if (add)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.accentFill,
                border: Border.all(color: t.backgroundPrimary, width: 2),
              ),
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.add_rounded, size: 16, color: t.onAccent),
            ),
          ),
      ],
    );
  }
}

/// The horizontal row of stories (Home). Your bubble first: tap to add a
/// story, or to watch yours.
class StoryRing extends ConsumerWidget {
  const StoryRing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final me = ref.read(supabaseMusicStoriesDatasourceProvider).currentUserId;
    final ring = ref.watch(storyRingProvider).valueOrNull ?? const [];
    final mine = ring.where((e) => e.userId == me).firstOrNull;
    final others = ring.where((e) => e.userId != me).toList();
    final order = [?mine?.userId, ...others.map((e) => e.userId)];

    Widget bubble({
      required String label,
      required Widget avatar,
      required VoidCallback onTap,
      VoidCallback? onLongPress,
    }) => Padding(
      padding: const EdgeInsets.only(right: VibraSpacing.md),
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
          onTap: onTap,
          onLongPress: onLongPress,
          child: SizedBox(
            width: 72,
            child: Column(
              children: [
                avatar,
                const SizedBox(height: VibraSpacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: t.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: VibraSpacing.pagePadding,
        ),
        children: [
          bubble(
            label: mine == null ? l10n.storyAdd : l10n.storyYours,
            avatar: StoryAvatar(
              name: l10n.storyYours,
              imageUrl: mine?.avatarUrl,
              unseen: mine != null,
              add: true,
            ),
            onTap: () => mine == null
                ? context.push('/story-composer')
                : context.push('/stories', extra: (order, 0)),
            onLongPress: () => context.push('/story-composer'),
          ),
          for (final (i, e) in others.indexed)
            bubble(
              label: e.name,
              avatar: StoryAvatar(
                name: e.name,
                imageUrl: e.avatarUrl,
                unseen: !e.allSeen,
              ),
              onTap: () => context.push(
                '/stories',
                extra: (order, i + (mine == null ? 0 : 1)),
              ),
            ),
        ],
      ),
    );
  }
}

/// MUSIC STORIES (docs/music-stories.md): one story as a 9:16 thumbnail,
/// the real canvas scaled down (no separate preview to fall out of sync),
/// with how long ago it was posted and a ring while it is unseen.
class MusicStoryCard extends StatelessWidget {
  const MusicStoryCard({
    required this.story,
    this.onTap,
    this.width = 108,
    super.key,
  });

  final MusicStory story;
  final VoidCallback? onTap;
  final double width;

  /// The canvas is laid out at phone size, then scaled to [width].
  static const _designSize = Size(360, 640);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final hours = DateTime.now().difference(story.createdAt).inHours;
    final radius = BorderRadius.circular(VibraSpacing.radiusMedium);
    return Semantics(
      button: onTap != null,
      label: l10n.storyCardSemantics(
        story.name,
        storyKindLabel(l10n, story.kind),
        hours,
      ),
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Material(
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: story.seen ? t.borderDefault : t.accentPrimary,
                width: story.seen ? 1 : 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  IgnorePointer(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox.fromSize(
                        size: _designSize,
                        child: StoryCanvas.of(story, showAction: false),
                      ),
                    ),
                  ),
                  Positioned(
                    left: VibraSpacing.xs,
                    bottom: VibraSpacing.xs,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          l10n.storyHoursAgo(hours),
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A person's active stories on their profile, newest first. Hidden when
/// there are none or they are not visible to me (the server decides).
class UserStoriesStrip extends ConsumerWidget {
  const UserStoriesStrip({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(userStoriesProvider(userId)).valueOrNull;
    if (stories == null || stories.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileStories,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: VibraSpacing.sm),
        SizedBox(
          height: 108 * 16 / 9,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            separatorBuilder: (_, _) => const SizedBox(width: VibraSpacing.sm),
            itemBuilder: (context, i) => MusicStoryCard(
              story: stories[i],
              onTap: () => context.push('/stories', extra: ([userId], 0)),
            ),
          ),
        ),
      ],
    );
  }
}
