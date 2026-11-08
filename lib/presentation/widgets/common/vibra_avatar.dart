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
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        textScaler: TextScaler.noScaling,
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
            padding: EdgeInsets.all(signalRing ? 2.5 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: signalRing ? t.primaryGradient : null,
              color: signalRing ? null : t.surfaceMuted,
            ),
            child: Container(
              padding: EdgeInsets.all(signalRing ? 2 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.backgroundPrimary,
              ),
              child: ClipOval(child: content),
            ),
          ),
          if (active)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: (radius * 0.5).clamp(10, 16),
                height: (radius * 0.5).clamp(10, 16),
                decoration: BoxDecoration(
                  color: t.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.backgroundPrimary, width: 2.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
