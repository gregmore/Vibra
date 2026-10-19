# Audit di accessibilità Vibra — 27 agosto 2026

## Ambito e metodo

Audit statico dei widget Flutter e dei flussi onboarding, esplorazione eventi,
chat/messaggi, match e navigazione principale. La verifica automatica ha
incluso `dart analyze` e gli smoke test dei controlli/navigazione. I test con
tecnologie assistive richiedono ancora una sessione su dispositivo reale:
questa non può essere sostituita dall'analisi del codice.

## Risultati e correzioni applicate

| Gravità iniziale | Criticità | Correzione |
| --- | --- | --- |
| Alta | CTA primaria con testo bianco su verde signal (1.17:1) | `VibraPillButton` usa ora testo inchiostro: 15.56:1. |
| Alta | Card evento, righe evento e conversazioni non esprimevano sempre azione, contenuto e non-letti in un'unica semantica | Aggiunte semantiche descrittive; i punteggi e i non-letti sono live region. |
| Alta | I filtri selezionati dipendevano soprattutto dal colore e non esponevano lo stato in modo esplicito | Check visibile, bordo da 2 px e stato `selected` per screen reader. |
| Media | Zoom mappa a 42×42 e chip/CTA con dimensione non garantita | Target mappa portati a 48×48; componenti CTA/chip usano altezza minima 48. |
| Media | Icone critiche senza testo (indietro, annulla ricerca, invia, copia, profilo) | Aggiunti tooltip/semantiche descrittive nei flussi principali. |
| Media | Gauge/affinità cambiavano solo visivamente | Valore semantico e `liveRegion` per l'annuncio al cambio. |
| Media | Parte delle animazioni ignorava “Riduci movimento” | Helper `VibraMotion.durationFor`; applicato a CTA, superfici, filtri e card; gauge e animazione d'ingresso evento rispettano `disableAnimations`. |
| Bassa | Onda grafica nella tab attiva poteva essere letta due volte | Marcata decorativa; la label resta quella nativa della `NavigationDestination`. |

## Contrasto verificato (WCAG 2.1 AA)

| Coppia | Rapporto | Esito |
| --- | ---: | --- |
| Testo secondario `#706F68` su `#FFFEF8` | 4.99:1 | AA testo normale |
| Testo secondario `#706F68` su canvas `#F6F4EE` | 4.59:1 | AA testo normale |
| Inchiostro `#151513` su signal `#C9FF45` | 15.56:1 | AAA |
| Echo `#5A57E8` su paper `#FFFEF8` | 5.24:1 | AA testo normale |

Il tema attivo è chiaro; non è stata rilevata una schermata viola scura nel
percorso tema corrente. Ogni testo sovrapposto a immagini resta comunque da
validare con screenshot reali, perché il contrasto dipende dalla fotografia.

## Rischi residui da chiudere con QA manuale

1. **Alta — VoiceOver iOS:** attivare VoiceOver e percorrere onboarding,
   ricerca con mappa e filtri, apertura evento, elenco conversazioni e chat,
   schermata match. Confermare ordine alto→basso e che non vengano letti
   poster/onde/texture decorative.
2. **Alta — TalkBack Android:** ripetere i flussi, inclusi marker della mappa,
   popup menu chat e badge non letti. Verificare che il focus resti sul
   controllo attivato dopo invio messaggio o cambio filtro.
3. **Media — dimensione testo:** su entrambi i sistemi provare 100%, 130%,
   160% e la dimensione massima. Controllare soprattutto titoli evento,
   bottom navigation, compositore chat, pulsanti e sheet onboarding.
4. **Media — input alternativi:** attivare Switch Control iOS e navigazione
   da tastiera Android/ChromeOS: tutti gli elementi devono avere un solo stop
   logico e un indicatore di focus visibile.
5. **Media — Riduci movimento:** attivarlo prima di onboarding, ricerca e
   match. Le animazioni corrette devono essere istantanee; le animazioni
   `flutter_animate` legacy rimanenti devono essere censite e migrate allo
   stesso helper prima della dichiarazione di conformità completa.

## Esito

Le criticità principali individuate nel codice sono state corrette. Il rilascio
non va dichiarato “testato con VoiceOver/TalkBack” finché i cinque controlli
manuali sopra non sono eseguiti e registrati su una build candidata.
