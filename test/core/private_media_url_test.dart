import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/core/services/private_media_url.dart';

void main() {
  const base = 'https://staging.supabase.co';
  const path =
      '12345678-1234-1234-1234-123456789012/12345678-1234-1234-1234-123456789013.png';
  test(
    'legacy signed chat URL becomes authenticated URL without capability',
    () {
      final result = privateChatMediaUri(
        '$base/storage/v1/object/sign/chat-media/$path?token=old',
        base,
      );
      expect(result!.path, '/storage/v1/object/authenticated/chat-media/$path');
      expect(result.query, isEmpty);
    },
  );
  test(
    'rejects arbitrary origins, buckets and traversal before adding credentials',
    () {
      for (final value in [
        'https://evil.invalid/storage/v1/object/sign/chat-media/$path',
        '$base.evil.invalid/storage/v1/object/sign/chat-media/$path',
        '$base/storage/v1/object/sign/avatars/$path',
        '$base/storage/v1/object/sign/chat-media/../secret.png',
        '/storage/v1/object/sign/chat-media/$path',
        'http://staging.supabase.co/storage/v1/object/sign/chat-media/$path',
      ]) {
        expect(privateChatMediaUri(value, base), isNull, reason: value);
      }
    },
  );
}
