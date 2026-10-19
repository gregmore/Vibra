import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/vibra_signal_wave.dart';
import '../../providers/app_state_providers.dart';

import 'package:vibra/l10n/app_localizations.dart';

/// La navigazione principale resta ancorata al canvas: nessuna card sospesa,
/// nessun blur. Il segnale a onda identifica la sezione Vibra attiva.
class VibraShellScreen extends ConsumerWidget {
  const VibraShellScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final badges = ref.watch(globalBadgeCountsProvider);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surfaceElevated,
          border: Border(top: BorderSide(color: t.borderDefault)),
          boxShadow: Theme.of(context).brightness == Brightness.light
              ? [t.cardShadow]
              : null,
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(8, 6, 8, 4),
          child: NavigationBar(
            height: 68,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore_rounded),
                label: l10n.navEvents,
              ),
              NavigationDestination(
                icon: Badge.count(
                  count: badges.pendingFriendships,
                  isLabelVisible: badges.pendingFriendships > 0,
                  child: Icon(
                    AppConstants.spotifyEnabled
                        ? Icons.favorite_border_rounded
                        : Icons.people_outline_rounded,
                  ),
                ),
                selectedIcon: Badge.count(
                  count: badges.pendingFriendships,
                  isLabelVisible: badges.pendingFriendships > 0,
                  child: SizedBox(
                    width: 26,
                    height: 18,
                    child: VibraSignalWave(
                      height: 18,
                      color: t.accentPrimary,
                      secondaryColor: t.accentPrimary,
                      amplitude: 3.4,
                      strokeWidth: 1.8,
                      animate: true,
                    ),
                  ),
                ),
                label: AppConstants.spotifyEnabled
                    ? l10n.navVibra
                    : l10n.socialTitle,
              ),
              NavigationDestination(
                icon: Badge.count(
                  count: badges.unreadMessages,
                  isLabelVisible: badges.unreadMessages > 0,
                  child: const Icon(Icons.chat_bubble_outline_rounded),
                ),
                selectedIcon: Badge.count(
                  count: badges.unreadMessages,
                  isLabelVisible: badges.unreadMessages > 0,
                  child: const Icon(Icons.chat_bubble_rounded),
                ),
                label: l10n.navChat,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: l10n.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
