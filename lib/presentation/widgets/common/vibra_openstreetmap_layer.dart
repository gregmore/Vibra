import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/theme/vibra_theme_tokens.dart';

/// OpenStreetMap's standard raster layer with a local, theme-aware treatment.
///
/// The source remains identical in both modes. Dark mode only transforms the
/// rendered pixels; it does not request tiles from an unverified third party.
class VibraOpenStreetMapTileLayer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TileLayer(
      urlTemplate: context.vibraTokens.mapTileUrl,
      userAgentPackageName: 'app.vibra.mobile',
      tileBuilder: isDark
          ? (context, tile, tileImage) =>
                ColorFiltered(colorFilter: _darkMapFilter, child: tile)
          : null,
    );
  }
}
