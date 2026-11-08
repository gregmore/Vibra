/// VIBRA AI (docs/vibra-ai.md): the optional music assistant.
/// Verified items are facts a tool returned (Spotify, VIBRA events and
/// communities, Musical DNA, the genre catalogue); the answer text, notes
/// and ideas are generated and always shown as such.
class AiStatus {
  const AiStatus({required this.available, required this.consent});
  final bool available;
  final bool consent;
}

enum AiItemKind { artist, album, track, event, community, genre }

class AiVerifiedItem {
  const AiVerifiedItem({
    required this.ref,
    required this.kind,
    required this.title,
    required this.source,
    this.subtitle,
    this.url,
    this.imageUrl,
    this.date,
    this.note,
  });

  final String ref;
  final AiItemKind kind;
  final String title;
  final String? subtitle;
  final String? url;
  final String? imageUrl;
  final DateTime? date;

  /// 'spotify' | 'vibra_events' | 'vibra_communities' | 'musical_dna' |
  /// 'genre_catalog'.
  final String source;

  /// Generated: why it is relevant.
  final String? note;

  /// The VIBRA id after "event:" / "community:".
  String? get localId {
    final i = ref.indexOf(':');
    return i < 0 ? null : ref.substring(i + 1);
  }

  static AiVerifiedItem? fromJson(Object? raw) {
    if (raw is! Map || raw['ref'] is! String || raw['title'] is! String) {
      return null;
    }
    final kind = AiItemKind.values
        .where((k) => k.name == raw['kind'])
        .firstOrNull;
    if (kind == null) return null;
    final url = raw['url'] as String?;
    final image = raw['image_url'] as String?;
    return AiVerifiedItem(
      ref: raw['ref'] as String,
      kind: kind,
      title: raw['title'] as String,
      subtitle: raw['subtitle'] as String?,
      // Only https links are opened.
      url: url != null && url.startsWith('https://') ? url : null,
      imageUrl: image != null && image.startsWith('https://') ? image : null,
      date: DateTime.tryParse('${raw['date']}'),
      source: raw['source']?.toString() ?? 'spotify',
      note: raw['note'] as String?,
    );
  }
}

class AiIdea {
  const AiIdea({required this.title, required this.kind, this.note});
  final String title;

  /// 'genre' | 'listening_tip' | 'other'.
  final String kind;
  final String? note;
}

class AiAnswer {
  const AiAnswer({
    required this.text,
    this.verified = const [],
    this.ideas = const [],
    this.status = 'ok',
  });

  final String text;
  final List<AiVerifiedItem> verified;
  final List<AiIdea> ideas;

  /// 'ok' | 'refused' | 'incomplete'.
  final String status;

  static AiAnswer fromJson(Map<String, dynamic> r) => AiAnswer(
    text: r['answer']?.toString() ?? '',
    verified: [
      for (final v in (r['verified'] as List? ?? const []))
        ?AiVerifiedItem.fromJson(v),
    ],
    ideas: [
      for (final i in (r['ideas'] as List? ?? const []))
        if (i is Map && i['title'] is String)
          AiIdea(
            title: i['title'] as String,
            kind: i['kind']?.toString() ?? 'other',
            note: i['note'] as String?,
          ),
    ],
    status: r['status']?.toString() ?? 'ok',
  );
}

/// One message in the on-device conversation.
class AiMessage {
  const AiMessage.user(this.text) : fromUser = true, answer = null;
  AiMessage.assistant(AiAnswer this.answer)
    : fromUser = false,
      text = answer.text;

  final bool fromUser;
  final String text;
  final AiAnswer? answer;
}
