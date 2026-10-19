import 'package:vibra/l10n/app_localizations.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_theme_tokens.dart';

/// Legacy-compatible avatar with an AA-safe initials fallback and score ring.
class VibraNeonAvatar extends StatelessWidget {
  const VibraNeonAvatar({
    super.key,
    required this.imageUrl,
    this.imageFile,
    this.radius = 30,
    this.score = 1,
    this.displayName,
    this.onTap,
    this.isOnline = false,
  });

  final String imageUrl;
  final File? imageFile;
  final double radius;
  final double score;
  final String? displayName;
  final VoidCallback? onTap;
  final bool isOnline;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'V';
    if (parts.length > 1) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first
        .substring(0, parts.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  Widget _fallback(BuildContext context, double innerRadius) {
    final t = context.vibraTokens;
    final safeName = displayName?.trim() ?? '';
    if (safeName.isEmpty) {
      return ColoredBox(
        color: t.surfaceMuted,
        child: Icon(Icons.person_rounded, color: t.textSecondary, size: radius),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(gradient: t.avatarGradient),
      child: Center(
        child: Text(
          _initials(safeName),
          style: VibraTextStyles.titleMedium.copyWith(
            color: t.onAccent,
            fontSize: innerRadius * .8,
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, double innerRadius) {
    final t = context.vibraTokens;
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _fallback(context, innerRadius),
      );
    }
    if (imageUrl.isEmpty) return _fallback(context, innerRadius);
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      final cacheWidth = (radius * 2 * MediaQuery.devicePixelRatioOf(context))
          .ceil();
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        memCacheWidth: cacheWidth,
        placeholder: (_, _) => ColoredBox(color: t.surfaceMuted),
        errorWidget: (_, _, _) => _fallback(context, innerRadius),
      );
    }
    return Image.file(
      File(imageUrl),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => _fallback(context, innerRadius),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final ringColor = t.matchColor(score);
    final innerRadius = radius - 2;
    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: 2),
          ),
          child: ClipOval(child: _content(context, innerRadius)),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * .5,
              height: radius * .5,
              decoration: BoxDecoration(
                color: t.success,
                shape: BoxShape.circle,
                border: Border.all(color: t.surface, width: 2),
              ),
            ),
          ),
      ],
    );

    return Semantics(
      image: true,
      button: onTap != null,
      label: [
        AppLocalizations.of(context)!.commonAvatarAffinity(
          displayName ?? AppLocalizations.of(context)!.commonAvatar,
          (score * 100).round(),
        ),
        if (isOnline) AppLocalizations.of(context)!.commonOnline,
      ].join(', '),
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onTap,
          radius: radius,
          splashColor: t.accentPrimary.withValues(alpha: .16),
          hoverColor: t.accentPrimary.withValues(alpha: .08),
          focusColor: t.accentPrimary.withValues(alpha: .12),
          child: avatar,
        ),
      ),
    );
  }
}
