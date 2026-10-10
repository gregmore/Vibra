import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/core/config/push_token_registration.dart';

void main() {
  testWidgets('late APNs token is retried and persisted', (tester) async {
    var reads = 0;
    final saved = <String>[];
    final registration = PushTokenRegistration(
      readToken: () async => ++reads == 1 ? null : 'ready-token',
      persistToken: (token) async => saved.add(token),
      isActive: () => true,
      onError: (_, _) => fail('Unexpected error'),
    );
    await registration.synchronize();
    expect(saved, isEmpty);
    await tester.pump(const Duration(seconds: 3));
    expect(saved, ['ready-token']);
    registration.dispose();
  });

  testWidgets('network failure retries but stops after disposal', (
    tester,
  ) async {
    var reads = 0;
    var errors = 0;
    final registration = PushTokenRegistration(
      readToken: () async {
        reads++;
        throw StateError('offline');
      },
      persistToken: (_) async => fail('Unexpected persistence'),
      isActive: () => true,
      onError: (_, _) => errors++,
    );
    await registration.synchronize();
    await tester.pump(const Duration(seconds: 3));
    expect(reads, 2);
    expect(errors, 2);
    registration.dispose();
    await tester.pump(const Duration(seconds: 30));
    expect(reads, 2);
  });

  testWidgets(
    'a new synchronization restarts after APNs retries are exhausted',
    (tester) async {
      var reads = 0;
      String? availableToken;
      final saved = <String>[];
      final registration = PushTokenRegistration(
        readToken: () async {
          reads++;
          return availableToken;
        },
        persistToken: (token) async => saved.add(token),
        isActive: () => true,
        onError: (_, _) => fail('Unexpected error'),
        maxAttempts: 2,
      );
      await registration.synchronize();
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 30));
      expect(reads, 2);
      expect(saved, isEmpty);

      // Re-enabling push calls synchronize again, even after a previous timeout.
      availableToken = 'new-token';
      await registration.synchronize();
      expect(reads, 3);
      expect(saved, ['new-token']);
      registration.dispose();
    },
  );

  test('logout while token is loading prevents persistence', () async {
    var signedIn = true;
    final token = Completer<String?>();
    final registration = PushTokenRegistration(
      readToken: () => token.future,
      persistToken: (_) async => fail('Token must not be saved after logout'),
      isActive: () => signedIn,
      onError: (_, _) => fail('Unexpected error'),
    );
    final pending = registration.synchronize();
    signedIn = false;
    token.complete('ready-token');
    await pending;
    registration.dispose();
  });
}
