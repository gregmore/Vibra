import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/common/vibra_page_scaffold.dart';

class SpotifyUnavailableScreen extends StatelessWidget {
  const SpotifyUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.spotifyUnavailableTitle)),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.music_off_rounded, size: 48),
              const SizedBox(height: 20),
              Text(l10n.spotifyUnavailableBody, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/explore'),
                child: Text(l10n.navEvents),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
