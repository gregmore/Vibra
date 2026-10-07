import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native secure storage round trip and deletion', (tester) async {
    const storage = FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.unlocked_this_device,
      ),
    );
    const key = 'vibra_security_synthetic_probe';
    try {
      await storage.write(key: key, value: 'synthetic-token');
      expect(await storage.read(key: key), 'synthetic-token');
      await storage.delete(key: key);
      expect(await storage.read(key: key), isNull);
    } finally {
      await storage.delete(key: key);
    }
  });
  testWidgets(
    'native TLS rejects untrusted certificate; trusted control succeeds',
    (tester) async {
      final cert = base64Decode(
        const String.fromEnvironment('VIBRA_TEST_TLS_CERT'),
      );
      final key = base64Decode(
        const String.fromEnvironment('VIBRA_TEST_TLS_KEY'),
      );
      final context = SecurityContext()
        ..useCertificateChainBytes(cert)
        ..usePrivateKeyBytes(key);
      final server = await HttpServer.bindSecure(
        InternetAddress.loopbackIPv4,
        0,
        context,
      );
      server.listen((request) {
        request.response.write('synthetic TLS');
        request.response.close();
      }, onError: (Object error) {});
      final uri = Uri.parse('https://127.0.0.1:${server.port}/');
      final untrusted = HttpClient();
      final trusted = HttpClient(
        context: SecurityContext()..setTrustedCertificatesBytes(cert),
      );
      try {
        await expectLater(
          untrusted.getUrl(uri),
          throwsA(isA<HandshakeException>()),
        );
        final response = await (await trusted.getUrl(uri)).close();
        expect(await response.transform(utf8.decoder).join(), 'synthetic TLS');
      } finally {
        untrusted.close(force: true);
        trusted.close(force: true);
        await server.close(force: true);
      }
    },
  );
}
