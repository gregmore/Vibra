import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/screens/profile/edit_profile_screen.dart';
import '../../helpers/test_http_overrides.dart';

class MockProfileController extends StateNotifier<AppUser>
    implements ProfileController {
  MockProfileController(super.user);

  bool updateProfileCalled = false;
  String? updatedUsername;
  String? updatedDisplayName;
  String? updatedBio;
  String? updatedAvatarUrl;

  @override
  Future<void> updateProfile({
    String? username,
    String? displayName,
    String? bio,
    String? onboardingStep,
    bool? onboardingCompleted,
    String? avatarUrl,
  }) async {
    updateProfileCalled = true;
    updatedUsername = username;
    updatedDisplayName = displayName;
    updatedBio = bio;
    updatedAvatarUrl = avatarUrl;
    state = AppUser(
      id: state.id,
      email: state.email,
      username: username ?? state.username,
      displayName: displayName ?? state.displayName,
      bio: bio ?? state.bio,
      avatarUrl: avatarUrl ?? state.avatarUrl,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues(const {});
    try {
      await Supabase.initialize(
        url: 'https://fake.supabase.co',
        publishableKey: 'fakeAnonKey',
        authOptions: const FlutterAuthClientOptions(
          localStorage: EmptyLocalStorage(),
        ),
      );
    } catch (_) {
      // already initialized
    }
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  final testUser = AppUser(
    id: 'user-123',
    email: 'test@vibra.app',
    username: 'vibra_fan',
    displayName: 'Marco Rossi',
    bio: 'Amo i concerti rock e indie live!',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
  );

  testWidgets('EditProfileScreen renders initial values correctly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myProfileProvider.overrideWith(
            (ref) => MockProfileController(testUser),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('it'),
          home: EditProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Modifica Profilo'), findsOneWidget);
    expect(find.text('vibra_fan'), findsOneWidget);
    expect(find.text('Marco Rossi'), findsOneWidget);
    expect(find.text('Amo i concerti rock e indie live!'), findsOneWidget);
    expect(find.text('Cambia immagine profilo'), findsOneWidget);
    expect(find.text('Salva Modifiche'), findsOneWidget);
  });

  testWidgets('Tapping change photo opens bottom sheet with options', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myProfileProvider.overrideWith(
            (ref) => MockProfileController(testUser),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('it'),
          home: EditProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Cambia immagine profilo'));
    await tester.pumpAndSettle();

    expect(find.text('Foto Profilo'), findsOneWidget);
    expect(find.text('Scegli dalla galleria'), findsOneWidget);
    expect(find.text('Scatta una foto'), findsOneWidget);
    expect(find.text('Rimuovi foto'), findsOneWidget);
  });

  testWidgets('Invalid username shows error message', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myProfileProvider.overrideWith(
            (ref) => MockProfileController(testUser),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('it'),
          home: EditProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final usernameFinder = find.widgetWithText(TextFormField, 'vibra_fan');
    await tester.enterText(usernameFinder, 'ab');
    await tester.pump();

    expect(find.text('Minimo 3 caratteri'), findsOneWidget);
  });

  testWidgets('Saving updated profile calls updateProfile on controller', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockController = MockProfileController(testUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [myProfileProvider.overrideWith((ref) => mockController)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('it'),
          home: EditProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final nameFinder = find.widgetWithText(TextFormField, 'Marco Rossi');
    await tester.enterText(nameFinder, 'Marco Rocker');
    await tester.pump();

    final bioFinder = find.widgetWithText(
      TextFormField,
      'Amo i concerti rock e indie live!',
    );
    await tester.enterText(bioFinder, 'Nuova descrizione musicale');
    await tester.pump();

    await tester.tap(find.text('Salva Modifiche'));
    await tester.pump();

    expect(mockController.updateProfileCalled, isTrue);
    expect(mockController.updatedDisplayName, equals('Marco Rocker'));
    expect(mockController.updatedBio, equals('Nuova descrizione musicale'));
  });
}
