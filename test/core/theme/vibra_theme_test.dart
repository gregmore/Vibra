import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/core/theme/vibra_theme_tokens.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';

void main() {
  test('light and dark themes expose their own semantic token values', () {
    const light = VibraThemeTokens.light;
    const dark = VibraThemeTokens.dark;

    expect(light.backgroundPrimary, const Color(0xFFFAF9FC));
    expect(dark.backgroundPrimary, const Color(0xFF0D0A14));
    expect(light.surfaceElevated, isNot(dark.surfaceElevated));
    expect(light.mapTileUrl, 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
    expect(dark.mapTileUrl, light.mapTileUrl);
    expect(light.cardShadow.color.a, greaterThan(0));
  });

  test('theme choices map to Flutter theme modes', () {
    expect(themeModeForPreference(VibraThemePreference.light), ThemeMode.light);
    expect(themeModeForPreference(VibraThemePreference.dark), ThemeMode.dark);
    expect(
      themeModeForPreference(VibraThemePreference.system),
      ThemeMode.system,
    );
  });
}
