# Verifica traduzioni Vibra — 14 ottobre 2026

Le cinque lingue supportate (italiano, inglese, spagnolo, francese e tedesco) ora
contengono lo stesso catalogo di **680 messaggi** e gli stessi tipi dei parametri.
Il controllo statico non rileva testi diretti dell’interfaccia fuori dal catalogo,
chiavi mancanti, chiavi JSON duplicate, messaggi vuoti o sequenze `\\n` visibili.

```sh
python3 script/l10n/audit_localizations.py --json
```

Sono stati localizzati onboarding, foto e modifica profilo, impostazioni privacy,
esportazione dati, tema, FAQ, Home, schede eventi, Live, social, amicizie, chat,
segnalazioni e testi di accessibilità. Date, mesi, giorni della settimana e prezzi
seguono la lingua dell’app; i contatori degli eventi e dei messaggi distinguono
singolare e plurale. I nomi propri, i nomi di utenti e gli eventi conservano la
loro identità. La traduzione online delle descrizioni degli eventi ignora le
risposte di richieste precedenti quando cambia lingua o evento; se il servizio
non risponde viene mostrata la descrizione originale.

Gli errori dei servizi sono convertiti in messaggi localizzati e comprensibili:
credenziali errate, email da confermare, rete assente, sessione cambiata e limiti
di richieste. SQL, token e dettagli diagnostici sconosciuti non compaiono nei
messaggi mostrati all’utente. La conferma di registrazione funziona in tutte le
lingue anche se il provider conserva un identificatore storico italiano.

La pagina Amici mostra il caricamento o un errore con Riprova, invece di una
lista apparentemente vuota. Amici e nomi delle richieste usano i profili pubblici
indipendenti da Spotify. Le categorie FAQ usano identificatori stabili, quindi
una scelta rimane valida quando si cambia lingua.

I test aggiunti sono in `test/presentation/localization/`: conversione errori e
contatori nelle cinque lingue, cambio tedesco→inglese nelle FAQ, caricamento e
ripetizione del caricamento degli amici. L’esecuzione Flutter e i risultati sono
coordinati dal controllo complessivo della nuova candidata.

Il controllo statico verifica i cataloghi e i testi diretti del codice Dart;
non costituisce una revisione linguistica professionale di testi inviati dagli
utenti o dai fornitori degli eventi.
