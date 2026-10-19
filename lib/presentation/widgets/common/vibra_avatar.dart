import 'package:vibra/l10n/app_localizations.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// Avatar a tinta unica: l'identità viene dalla persona, non da colori casuali.
class VibraAvatar extends StatelessWidget {
  const VibraAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.active = false,
    this.signalRing = false,
  });

  final String? imageUrl;
  final String? name;
  final double radius;
  final bool active;
  final bool signalRing;

  String get _initials {
    final safeName = name?.trim() ?? '';
    if (safeName.isEmpty) return 'V';
    final words = safeName.split(RegExp(r'\s+'));
    if (words.length > 1) {
      return '${words.first[0]}${words[1][0]}'.toUpperCase();
    }
    return safeName.substring(0, safeName.length > 1 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final imageIsNetwork =
        hasImage &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));
    final diameter = radius * 2;
    final cacheWidth = (diameter * MediaQuery.devicePixelRatioOf(context))
        .ceil();

    Widget fallback() => Container(
      decoration: BoxDecoration(gradient: t.avatarGradient),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: VibraTextStyles.titleMedium.copyWith(
          color: t.onAccent,
          fontSize: radius * 0.62,
        ),
      ),
    );

    Widget content;
    if (!hasImage) {
      content = fallback();
    } else if (imageIsNetwork) {
      content = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        memCacheWidth: cacheWidth,
        placeholder: (_, _) => fallback(),
        errorWidget: (_, _, _) => fallback(),
      );
    } else {
      content = Image.file(
        File(imageUrl!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    }

    return Semantics(
      image: true,
      label: name ?? AppLocalizations.of(context)!.commonAvatar,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: diameter,
            height: diameter,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: signalRing ? t.accentPrimary : t.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: signalRing ? t.accentPrimary : t.borderDefault,
              ),
            ),
            child: ClipOval(child: content),
          ),
          if (active)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: radius * 0.42,
                height: radius * 0.42,
                decoration: BoxDecoration(
                  color: t.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
