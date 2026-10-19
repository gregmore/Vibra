// Offline visual QA of the production map and support form in every language.
// Run explicitly: flutter test script/store/capture_map_report_test.dart
// Fixtures are fictional; no GPS, HTTP, account, report or backend is used.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/services/support_service.dart';
import 'package:vibra/core/theme/vibra_theme.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/location_provider.dart';
import 'package:vibra/presentation/providers/map_events_provider.dart';
import 'package:vibra/presentation/screens/explore/explore_screen.dart';
import 'package:vibra/presentation/screens/profile/report_problem_screen.dart';
import 'package:vibra/presentation/widgets/common/vibra_openstreetmap_layer.dart';

const _size = Size(360, 780);
const _outputDirectory = 'release/qa-20261014/map-report-captures';
final _events = <Event>[
  for (final (index, name, latitude, longitude) in [
    (1, 'Notte Indie', 45.4642, 9.1900),
    (2, 'Suoni in Cortile', 45.4645, 9.1905),
    (3, 'Luci Elettroniche', 45.4647, 9.1910),
    (4, 'Jazz al Tramonto', 45.4790, 9.2060),
    (5, 'Ritmi di Quartiere', 45.4800, 9.2070),
    (6, 'Festival delle Nuove Voci', 45.4420, 9.1500),
    (7, 'Live in Fabbrica', 45.5010, 9.1360),
    (8, 'House in Terrazza', 45.4300, 9.2310),
    (9, 'Onde Alternative', 45.4810, 9.2620),
    (10, 'Domenica Acustica', 45.4190, 9.1610),
    (11, 'Orizzonti Sonori', 45.5060, 9.2440),
    (12, 'Voci della Città', 45.4550, 9.1050),
  ])
    Event(
      id: 'capture-event-$index',
      externalId: 'capture-event-$index',
      source: 'offline-visual-fixture',
      name: name,
      artistName: 'Nuova Scena',
      venueName: 'Spazio Live $index',
      city: 'Milano',
      latitude: latitude,
      longitude: longitude,
      eventDate: DateTime(2027, 5, 14 + index, 21),
      description: 'Evento immaginario per la verifica grafica offline.',
      priceMin: 15,
      priceMax: 30,
    ),
];

class _OfflineMapEvents extends AutoDisposeAsyncNotifier<List<Event>>
    implements MapEventsNotifier {
  @override
  FutureOr<List<Event>> build() => _events;

  @override
  void updateLocation(
    double latitude,
    double longitude,
    double radiusInMeters,
  ) {
    // The camera still follows the production map code. Its data stays local.
  }

  @override
  Future<void> refresh() async {
    state = AsyncData(_events);
  }
}

class _MemoryTiles extends TileProvider {
  static final _image = MemoryImage(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
    ),
  );

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _image;
}

class _OfflineSupport implements SupportService {
  @override
  String get currentUserId => 'offline-capture-user';

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<Map<String, dynamic>> diagnostics() async => const {};

  @override
  Future<void> submit({
    required String description,
    Uint8List? screenshotBytes,
    String? screenshotExtension,
  }) async {
    throw StateError('Offline captures must never send a support report.');
  }
}

class _OfflinePicker extends ImagePicker {
  _OfflinePicker(this.bytes);
  final Uint8List bytes;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = true,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async => XFile.fromData(
    bytes,
    name: 'offline-map-screenshot.png',
    mimeType: 'image/png',
  );
}

const _descriptions = {
  'it':
      'Nella mappa cerco gli eventi vicino a Milano. Dopo avere cambiato il '
      'raggio e riaperto la schermata, vorrei capire quali risultati sono '
      'stati aggiornati. Allego una schermata di esempio per spiegare il problema.',
  'en':
      'I am searching the map for events near Milan. After changing the '
      'search radius and reopening the screen, I would like to understand '
      'which results were updated. I have attached an example screenshot to explain the problem.',
  'de':
      'Ich suche auf der Karte nach Veranstaltungen in der Nähe von Mailand. '
      'Nachdem ich den Suchradius geändert und die Ansicht erneut geöffnet '
      'habe, möchte ich erkennen, welche Ergebnisse aktualisiert wurden. '
      'Zur Erklärung habe ich einen beispielhaften Screenshot angehängt.',
  'fr':
      'Je cherche des événements près de Milan sur la carte. Après avoir '
      'modifié le rayon et rouvert la page, je voudrais savoir quels '
      'résultats ont été actualisés. Je joins une capture d’exemple pour expliquer le problème.',
  'es':
      'Busco eventos cerca de Milán en el mapa. Después de cambiar el radio '
      'de búsqueda y volver a abrir la pantalla, me gustaría saber qué '
      'resultados se han actualizado. Adjunto una captura de ejemplo para explicar el problema.',
};

Future<void> _loadFonts() async {
  for (final (family, files) in [
    (
      'Inter',
      [
        'Inter-Regular',
        'Inter-Medium',
        'Inter-SemiBold',
        'Inter-Bold',
        'Inter-ExtraBold',
      ],
    ),
    ('Syne', ['Syne-SemiBold', 'Syne-Bold']),
    // Explicit Material button text styles can omit a family. Supply both the
    // Android family and the tester's substituted default with real glyphs.
    ('Roboto', ['Inter-Regular']),
    ('Ahem', ['Inter-Regular']),
  ]) {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(rootBundle.load('assets/fonts/$file.ttf'));
    }
    await loader.load();
  }
  final icons = FontLoader('MaterialIcons');
  icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();
}

Widget _app({
  required GlobalKey boundaryKey,
  required String language,
  required bool dark,
  required Widget screen,
}) => RepaintBoundary(
  key: boundaryKey,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dark ? VibraTheme.darkTheme : VibraTheme.lightTheme,
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: screen,
  ),
);

Future<Uint8List> _capture(
  WidgetTester tester,
  GlobalKey key,
  String path,
) async {
  expect(tester.takeException(), isNull);
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      expect(image.width, 720);
      expect(image.height, 1560);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final png = data!.buffer.asUint8List();
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(png);
      return png;
    } finally {
      image.dispose();
    }
  });
  expect(bytes, isNotNull);
  expect(tester.takeException(), isNull);
  return bytes!;
}

Future<void> _waitForAttachment(WidgetTester tester) async {
  final image = tester.widget<Image>(find.byType(Image));
  await tester.runAsync(() async {
    // Engine image decoding runs outside the fake test clock. Waiting only
    // through pumpAndSettle can capture an allocated, still empty preview.
    final stream = image.image.resolve(ImageConfiguration.empty);
    final ready = Completer<Size>();
    final listener = ImageStreamListener(
      (info, synchronousCall) {
        if (!ready.isCompleted) {
          ready.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()),
          );
        }
        info.dispose();
      },
      onError: (Object error, StackTrace? stack) {
        if (!ready.isCompleted) ready.completeError(error, stack);
      },
    );
    stream.addListener(listener);
    try {
      expect(
        await ready.future.timeout(const Duration(seconds: 10)),
        const Size(720, 1560),
      );
    } finally {
      stream.removeListener(listener);
    }
  });
  // The production Image listener receives the same decoded frame; paint it.
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  for (final language in ['it', 'en', 'de', 'fr', 'es']) {
    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      testWidgets('$language $theme map and attached support report', (
        tester,
      ) async {
        tester.view.physicalSize = _size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final mapKey = GlobalKey();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userLocationProvider.overrideWith(
                (ref) async => UserLocation.milano,
              ),
              mapEventsProvider.overrideWith(_OfflineMapEvents.new),
              exploreGeocoderProvider.overrideWithValue((query) async => []),
              openStreetMapTileProvider.overrideWith((ref) => _MemoryTiles()),
            ],
            child: _app(
              boundaryKey: mapKey,
              language: language,
              dark: dark,
              screen: const ExploreScreen(),
            ),
          ),
        );
        // Bounded frames also finish marker/entry animations without waiting
        // for decorative map beacons that intentionally animate continuously.
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 2));
        final directory = '$_outputDirectory/$language-$theme';
        final mapScreenshot = await _capture(
          tester,
          mapKey,
          '$directory/01-map.png',
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();

        final reportKey = GlobalKey();
        await tester.pumpWidget(
          _app(
            boundaryKey: reportKey,
            language: language,
            dark: dark,
            screen: ReportProblemScreen(
              initialDescription: _descriptions[language],
              supportService: _OfflineSupport(),
              imagePicker: _OfflinePicker(mapScreenshot),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(ReportProblemScreen)),
        )!;
        await tester.ensureVisible(find.text(l10n.supportAddScreenshot));
        await tester.tap(find.text(l10n.supportAddScreenshot));
        await tester.pumpAndSettle();
        expect(find.text(l10n.supportScreenshotAttached), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
        await _waitForAttachment(tester);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          _descriptions[language],
        );
        // Return to the start so all languages show the same form position.
        // TextField has its own nested scrollable. Resolve the surrounding
        // form's scrollable from the attachment label instead of collecting
        // every scrollable under the ListView.
        final scroll = Scrollable.of(
          tester.element(find.text(l10n.supportScreenshotAttached)),
        );
        scroll.position.jumpTo(0);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await _capture(tester, reportKey, '$directory/02-report-attached.png');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
