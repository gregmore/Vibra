import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/concert_match.dart';
import '../../l10n/app_localizations.dart';
import 'common/vibra_avatar.dart';
import 'whos_going_section.dart';

/// CONCERT MATCH (docs/concert-match.md): one person going to, or a fan of,
/// the same concert. Messaging appears only after an accepted connection;
/// otherwise the card offers a Vibra (a connection request).
class ConcertMatchCard extends StatelessWidget {
  const ConcertMatchCard({
    required this.person,
    required this.eventLabel,
    required this.onSendVibra,
    this.selected,
    this.onSelected,
    this.requested = false,
    super.key,
  });

  final ConcertMatchPerson person;

  /// The artist or event name, for "fan of …".
  final String eventLabel;

  /// Non-null when the person can be invited to a concert group: shows a
  /// checkbox in that state.
  final bool? selected;
  final ValueChanged<bool>? onSelected;

  /// A Vibra was already sent from this screen.
  final bool requested;
  final VoidCallback onSendVibra;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final p = person;
    final reason = [
      if (p.status != null) attendanceStatusLabel(l10n, p.status!),
      if (p.status == null && p.artistFan) l10n.concertMatchFan(eventLabel),
      if (p.compatibility != null) l10n.whosGoingAffinity(p.compatibility!),
    ].join(' · ');
    final connected = p.connection == 'accepted';
    final pending = p.connection == 'pending' || requested;
    final avatar = VibraAvatar(imageUrl: p.avatarUrl, name: p.name);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => context.push('/user-profile', extra: p.userId),
      leading: selected == null
          ? avatar
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (v) => onSelected?.call(v == true),
                ),
                avatar,
              ],
            ),
      title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        reason,
        style: TextStyle(
          color: p.status == 'going' ? t.accentPrimary : t.textSecondary,
        ),
      ),
      trailing: connected
          // Conversation only after the connection was accepted.
          ? IconButton(
              tooltip: l10n.socialMessageAction,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              onPressed: () => context.push(
                '/chat',
                extra: <String, dynamic>{
                  'otherUserId': p.userId,
                  'otherDisplayName': p.name,
                },
              ),
            )
          : pending
          ? Text(l10n.whosGoingRequested, style: TextStyle(color: t.textMuted))
          : TextButton(
              onPressed: onSendVibra,
              child: Text(l10n.socialMatchSendVibra),
            ),
    );
  }
}
