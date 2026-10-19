# Vibra Brand Pack

Il marchio dell'app è una V formata da due onde continue: musica e incontro.
L'icona nativa usa il viola `#7C3AED` e il simbolo bianco su fondo opaco.
Il marchio nelle schermate segue il tema chiaro/scuro.

- `vibra_app_icon.svg`: sorgente vettoriale scalabile.
- `raster/vibra_app_icon_1024.png`: icona store.
- `raster/vibra_play_feature_graphic_1024x500.png`: feature graphic Google
  Play, con lo stesso simbolo V bianco su viola e il testo “La tua musica.
  Le tue persone.” nei font locali Syne e Inter.
- `lib/presentation/widgets/common/vibra_logo.dart`: geometria Flutter condivisa
  con l'esportazione nativa.
- `script/branding/generate_brand_assets_test.dart`: rigenera le icone iOS,
  Android, l'anteprima e la feature graphic da quella stessa geometria.
  Le immagini esportate sono PNG RGB opachi; il codice è anche la sorgente
  della composizione della feature graphic.

```bash
flutter test script/branding/generate_brand_assets_test.dart
```

Gli altri visual promozionali restano disponibili come materiali precedenti;
prima di usarli per una nuova campagna vanno riallineati al marchio attuale.
