import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/core/theme/vibra_text_styles.dart';
import 'package:vibra/core/theme/vibra_theme_tokens.dart';

void main() {
  for (final entry in const {
    'light': VibraThemeTokens.light,
    'dark': VibraThemeTokens.dark,
  }.entries) {
    group('${entry.key} semantic contrast', () {
      final t = entry.value;
      final neutralSurfaces = {
        'backgroundPrimary': t.backgroundPrimary,
        'backgroundSecondary': t.backgroundSecondary,
        'surface': t.surface,
        'surfaceElevated': t.surfaceElevated,
        'surfaceMuted': t.surfaceMuted,
      };

      for (final surface in neutralSurfaces.entries) {
        test('primary text on ${surface.key} is AA', () {
          _expectContrast(t.textPrimary, surface.value, 4.5);
        });
        test('secondary text on ${surface.key} is AA', () {
          _expectContrast(t.textSecondary, surface.value, 4.5);
        });
      }

      test('CTA copy is AA on both gradient endpoints', () {
        for (final color in t.primaryGradient.colors) {
          _expectContrast(t.onAccent, color, 4.5);
        }
      });

      test('semantic status copy is AA on cards', () {
        for (final color in [t.success, t.warning, t.error]) {
          _expectContrast(color, t.surfaceElevated, 4.5);
        }
      });

      test('image copy is AA over the opaque copy panel', () {
        _expectContrast(
          t.onImage,
          _composite(t.imageOverlay, Colors.white),
          4.5,
        );
        _expectContrast(
          t.onImageMuted,
          _composite(t.imageOverlay, Colors.white),
          4.5,
        );
      });

      test('image scrim protects white copy from a white photograph', () {
        _expectContrast(t.onImage, _composite(t.imageScrim, Colors.white), 4.5);
      });
    });
  }

  test('large app canvases avoid pure black and pure white', () {
    expect(VibraThemeTokens.light.backgroundPrimary, isNot(Colors.white));
    expect(VibraThemeTokens.dark.backgroundPrimary, isNot(Colors.black));
  });

  test('informational type never drops below the agreed floor', () {
    expect(VibraTextStyles.minimumBodyFontSize, greaterThanOrEqualTo(12));
    expect(VibraTextStyles.minimumLabelFontSize, greaterThanOrEqualTo(11));
  });

  test('paragraph styles use at least 1.4 line height', () {
    expect(VibraTextStyles.paragraphLineHeight, greaterThanOrEqualTo(1.4));
  });
}

void _expectContrast(Color foreground, Color background, double minimum) {
  expect(
    _contrast(foreground, background),
    greaterThanOrEqualTo(minimum),
    reason:
        '${_hex(foreground)} on ${_hex(background)} must reach '
        '${minimum.toStringAsFixed(1)}:1',
  );
}

double _contrast(Color a, Color b) {
  final lighter = math.max(a.computeLuminance(), b.computeLuminance());
  final darker = math.min(a.computeLuminance(), b.computeLuminance());
  return (lighter + .05) / (darker + .05);
}

Color _composite(Color foreground, Color background) {
  final alpha = foreground.a;
  return Color.from(
    alpha: 1,
    red: foreground.r * alpha + background.r * (1 - alpha),
    green: foreground.g * alpha + background.g * (1 - alpha),
    blue: foreground.b * alpha + background.b * (1 - alpha),
  );
}

String _hex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
