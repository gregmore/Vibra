import 'package:vibra/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/app_user.dart';
import '../common/vibra_avatar.dart';

/// Compatibility wrapper around the single, contrast-verified avatar system.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.avatarUrl, this.name, this.radius = 24});

  factory UserAvatar.fromUser(AppUser? user, {double radius = 24}) {
    return UserAvatar(
      avatarUrl: user?.avatarUrl,
      name: user?.displayName ?? user?.username,
      radius: radius,
    );
  }

  final String? avatarUrl;
  final String? name;
  final double radius;

  @override
  Widget build(BuildContext context) => VibraAvatar(
    imageUrl: avatarUrl,
    name: name ?? AppLocalizations.of(context)!.userGeneric,
    radius: radius,
  );
}
