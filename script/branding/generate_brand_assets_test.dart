// Export the shared brand geometry; promotional text uses bundled local fonts.
// Run: flutter test script/branding/generate_brand_assets_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/presentation/widgets/common/vibra_logo.dart';

Future<void> exportIcon(String path, int side) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawColor(const Color(0xFF7C3AED), BlendMode.src);
  canvas.save();
  canvas.translate(side * .16, side * .16);
  const fraction = .68;
  VibraLogoPainter(
    strokeWidth: side * fraction * .07,
    gradient: const LinearGradient(colors: [Colors.white, Colors.white]),
  ).paint(canvas, Size(side * fraction, side * fraction));
  canvas.restore();
  final picture = recorder.endRecording();
  final image = await picture.toImage(side, side);
  final bytes = await _opaquePng(image);
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
  image.dispose();
  picture.dispose();
}

Future<void> exportPlayFeatureGraphic(String path) async {
  const width = 1024;
  const height = 500;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawColor(const Color(0xFF7C3AED), BlendMode.src);
  canvas.save();
  canvas.translate(40, 84);
  const logoSide = 330.0;
  const VibraLogoPainter(
    strokeWidth: logoSide * .07,
    gradient: LinearGradient(colors: [Colors.white, Colors.white]),
  ).paint(canvas, const Size.square(logoSide));
  canvas.restore();

  void paintText(String text, Offset position, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 544);
    painter.paint(canvas, position);
    painter.dispose();
  }

  paintText(
    'vibra',
    const Offset(414, 116),
    const TextStyle(
      fontFamily: 'Syne',
      fontWeight: FontWeight.w700,
      fontSize: 112,
      height: 1,
      letterSpacing: -4,
      color: Colors.white,
    ),
  );
  paintText(
    'La tua musica.\nLe tue persone.',
    const Offset(420, 263),
    const TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      fontSize: 36,
      height: 1.4,
      color: Colors.white,
    ),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(await _opaquePng(image));
  image.dispose();
  picture.dispose();
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
    for (final (family, file) in [
      ('Syne', 'Syne-Bold'),
      ('Inter', 'Inter-Regular'),
    ]) {
      final loader = FontLoader(family);
      loader.addFont(rootBundle.load('assets/fonts/$file.ttf'));
      await loader.load();
    }
  });
  test('Export native icons from the application mark', () async {
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
        'android/app/src/main/res/mipmap-$density/ic_launcher.png',
        side,
      );
    }
    await exportIcon('assets/branding/raster/vibra_app_icon_1024.png', 1024);
    await exportIcon('release/qa-20261013/logo-preview.png', 1024);
    await exportPlayFeatureGraphic(
      'assets/branding/raster/vibra_play_feature_graphic_1024x500.png',
    );
  });
}
