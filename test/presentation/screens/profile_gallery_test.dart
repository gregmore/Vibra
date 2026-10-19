import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/theme/vibra_theme.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/profile_photo_provider.dart';
import 'package:vibra/presentation/screens/profile/edit_profile_screen.dart';
import 'package:vibra/presentation/widgets/common/vibra_avatar.dart';

import '../../helpers/test_http_overrides.dart';

class _Profile extends StateNotifier<AppUser> implements ProfileController {
  _Profile({String? avatarUrl})
    : super(
        AppUser(
          id: 'me',
          email: '',
          username: 'music_fan',
          displayName: 'Giulia',
          avatarUrl: avatarUrl,
        ),
      );
  String? avatar;
  bool failSave = false;
  Object? saveError;
  int saves = 0;
  @override
  Future<void> updateProfile({
    String? username,
    String? displayName,
    String? bio,
    String? onboardingStep,
    bool? onboardingCompleted,
    String? avatarUrl,
  }) async {
    saves++;
    if (saveError != null) throw saveError!;
    if (failSave) throw StateError('offline');
    avatar = avatarUrl;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Picker extends ImagePicker {
  Future<XFile?> Function() result = () async => null;
  LostDataResponse lost = LostDataResponse.empty();
  Future<LostDataResponse>? lostResult;
  int calls = 0;
  int recoveries = 0;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) {
    calls++;
    expect(source, ImageSource.gallery);
    expect(maxWidth, 1024);
    expect(maxHeight, 1024);
    expect(imageQuality, 85);
    expect(requestFullMetadata, false);
    return result();
  }

  @override
  Future<LostDataResponse> retrieveLostData() async {
    recoveries++;
    return lostResult ?? lost;
  }
}

void main() {
  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://fake.supabase.co',
      publishableKey: 'fake',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );
  });
  tearDownAll(() => HttpOverrides.global = null);
  final photo = File(
    'assets/branding/raster/vibra_app_icon_1024.png',
  ).absolute.path;

  Future<void> mount(
    WidgetTester tester,
    _Profile profile,
    _Picker picker, {
    double textScale = 1,
  }) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/edit-profile'),
              child: const Text('Edit'),
            ),
          ),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (_, _) => const EditProfileScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myProfileProvider.overrideWith((_) => profile),
          profileImagePickerProvider.overrideWithValue(picker),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: VibraTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
  }

  Future<void> openGallery(WidgetTester tester) async {
    await tester.tap(find.text('Cambia immagine profilo'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Scegli dalla galleria'));
    await tester.tap(find.text('Scegli dalla galleria'));
    await tester.pump();
  }

  testWidgets('Gallery previews the photo and saves only after confirmation', (
    tester,
  ) async {
    final profile = _Profile();
    final picker = _Picker()..result = () async => XFile(photo);
    await mount(tester, profile, picker);
    await openGallery(tester);
    await tester.pumpAndSettle();
    expect(
      tester.widget<VibraAvatar>(find.byType(VibraAvatar)).imageUrl,
      photo,
    );
    expect(profile.saves, 0);
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(profile.avatar, photo);
    expect(profile.saves, 1);
    expect(find.text('Edit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cancelling selection keeps the existing avatar', (tester) async {
    final profile = _Profile();
    final picker = _Picker();
    await mount(tester, profile, picker);
    await openGallery(tester);
    await tester.pumpAndSettle();
    expect(
      tester.widget<VibraAvatar>(find.byType(VibraAvatar)).imageUrl,
      isEmpty,
    );
    expect(profile.saves, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Selection is protected from repeated taps and concurrent saving',
    (tester) async {
      final pending = Completer<XFile?>();
      final picker = _Picker()..result = () => pending.future;
      final profile = _Profile();
      await mount(tester, profile, picker);
      await openGallery(tester);
      await tester.pump(const Duration(seconds: 1));
      final change = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Cambia immagine profilo'),
      );
      expect(change.onPressed, isNull);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Salva'))
            .onPressed,
        isNull,
      );
      expect(picker.calls, 1);
      pending.complete(null);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Salva'))
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('Permission denial shows recovery guidance without saving', (
    tester,
  ) async {
    final profile = _Profile();
    final picker = _Picker()
      ..result = () async =>
          throw PlatformException(code: 'photo_access_denied');
    await mount(tester, profile, picker);
    await openGallery(tester);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Consenti l’accesso alle foto nelle impostazioni del dispositivo e riprova.',
      ),
      findsOneWidget,
    );
    expect(profile.saves, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Interrupted Android gallery is recovered without automatic upload',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final profile = _Profile();
      final picker = _Picker()..lost = LostDataResponse(files: [XFile(photo)]);
      await mount(tester, profile, picker);
      debugDefaultTargetPlatformOverride = null;
      expect(picker.recoveries, 1);
      expect(
        tester.widget<VibraAvatar>(find.byType(VibraAvatar)).imageUrl,
        photo,
      );
      expect(profile.saves, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Failed upload retains the preview for retry', (tester) async {
    final profile = _Profile()..failSave = true;
    final picker = _Picker()..result = () async => XFile(photo);
    await mount(tester, profile, picker);
    await openGallery(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(
      find.text('Impossibile salvare il profilo. Riprova tra poco.'),
      findsOneWidget,
    );
    expect(
      tester.widget<VibraAvatar>(find.byType(VibraAvatar)).imageUrl,
      photo,
    );
    profile.failSave = false;
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(profile.saves, 2);
    expect(profile.avatar, photo);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gallery controls fit a small phone with large text', (
    tester,
  ) async {
    await mount(tester, _Profile(), _Picker(), textScale: 2);
    await tester.tap(find.text('Cambia immagine profilo'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Scatta una foto'));
    await tester.pumpAndSettle();
  });
  testWidgets('Removing an avatar wins over delayed Android gallery recovery', (
    tester,
  ) async {
    final delayed = Completer<LostDataResponse>();
    final picker = _Picker()..lostResult = delayed.future;
    final profile = _Profile(avatarUrl: 'https://example.invalid/old.png');
    await mount(tester, profile, picker);
    await tester.tap(find.text('Cambia immagine profilo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rimuovi foto'));
    await tester.pumpAndSettle();
    delayed.complete(LostDataResponse(files: [XFile(photo)]));
    await tester.pumpAndSettle();
    final preview = tester.widget<VibraAvatar>(find.byType(VibraAvatar));

    expect(preview.imageUrl, isEmpty);
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(profile.avatar, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('A username race gives a precise, recoverable conflict', (
    tester,
  ) async {
    final profile = _Profile()
      ..saveError = const PostgrestException(
        message: 'duplicate',
        code: '23505',
      );
    await mount(tester, profile, _Picker());
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(
      find.text('Username già in uso. Scegline un altro.'),
      findsOneWidget,
    );
    expect(find.text('Username già in uso'), findsOneWidget);
    expect(profile.saves, 1);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Salva'))
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
}
