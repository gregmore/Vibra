# Verifiche native isolate

`native_security_test.dart.template` conserva i controlli di secure storage e
TLS su device. Sono separati dall'app perché il plugin Flutter `integration_test`
può entrare anche nel bundle iOS quando è una dipendenza di sviluppo del progetto.
Il progetto di produzione non dipende più da questo plugin.

Per eseguirli, creare un progetto Flutter temporaneo dedicato con
`flutter_secure_storage` 10.3.1 nelle dipendenze e `integration_test` / `flutter_test`
dell'SDK nelle dev dependencies. Copiare il template in
`integration_test/native_security_test.dart`, poi eseguire `flutter test` sul
simulatore/device selezionato. La verifica TLS richiede `VIBRA_TEST_TLS_CERT` e
`VIBRA_TEST_TLS_KEY` (base64) di un certificato sintetico con SAN `127.0.0.1` e
relativa chiave. Non usare certificati o token di produzione.

Il rapporto QA precedente segnala un controllo TLS positivo fallito su iOS:
non considerare questa verifica completata finché fixture e trust non sono
stati validati. Il passaggio di secure storage resta un controllo separato.
