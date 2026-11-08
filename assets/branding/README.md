# Vibra Brand Pack

Il marchio è la **V geometrica VIBRA** fornita dal brand: contorno
arrotondato, banda nera, V piena. Bianco su nero è la versione principale;
nero su bianco è la variante chiara.

- `source/`: i file originali del logo, **non modificati**. Sono l'unica
  sorgente da cui derivano tutte le immagini.
  - `vibra_logo_white_on_black_1024.jpg` (master)
  - `vibra_logo_black_on_white_1024.jpg`
  - `vibra_logo_white_transparent_500.png`, `vibra_logo_black_transparent_500.png`
- `logo/vibra_mark.png`: marchio bianco su trasparente, ritagliato dal master.
  Usato in app da `VibraLogo` e colorato in base al tema (bianco su scuro,
  nero su chiaro) senza alterarne la geometria.
- `logo/vibra_splash_mark.png`: marchio per le launch screen native
  (iOS, Android, Android 12) su fondo `#000000`.
- `raster/vibra_app_icon_1024.png`: icona store (master ricampionato, RGB opaco).
- `raster/vibra_play_feature_graphic_1024x500.png`: feature graphic Google
  Play — marchio, wordmark “VIBRA” e “La tua musica. Le tue persone.” in Inter.

Rigenerare icone iOS/Android, marchio, splash e feature graphic:

```bash
flutter test script/branding/generate_brand_assets_test.dart
dart run flutter_native_splash:create
```

Lo script ritaglia, ricampiona e converte la luminanza in trasparenza:
non ridisegna mai il marchio.

Gli altri visual promozionali (`vibra_store_hero`, `vibra_splash_visual`,
`vibra_portrait_promo`) usano il marchio precedente e vanno riallineati
prima di una nuova campagna.
