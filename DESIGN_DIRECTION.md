# Vibra — Signal Paper

## Intento

Vibra passa da una UI **dark-neon / glassmorphism** a un social musicale editoriale: più vicino a un poster vivo che a una dashboard di eventi. Il sistema mantiene tutte le informazioni e le azioni esistenti, ma assegna loro una gerarchia più netta.

**Parole guida:** editoriale, sociale, fisico, diretto, ritmico.

**Da evitare:** gradienti decorativi, glow, rainbow badge, superfici glass, card ripetute con immagine + titolo + bottone.

## Moodboard / tokens

| Ruolo | Token | Valore |
| --- | --- | --- |
| Canvas | `canvas` | `#F6F4EE` |
| Superficie | `surface` | `#FFFEF8` |
| Inchiostro | `ink` | `#151513` |
| Testo secondario | `muted` | `#706F68` |
| Linea | `line` | `#DCD9D0` |
| Segnale Vibra | `signal` | `#C9FF45` |
| Eco / focus | `echo` | `#5A57E8` |

`signal` è il solo accento dominante: riempie azioni sociali, meter e stati selezionati; non viene usato come testo piccolo su canvas. `echo` è raro e riservato a focus/input e dettagli informativi. Errori e avvisi restano puramente semantici.

### Tipografia

- **Syne** — display, metriche, nomi e titoli: grande, sicura, con spazio intorno.
- **Inter** — corpo, metadati e controlli: calma e leggibile.

JetBrains Mono esce dal sistema: gli score devono sembrare parte della cultura musicale, non di una dashboard tecnica.

Scala principale: Syne 48/44, 32/34, 24/27; Inter 16/22, 14/20, 12/14. Le maiuscole servono soltanto alle label brevi (`STASERA`, `AFFINITÀ`).

### Firma Vibra: doppia onda continua

Un `CustomPainter` disegna due tracce morbide, sfasate e a tinta unica. L'onda non è un'icona isolata: è la texture e il comportamento del prodotto.

- piccola: marchio / stato Spotify;
- ampia e ritagliata: sfondo di profilo e sezioni;
- lineare: meter di affinità e listening rhythm;
- pulsante: loading e beacon del marker selezionato.

Niente equalizzatori a barrette, radar o cuore geometrico. Il movimento è lento e leggero, come un segnale che trova stabilità.

## Componenti di base

| Componente | Regola |
| --- | --- |
| `VibraSurface` | piano opaco, bordo hairline, nessun blur o ombra diffusa |
| `VibraButton` | 48–52 px, raggio 14; ink per azioni standard, signal per la CTA sociale |
| `VibraInput` | campo piano e sobrio, focus echo, nessuna pill glass |
| `VibraAvatar` | bordo canvas, fallback ink/signal, mai palette casuale rainbow |
| `VibraSignalWave` | doppia onda riutilizzabile in formato texture, meter e loading |
| `VibraAffinityScore` | numero Syne + onda a intensità crescente, sostituisce gauge/semaforo |
| `VibraEventFeature` | poster alto editoriale, data in colonna e nessun bottone interno |
| `VibraEventRow` | riga data/titolo/luogo/meter con divider, sostituisce le card compatte |

## Applicazione alle aree

### Home

Header temporale piccolo e saluto display; Spotify come stato inline. L'evento consigliato è un poster verticale dominante con una porzione del successivo visibile, non un carousel di card standard. Vicino e trend diventano righe editoriali. Il completamento profilo è una action line compatta e non compete con il contenuto.

### Eventi / Mappa

Ricerca, raggio e genere restano, ma diventano una filter rail compatta su una mappa tonal/no-label. I marker usano tutti `ink + signal`; genere e priorità sono leggibili tramite forma, label e densità, non mediante colori diversi. Un event dock sovrapposto alla mappa porta alla lista di righe. Per una cartografia totalmente proprietaria servirà in seguito un provider vector-styled: gli attuali raster tile possono essere resi coerenti ma non ridisegnati strada per strada.

### Vibra / Match

Swipe, passa e invia Vibra restano. Il gauge a semaforo diventa un numero grande e un meter a onda monochrome. La card assume una composizione a ritratto, con due ragioni del match presentate come righe editoriali. Lo scanning usa un'onda in movimento e non cerchi radar.

### Chat

Inbox con titolo a sinistra, tab testuali e righe conversazione essenziali. Il non letto usa contrasto tipografico e un punto signal, non badge, bordo e icone insieme. Ricerca, richieste, refresh, cancellazione e chat realtime restano. Il dettaglio chat usa bubble ink/surface e composer pulito.

### Profilo / statistiche

Avatar sovrapposto a un'onda ritagliata, nome grande e contatori come triplet tipografica. Spotify diventa stato inline. Artisti diventano una classifica-poster, generi un elenco tipografico e la heatmap un `Listening rhythm` monocromatico.

## Motion

Firma unica: compressione lieve e rilascio calmo.

- curva: `Cubic(0.22, 1.0, 0.36, 1.0)`;
- tap: 0.98 in 90 ms, rilascio 180–220 ms;
- ingresso: fade + 12 px in 320–380 ms, massimo tre elementi in stagger;
- pagina: fade/slide 420 ms;
- score: count-up + onda in 650 ms;
- onda idle: fase lenta in 4–6 s;
- rispettare `MediaQuery.disableAnimations` e non comunicare mai stato soltanto con il colore.
