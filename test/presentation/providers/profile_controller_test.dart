import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/domain/usecases/profile_usecases.dart';
import 'package:vibra/domain/usecases/usecase.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';

class _Ref extends Mock implements Ref {}

class _Source extends Mock implements SupabaseDatasource {}

class _GetProfile extends Mock implements GetMyProfileUseCase {}

User user(String id) => User(
  id: id,
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  createdAt: '2026-10-13',
);
const oldProfile = AppUser(
  id: 'alice',
  email: '',
  username: 'alice',
  avatarUrl: 'https://example.invalid/old.png',
);
const newProfile = AppUser(
  id: 'alice',
  email: '',
  username: 'alice',
  avatarUrl: 'https://example.invalid/new.png',
);

void main() {
  registerFallbackValue(Uint8List(0));
  Future<void> start() => Future<void>.delayed(Duration.zero);
  (_Ref, _Source, _GetProfile) setup() {
    final ref = _Ref();
    final source = _Source();
    final get = _GetProfile();
    when(() => ref.read(supabaseDatasourceProvider)).thenReturn(source);
    when(() => ref.read(getMyProfileUseCaseProvider)).thenReturn(get);
    when(() => source.currentUser).thenReturn(user('alice'));
    return (ref, source, get);
  }

  test('A stale profile refresh cannot overwrite a more recent one', () async {
    final (ref, _, get) = setup();
    final first = Completer<AppUser>();
    final second = Completer<AppUser>();
    var reads = 0;
    when(
      () => get.call(const NoParams()),
    ).thenAnswer((_) => ++reads == 1 ? first.future : second.future);
    final controller = ProfileController(ref);
    await start();
    final refresh = controller.refresh();
    second.complete(newProfile);
    await refresh;
    first.complete(oldProfile);
    await start();
    expect(controller.state.avatarUrl, newProfile.avatarUrl);
    controller.dispose();
  });
  test('An old account response does not populate the new session', () async {
    final (ref, source, get) = setup();
    final pending = Completer<AppUser>();
    when(() => get.call(const NoParams())).thenAnswer((_) => pending.future);
    final controller = ProfileController(ref);
    await start();
    when(() => source.currentUser).thenReturn(user('bob'));
    pending.complete(oldProfile);
    await start();
    expect(controller.state.id, isEmpty);
    controller.dispose();
  });
  test(
    'Disposal while loading does not attempt to update provider state',
    () async {
      final (ref, _, get) = setup();
      final pending = Completer<AppUser>();
      when(() => get.call(const NoParams())).thenAnswer((_) => pending.future);
      final controller = ProfileController(ref);
      await start();
      controller.dispose();
      pending.complete(oldProfile);
      await start();
      expect(controller.mounted, isFalse);
    },
  );
  test(
    'Temporary profile failures preserve data without logout or bootstrap',
    () async {
      final (ref, source, get) = setup();
      var reads = 0;
      when(() => get.call(const NoParams())).thenAnswer((_) async {
        if (++reads == 1) return oldProfile;
        throw StateError('offline');
      });
      final controller = ProfileController(ref);
      await start();
      await controller.refresh();
      expect(controller.state, oldProfile);
      verifyNever(() => source.client);
      controller.dispose();
    },
  );
  test(
    'Confirmed profile update immediately displays avatar and fences stale loads',
    () async {
      final (ref, source, get) = setup();
      var reads = 0;
      final stale = Completer<AppUser>();
      when(
        () => get.call(const NoParams()),
      ).thenAnswer((_) async => ++reads == 1 ? oldProfile : stale.future);
      final client = SupabaseClient(
        'https://example.supabase.co',
        'public',
        httpClient: MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(jsonDecode(request.body)['avatar_url'], newProfile.avatarUrl);
          return http.Response(
            jsonEncode({
              'id': 'alice',
              'email': '',
              'username': 'alice',
              'avatar_url': newProfile.avatarUrl,
            }),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      when(() => source.client).thenReturn(client);
      final controller = ProfileController(ref);
      await start();
      final refresh = controller.refresh();
      await controller.updateProfile(avatarUrl: newProfile.avatarUrl);
      expect(controller.state.avatarUrl, newProfile.avatarUrl);
      stale.complete(oldProfile);
      await refresh;
      expect(controller.state.avatarUrl, newProfile.avatarUrl);
      controller.dispose();
      await client.dispose();
    },
  );
  test(
    'Account change while reading the photo prevents upload under the new account',
    () async {
      final (ref, source, get) = setup();
      when(
        () => get.call(const NoParams()),
      ).thenAnswer((_) async => oldProfile);
      final controller = ProfileController(ref);
      await start();
      final update = controller.updateProfile(
        avatarUrl: File(
          'assets/branding/raster/vibra_app_icon_1024.png',
        ).absolute.path,
      );
      when(() => source.currentUser).thenReturn(user('bob'));
      await expectLater(update, throwsStateError);
      verifyNever(
        () => source.uploadFile(
          any(),
          any(),
          any(),
          contentType: any(named: 'contentType'),
          upsert: false,
        ),
      );
      verifyNever(() => source.client);
      controller.dispose();
    },
  );
  test(
    'Disposed profile cannot PATCH an avatar after an upload completes',
    () async {
      final (ref, source, get) = setup();
      when(
        () => get.call(const NoParams()),
      ).thenAnswer((_) async => oldProfile);
      final uploaded = Completer<String>();
      final started = Completer<void>();
      when(
        () => source.uploadFile(
          any(),
          any(),
          any(),
          contentType: any(named: 'contentType'),
          upsert: false,
        ),
      ).thenAnswer((_) {
        started.complete();
        return uploaded.future;
      });
      final controller = ProfileController(ref);
      await start();
      final update = controller.updateProfile(
        avatarUrl: File(
          'assets/branding/raster/vibra_app_icon_1024.png',
        ).absolute.path,
      );
      await started.future;
      controller.dispose();
      final rejected = expectLater(update, throwsStateError);
      uploaded.complete('https://example.invalid/confirmed-photo.png');
      await rejected;
      verifyNever(() => source.client);
    },
  );
}
