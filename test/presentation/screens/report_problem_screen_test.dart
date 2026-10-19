import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/core/services/support_service.dart';
import 'package:vibra/core/theme/vibra_theme.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/screens/profile/report_problem_screen.dart';

XFile _screenshot() => XFile.fromData(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aMKsAAAAASUVORK5CYII=',
  ),
  name: 'screenshot.png',
  mimeType: 'image/png',
);

class _Service extends SupportService {
  _Service(super.client);
  String? userId = 'me';
  final changes = StreamController<AuthState>.broadcast();
  Future<void> Function() result = () async {};
  int sends = 0;
  String? sentDescription;
  Uint8List? sentScreenshot;

  @override
  String? get currentUserId => userId;
  @override
  Stream<AuthState> get authStateChanges => changes.stream;
  @override
  Future<void> submit({
    required String description,
    Uint8List? screenshotBytes,
    String? screenshotExtension,
  }) async {
    sends++;
    sentDescription = description;
    sentScreenshot = screenshotBytes;
    await result();
  }
}

class _Picker extends ImagePicker {
  Future<XFile?> Function() result = () async => null;
  int calls = 0;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = true,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) {
    calls++;
    expect(source, ImageSource.gallery);
    expect(maxWidth, 1920);
    expect(maxHeight, 1920);
    expect(imageQuality, 85);
    expect(requestFullMetadata, false);
    return result();
  }
}

void main() {
  late SupabaseClient client;
  late _Service service;
  late _Picker picker;

  setUp(() {
    client = SupabaseClient('https://example.supabase.co', 'test-key');
    service = _Service(client);
    picker = _Picker();
  });
  tearDown(() async {
    await service.changes.close();
    await client.dispose();
  });

  Future<void> mount(WidgetTester tester, {String locale = 'it'}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: VibraTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(locale),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ReportProblemScreen(
                    supportService: service,
                    imagePicker: picker,
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> send(WidgetTester tester) async {
    final l10n = AppLocalizations.of(
      tester.element(find.byType(ReportProblemScreen)),
    )!;
    final sendButton = find.widgetWithText(
      FilledButton,
      l10n.supportSendReport,
    );
    await tester.scrollUntilVisible(
      sendButton,
      120,
      scrollable: find
          .descendant(
            of: find.byType(ReportProblemScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(sendButton);
    await tester.pump();
  }

  testWidgets(
    'A failed report retains the editable description and screenshot',
    (tester) async {
      service.result = () async =>
          throw const SupportSubmissionException(SupportFailure.unavailable);
      picker.result = () async => _screenshot();
      await mount(tester);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(ReportProblemScreen)),
      )!;
      await tester.enterText(
        find.byType(TextField),
        'La mappa non mostra gli eventi',
      );
      await tester.ensureVisible(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(ReportProblemScreen)),
          )!.supportAddScreenshot,
        ),
      );
      await tester.tap(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(ReportProblemScreen)),
          )!.supportAddScreenshot,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.supportScreenshotAttached), findsOneWidget);
      await send(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'La mappa non mostra gli eventi',
      );
      expect(find.text(l10n.supportScreenshotAttached), findsOneWidget);
      expect(service.sentScreenshot, isNotNull);
      expect(service.sends, 1);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, l10n.supportSendReport),
            )
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('A short description is rejected locally without sending', (
    tester,
  ) async {
    await mount(tester);
    await tester.enterText(find.byType(TextField), '😀😀😀😀');
    await send(tester);
    await tester.pumpAndSettle();
    expect(service.sends, 0);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Rate limiting leaves the draft available for a later retry', (
    tester,
  ) async {
    service.result = () async =>
        throw const SupportSubmissionException(SupportFailure.rateLimited);
    await mount(tester);
    await tester.enterText(
      find.byType(TextField),
      'Non riesco a inviare messaggi',
    );
    await send(tester);
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(ReportProblemScreen));
    expect(
      find.text(AppLocalizations.of(context)!.supportReportRateLimited),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Non riesco a inviare messaggi',
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'One in-flight send disables the controls and success is shown after confirmation',
    (tester) async {
      final pending = Completer<void>();
      service.result = () => pending.future;
      await mount(tester);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(ReportProblemScreen)),
      )!;
      await tester.enterText(
        find.byType(TextField),
        'Non riesco a inviare messaggi',
      );
      await send(tester);
      expect(service.sends, 1);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
      final sending = find.widgetWithText(FilledButton, l10n.supportSending);
      expect(tester.widget<FilledButton>(sending).onPressed, isNull);
      pending.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(l10n.supportReportSentTitle), findsOneWidget);
      await tester.tap(find.text(l10n.commonOK));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
      expect(find.byType(ReportProblemScreen), findsNothing);
    },
  );

  testWidgets(
    'The gallery returning after leaving the report cannot set disposed state',
    (tester) async {
      final pending = Completer<XFile?>();
      picker.result = () => pending.future;
      await mount(tester);
      await tester.ensureVisible(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(ReportProblemScreen)),
          )!.supportAddScreenshot,
        ),
      );
      await tester.tap(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(ReportProblemScreen)),
          )!.supportAddScreenshot,
        ),
      );
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ReportProblemScreen), findsNothing);
      pending.complete(_screenshot());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Open'), findsOneWidget);
    },
  );

  testWidgets('Gallery permission denial keeps the report usable', (
    tester,
  ) async {
    picker.result = () async =>
        throw PlatformException(code: 'photo_access_denied');
    await mount(tester);
    await tester.enterText(
      find.byType(TextField),
      'La mappa non mostra gli eventi',
    );
    await tester.ensureVisible(
      find.text(
        AppLocalizations.of(
          tester.element(find.byType(ReportProblemScreen)),
        )!.supportAddScreenshot,
      ),
    );
    await tester.tap(
      find.text(
        AppLocalizations.of(
          tester.element(find.byType(ReportProblemScreen)),
        )!.supportAddScreenshot,
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(ReportProblemScreen));
    expect(
      find.text(
        AppLocalizations.of(context)!.supportScreenshotPermissionDenied,
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'La mappa non mostra gli eventi',
    );
    expect(service.sends, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Signing out clears private draft and rejects a late gallery selection',
    (tester) async {
      final pending = Completer<XFile?>();
      picker.result = () => pending.future;
      await mount(tester);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(ReportProblemScreen)),
      )!;
      await tester.enterText(
        find.byType(TextField),
        'Descrizione privata del mio problema',
      );
      await tester.ensureVisible(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(ReportProblemScreen)),
          )!.supportAddScreenshot,
        ),
      );
      await tester.tap(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(ReportProblemScreen)),
          )!.supportAddScreenshot,
        ),
      );
      await tester.pump();
      service.userId = null;
      service.changes.add(AuthState(AuthChangeEvent.signedOut, null));
      await tester.pump();
      pending.complete(_screenshot());
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text(l10n.supportScreenshotAttached), findsNothing);
      expect(service.sends, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Report form labels and support contacts follow the selected language',
    (tester) async {
      await mount(tester, locale: 'en');
      expect(find.text('Report a problem'), findsOneWidget);
      expect(find.text('Segnala un problema'), findsNothing);
      final context = tester.element(find.byType(ReportProblemScreen));
      final l10n = AppLocalizations.of(context)!;
      expect(find.text(l10n.supportDescriptionLabel), findsOneWidget);
      expect(
        find.text(l10n.supportAlternativeContact(AppConstants.supportEmail)),
        findsOneWidget,
      );
    },
  );
}
