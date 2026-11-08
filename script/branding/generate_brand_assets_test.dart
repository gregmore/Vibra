// Derives every brand raster from the original VIBRA logo artwork.
//
// Source of truth: assets/branding/source/vibra_logo_white_on_black_1024.jpg
// (the logo exactly as supplied). Nothing here redraws the mark: the script
// only crops, resamples and converts luminance into alpha so the geometry is
// preserved pixel for pixel.
//
// Run: flutter test script/branding/generate_brand_assets_test.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _source = 'assets/branding/source/vibra_logo_white_on_black_1024.jpg';
const _ink = Color(0xFF000000);

Future<ui.Image> _decode(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}

Future<ui.Image> _fromPixels(Uint8List rgba, int width, int height) {
  final done = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    rgba,
    width,
    height,
    ui.PixelFormat.rgba8888,
    done.complete,
  );
  return done.future;
}

/// White-on-black artwork → white mark on a transparent canvas, cropped to the
/// mark's own bounds plus [padding] (fraction of the longest side).
Future<ui.Image> _extractMark(ui.Image source, {double padding = .04}) async {
  final w = source.width;
  final h = source.height;
  final rgba = (await source.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  ))!.buffer.asUint8List();

  // JPEG noise floor and highlight ceiling, mapped to a clean 0..255 ramp so
  // the anti-aliased edges of the original survive.
  const low = 24;
  const high = 232;
  int alphaAt(int i) {
    final l = (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;
    return ((l - low) * 255 ~/ (high - low)).clamp(0, 255);
  }

  var minX = w, minY = h, maxX = 0, maxY = 0;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (alphaAt((y * w + x) * 4) > 96) {
        minX = math.min(minX, x);
        maxX = math.max(maxX, x);
        minY = math.min(minY, y);
        maxY = math.max(maxY, y);
      }
    }
  }
  final pad = (math.max(maxX - minX, maxY - minY) * padding).round();
  minX = math.max(0, minX - pad);
  minY = math.max(0, minY - pad);
  maxX = math.min(w - 1, maxX + pad);
  maxY = math.min(h - 1, maxY + pad);
  final cw = maxX - minX + 1;
  final ch = maxY - minY + 1;
  final out = Uint8List(cw * ch * 4);
  for (var y = 0; y < ch; y++) {
    for (var x = 0; x < cw; x++) {
      final a = alphaAt(((y + minY) * w + (x + minX)) * 4);
      final o = (y * cw + x) * 4;
      out[o] = 255;
      out[o + 1] = 255;
      out[o + 2] = 255;
      out[o + 3] = a;
    }
  }
  return _fromPixels(out, cw, ch);
}

Future<ui.Image> _render(
  int width,
  int height,
  void Function(Canvas canvas) paint,
) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  picture.dispose();
  return image;
}

void _drawFit(Canvas canvas, ui.Image image, Rect target) {
  final scale = math.min(
    target.width / image.width,
    target.height / image.height,
  );
  final size = Size(image.width * scale, image.height * scale);
  final dst = Alignment.center.inscribe(size, target);
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    dst,
    Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true,
  );
}

Future<void> _write(String path, Uint8List bytes) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
}

Future<Uint8List> _png(ui.Image image) async => (await image.toByteData(
  format: ui.ImageByteFormat.png,
))!.buffer.asUint8List();

/// App icon: the supplied artwork itself, resampled. Opaque RGB as required by
/// the App Store.
Future<void> exportIcon(ui.Image artwork, String path, int side) async {
  final image = await _render(side, side, (canvas) {
    canvas.drawColor(Colors.black, BlendMode.src);
    _drawFit(
      canvas,
      artwork,
      Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble()),
    );
  });
  await _write(path, await _opaquePng(image));
  image.dispose();
}

Future<void> exportPlayFeatureGraphic(ui.Image mark, String path) async {
  const width = 1024;
  const height = 500;
  final image = await _render(width, height, (canvas) {
    canvas.drawColor(_ink, BlendMode.src);
    // A single, quiet violet signal behind the mark — no neon.
    canvas.drawCircle(
      const Offset(250, 250),
      240,
      Paint()
        ..shader = ui.Gradient.radial(const Offset(250, 250), 240, [
          const Color(0x408B5CF6),
          const Color(0x008B5CF6),
        ]),
    );
    _drawFit(canvas, mark, const Rect.fromLTWH(90, 110, 320, 280));

    void text(String value, Offset at, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 520);
      painter.paint(canvas, at);
      painter.dispose();
    }

    text(
      'VIBRA',
      const Offset(470, 150),
      const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w800,
        fontSize: 96,
        height: 1,
        letterSpacing: 6,
        color: Colors.white,
      ),
    );
    text(
      'La tua musica.\nLe tue persone.',
      const Offset(474, 272),
      const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
        fontSize: 34,
        height: 1.35,
        color: Color(0xFFA1A1AA),
      ),
    );
  });
  await _write(path, await _opaquePng(image));
  image.dispose();
}

/// Store images must have no alpha channel, including fully opaque alpha.
Future<Uint8List> _opaquePng(ui.Image image) async {
  final width = image.width;
  final height = image.height;
  final rgba = (await image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  ))!.buffer.asUint8List();
  final rgb = BytesBuilder(copy: false);
  for (var y = 0; y < height; y++) {
    rgb.addByte(0); // PNG filter: None.
    for (var x = 0; x < width; x++) {
      final offset = (y * width + x) * 4;
      rgb.add(rgba.sublist(offset, offset + 3));
    }
  }
  Uint8List chunk(String name, List<int> data) {
    final payload = [...ascii.encode(name), ...data];
    var crc = 0xffffffff;
    for (final byte in payload) {
      crc ^= byte;
      for (var bit = 0; bit < 8; bit++) {
        crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
      }
    }
    final length = ByteData(4)..setUint32(0, data.length);
    final checksum = ByteData(4)..setUint32(0, crc ^ 0xffffffff);
    return Uint8List.fromList([
      ...length.buffer.asUint8List(),
      ...payload,
      ...checksum.buffer.asUint8List(),
    ]);
  }

  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, 2); // 8-bit RGB, no alpha.
  return Uint8List.fromList([
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    ...chunk('IHDR', header.buffer.asUint8List()),
    ...chunk('IDAT', ZLibCodec(level: 9).encode(rgb.takeBytes())),
    ...chunk('IEND', []),
  ]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final file in ['Inter-Medium', 'Inter-ExtraBold']) {
      final loader = FontLoader('Inter');
      loader.addFont(rootBundle.load('assets/fonts/$file.ttf'));
      await loader.load();
    }
  });

  test('Export brand rasters from the original VIBRA logo', () async {
    final artwork = await _decode(await File(_source).readAsBytes());

    // In-app mark: white on transparent, tinted at runtime.
    final mark = await _extractMark(artwork);
    await _write('assets/branding/logo/vibra_mark.png', await _png(mark));

    // Native launch screens: the mark on a transparent square with the
    // safe-zone padding required by the Android 12 circular icon mask.
    final splash = await _render(768, 768, (canvas) {
      _drawFit(canvas, mark, const Rect.fromLTWH(234, 234, 300, 300));
    });
    await _write(
      'assets/branding/logo/vibra_splash_mark.png',
      await _png(splash),
    );
    splash.dispose();

    final contents =
        jsonDecode(
              await File(
                'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
              ).readAsString(),
            )
            as Map<String, dynamic>;
    for (final entry in contents['images'] as List) {
      final item = entry as Map<String, dynamic>;
      final size = double.parse((item['size'] as String).split('x').first);
      final scale = double.parse((item['scale'] as String).replaceAll('x', ''));
      await exportIcon(
        artwork,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/${item['filename']}',
        (size * scale).round(),
      );
    }
    for (final (density, side) in [
      ('mdpi', 48),
      ('hdpi', 72),
      ('xhdpi', 96),
      ('xxhdpi', 144),
      ('xxxhdpi', 192),
    ]) {
      await exportIcon(
        artwork,
        'android/app/src/main/res/mipmap-$density/ic_launcher.png',
        side,
      );
    }
    await exportIcon(
      artwork,
      'assets/branding/raster/vibra_app_icon_1024.png',
      1024,
    );
    await exportPlayFeatureGraphic(
      mark,
      'assets/branding/raster/vibra_play_feature_graphic_1024x500.png',
    );
    mark.dispose();
    artwork.dispose();
  });
}
