import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';

/// OpenStreetMap's standard raster layer with a local, theme-aware treatment.
///
/// The source remains identical in both modes. Dark mode only transforms the
/// rendered pixels; it does not request tiles from an unverified third party.
final openStreetMapTileProvider = Provider<TileProvider>((ref) {
  final provider = _CachedMapTileProvider();
  ref.onDispose(provider.dispose);
  return provider;
});

class _CachedMapTileProvider extends TileProvider {
  _CachedMapTileProvider()
    : super(
        headers: {
          'User-Agent':
              'Vibra/${AppConstants.appVersion} (${AppConstants.androidPackageName}; +${AppConstants.supportUrl})',
        },
      );
  static final _cache = CacheManager(
    Config(
      'vibra_openstreetmap_tiles',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 1000,
    ),
  );

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      CachedNetworkImageProvider(
        getTileUrl(coordinates, options),
        headers: headers,
        cacheManager: _cache,
      );
}

class VibraOpenStreetMapTileLayer extends ConsumerWidget {
  const VibraOpenStreetMapTileLayer({super.key});

  static const _darkMapFilter = ColorFilter.matrix(<double>[
    -0.65,
    0,
    0,
    0,
    210,
    0,
    -0.65,
    0,
    0,
    200,
    0,
    0,
    -0.65,
    0,
    220,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TileLayer(
      urlTemplate: context.vibraTokens.mapTileUrl,
      userAgentPackageName: 'com.vibra.app',
      tileProvider: ref.watch(openStreetMapTileProvider),
      tileBuilder: isDark
          ? (context, tile, tileImage) =>
                ColorFiltered(colorFilter: _darkMapFilter, child: tile)
          : null,
    );
  }
}

/// Always visible and linked to the source licence, including on preview maps.
class VibraOpenStreetMapAttribution extends StatelessWidget {
  const VibraOpenStreetMapAttribution({super.key});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomRight,
    child: Material(
      color: context.vibraTokens.surfaceElevated,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: context.vibraTokens.textPrimary,
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 11),
        ),
        onPressed: () async {
          try {
            final opened = await launchUrl(
              Uri.https('www.openstreetmap.org', '/copyright'),
              mode: LaunchMode.externalApplication,
            );
            if (!opened && context.mounted) _showError(context);
          } catch (_) {
            if (context.mounted) _showError(context);
          }
        },
        child: const Text('© OpenStreetMap'),
      ),
    ),
  );

  void _showError(BuildContext context) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.commonLinkOpenError),
      ),
    );
  }
}
