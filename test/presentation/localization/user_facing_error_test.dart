import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/localization/user_facing_error.dart';

void main() {
  for (final locale in ['it', 'en', 'es', 'fr', 'de']) {
    final l10n = lookupAppLocalizations(Locale(locale));
    test('$locale: legacy auth errors use the selected language', () {
      expect(
        userFacingError(l10n, 'Credenziali non valide. Controlla la password.'),
        l10n.authInvalidCredentials,
      );
      expect(
        userFacingError(l10n, 'email_not_confirmed'),
        l10n.authEmailNotConfirmed,
      );
      expect(
        userFacingError(l10n, 'Registrazione completata con successo!'),
        l10n.authConfirmEmail,
      );
    });
    test('$locale: unknown service diagnostics are never displayed', () {
      const diagnostic = 'PostgrestException: SELECT private_field secret=abc';
      final text = userFacingError(l10n, diagnostic);
      expect(text, l10n.errorActionFailed);
      expect(text, isNot(contains('SELECT')));
      expect(text, isNot(contains('secret')));
      expect(
        userFacingError(l10n, 'SocketException: failed host lookup'),
        l10n.errorNetwork,
      );
    });
    test('$locale: event and unread counts use singular forms', () {
      expect(l10n.exploreEventsInArea(1), isNot(l10n.exploreEventsInArea(2)));
      expect(l10n.inboxUnreadCount(1), isNot(l10n.inboxUnreadCount(2)));
      expect(l10n.exploreEventsVisible(0), contains('0'));
    });
  }
  test('registration confirmation detection is independent of UI locale', () {
    expect(
      isRegistrationConfirmation('Registrazione completata con successo!'),
      isTrue,
    );
    expect(isRegistrationConfirmation('invalid_credentials'), isFalse);
    expect(isRegistrationConfirmation(null), isFalse);
  });
}
