import '../../core/music/genre_catalog.dart';
import '../../domain/entities/music_affinity.dart';
import '../../l10n/app_localizations.dart';

/// Localized family name ("Elettronica"); unknown keys fall back to the key.
String genreFamilyLabel(AppLocalizations l10n, String key) => switch (key) {
  'hip-hop' => l10n.genreFamilyHipHop,
  'rnb' => l10n.genreFamilyRnb,
  'electronic' => l10n.genreFamilyElectronic,
  'rock' => l10n.genreFamilyRock,
  'metal' => l10n.genreFamilyMetal,
  'punk' => l10n.genreFamilyPunk,
  'pop' => l10n.genreFamilyPop,
  'jazz' => l10n.genreFamilyJazz,
  'blues' => l10n.genreFamilyBlues,
  'reggae' => l10n.genreFamilyReggae,
  'latin' => l10n.genreFamilyLatin,
  'afro' => l10n.genreFamilyAfro,
  'country' => l10n.genreFamilyCountry,
  'folk' => l10n.genreFamilyFolk,
  'classical' => l10n.genreFamilyClassical,
  'soundtrack' => l10n.genreFamilySoundtrack,
  'gospel' => l10n.genreFamilyGospel,
  'world' => l10n.genreFamilyWorld,
  _ => key,
};

/// Any catalogue key: a family's generic entry uses the localized family
/// name, specific subgenres keep their proper name ("Trap", "Neo Soul").
String genreLabel(AppLocalizations l10n, String key) {
  final sub = GenreCatalog.subgenre(key);
  if (sub == null) return genreFamilyLabel(l10n, key);
  return sub.isGeneric ? genreFamilyLabel(l10n, key) : sub.label;
}

String affinityCategoryLabel(AppLocalizations l10n, AffinityCategory c) =>
    switch (c) {
      AffinityCategory.exceptional => l10n.affinityCategoryExceptional,
      AffinityCategory.veryHigh => l10n.affinityCategoryVeryHigh,
      AffinityCategory.high => l10n.affinityCategoryHigh,
      AffinityCategory.moderate => l10n.affinityCategoryModerate,
      AffinityCategory.low => l10n.affinityCategoryLow,
      AffinityCategory.veryLow => l10n.affinityCategoryVeryLow,
    };

String affinityQuote(AppLocalizations l10n, AffinityCategory c) => switch (c) {
  AffinityCategory.exceptional => l10n.affinityQuoteExceptional,
  AffinityCategory.veryHigh => l10n.affinityQuoteVeryHigh,
  AffinityCategory.high => l10n.affinityQuoteHigh,
  AffinityCategory.moderate => l10n.affinityQuoteModerate,
  AffinityCategory.low ||
  AffinityCategory.veryLow => l10n.affinityQuoteDiscovery,
};

/// "A, B and C" in the current language.
String joinGenres(AppLocalizations l10n, List<String> items) {
  if (items.isEmpty) return '';
  if (items.length == 1) return items.first;
  return '${items.sublist(0, items.length - 1).join(', ')}'
      '${l10n.affinityListSeparator}${items.last}';
}

/// One sentence per server reason. Every name comes from the reason itself.
String affinityReasonText(
  AppLocalizations l10n,
  AffinityReason reason,
) => switch (reason) {
  SharedFamiliesReason(:final families) => l10n.affinityReasonSharedFamilies(
    joinGenres(l10n, [for (final f in families) genreFamilyLabel(l10n, f)]),
  ),
  SharedSubgenresReason(:final subgenres) => l10n.affinityReasonSharedSubgenres(
    joinGenres(l10n, [for (final s in subgenres) genreLabel(l10n, s)]),
  ),
  DifferentSubgenresReason(:final family) =>
    l10n.affinityReasonDifferentSubgenres(genreFamilyLabel(l10n, family)),
  RelatedFamiliesReason(:final first, :final second) =>
    l10n.affinityReasonRelatedFamilies(
      genreFamilyLabel(l10n, first),
      genreFamilyLabel(l10n, second),
    ),
  SharedArtistsReason(:final count) => l10n.affinityReasonSharedArtists(count),
  CommonGroundReason(:final families) => l10n.affinityReasonCommonGround(
    joinGenres(l10n, [for (final f in families) genreFamilyLabel(l10n, f)]),
  ),
  DiversityReason(:final pattern) => switch (pattern) {
    DiversityPattern.bothEclectic => l10n.affinityReasonBothEclectic,
    DiversityPattern.bothFocused => l10n.affinityReasonBothFocused,
    DiversityPattern.contrast => l10n.affinityReasonDiversityContrast,
  },
  DiscoveryReason() => l10n.affinityReasonDiscovery,
};
