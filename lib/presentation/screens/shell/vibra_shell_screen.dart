import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../../widgets/common/vibra_bottom_navigation.dart';
import '../../widgets/common/vibra_logo.dart';

/// Main shell: five existing destinations on the VIBRA navigation bar.
/// The social destination uses the VIBRA mark itself as its selected glyph.
class VibraShellScreen extends ConsumerWidget {
  const VibraShellScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final badges = ref.watch(globalBadgeCountsProvider);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: VibraBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          VibraNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: l10n.navHome,
          ),
          VibraNavItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore_rounded,
            label: l10n.navEvents,
          ),
          // People hub for everyone; the VIBRA mark marks it when active.
          VibraNavItem(
            icon: Icons.people_outline_rounded,
            selectedIcon: Icons.people_rounded,
            label: l10n.socialTitle,
            badgeCount: badges.pendingFriendships,
            selectedBuilder: (context) => VibraLogo(
              width: 24,
              height: 21,
              color: context.vibraTokens.accentPrimary,
            ),
          ),
          VibraNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            selectedIcon: Icons.chat_bubble_rounded,
            label: l10n.navChat,
            badgeCount: badges.unreadMessages,
          ),
          VibraNavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
