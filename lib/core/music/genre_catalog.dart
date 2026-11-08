/// Genre catalogue shared with the server engine
/// (supabase/functions/_shared/genre_catalog.json). The data lives in the
/// generated part file; regenerate with
/// `python3 -I script/music/build_genre_catalog.py`.
library;

part 'genre_catalog.g.dart';

class GenreFamilyInfo {
  const GenreFamilyInfo({required this.key, required this.label});

  final String key;

  /// English canonical name; the UI localizes families via l10n.
  final String label;
}

class SubgenreInfo {
  const SubgenreInfo({
    required this.key,
    required this.family,
    required this.label,
  });

  final String key;
  final String family;

  /// Proper genre name ("Trap", "Neo Soul"), shown as is in every language.
  final String label;

  /// The family's own entry ("Hip-Hop" inside Hip-Hop).
  bool get isGeneric => key == family;
}

abstract final class GenreCatalog {
  static int get version => _catalogVersion;
  static List<GenreFamilyInfo> get families => _families;
  static List<SubgenreInfo> get subgenres => _subgenres;

  static final Map<String, SubgenreInfo> _byKey = {
    for (final sub in _subgenres) sub.key: sub,
  };

  static SubgenreInfo? subgenre(String key) => _byKey[key];
  static bool isKnown(String key) => _byKey.containsKey(key);

  /// Subgenres of one family, the generic entry first.
  static List<SubgenreInfo> subgenresOf(String family) =>
      _subgenres.where((s) => s.family == family).toList(growable: false);

  /// Case/accent-insensitive search on subgenre names and family labels.
  static List<SubgenreInfo> search(
    String query, {
    String Function(String familyKey)? familyLabel,
  }) {
    final q = _fold(query);
    if (q.isEmpty) return const [];
    return _subgenres
        .where((s) {
          final family = familyLabel?.call(s.family) ?? s.family;
          return _fold(s.label).contains(q) || _fold(family).contains(q);
        })
        .toList(growable: false);
  }

  static String _fold(String value) {
    const from = 'àáâäèéêëìíîïòóôöùúûüçñ';
    const to = 'aaaaeeeeiiiioooouuuucn';
    final lower = value.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final index = from.indexOf(char);
      buffer.write(index >= 0 ? to[index] : char);
    }
    return buffer.toString().replaceAll(RegExp(r'[^a-z0-9&]+'), ' ').trim();
  }
}
