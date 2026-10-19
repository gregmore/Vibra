# Vibra — verifica accessibilità dei temi

I token in `lib/core/theme/vibra_theme_tokens.dart` sono verificati per ruolo,
separatamente per ciascun tema. I testi normali usano `textPrimary` e
`textSecondary` solo sulle rispettive superfici neutre; i CTA hanno testo
`onAccent` su `accentPrimary` e non usano il gradiente come unico indicatore.

| Ruolo | Dark | Light | Criterio |
| --- | --- | --- | --- |
| Testo primario / sfondo | `#FFFFFF` / `#0D0A14` | `#14101C` / `#FFFFFF` | AAA |
| Testo secondario / sfondo | `#B8AFC7` / `#0D0A14` | `#6B6478` / `#FFFFFF` | AA testo normale |
| Errore / superficie | `#F87171` / `#1A1425` | `#B42318` / `#FFFFFF` | AA testo normale |
| Successo / superficie | `#4ADE80` / `#1A1425` | `#16803A` / `#FFFFFF` | AA testo normale |

Le locandine mantengono sempre `imageOverlay` scuro, quindi il testo bianco
sulle immagini non dipende dal tema dell’app. Il selettore Aspetto usa controlli
radio con stato selezionato e label semantiche, non solo il colore.
