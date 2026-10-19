import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/spotify_connect_screen.dart';
import '../../presentation/screens/auth/spotify_unavailable_screen.dart';
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/event_detail/event_detail_screen.dart';
import '../../presentation/screens/explore/explore_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/live/live_screen.dart';
import '../../presentation/screens/onboarding/onboarding_wizard_screen.dart';
import '../../presentation/providers/app_state_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/screens/profile/music_stats_screen.dart';
import '../../presentation/screens/profile/my_events_screen.dart';
import '../../presentation/screens/profile/my_profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/legal_support_screens.dart';
import '../../presentation/screens/profile/help_center_screen.dart';
import '../../presentation/screens/profile/report_problem_screen.dart';
import '../../presentation/screens/profile/privacy_controls_screen.dart';
import '../../presentation/screens/profile/settings_screen.dart';
import '../../presentation/screens/shell/vibra_shell_screen.dart';
import '../../domain/entities/event.dart';

import '../../presentation/screens/social/social_match_screen.dart';
import '../../presentation/screens/social/chat_screen.dart';
import '../../presentation/screens/social/conversations_screen.dart';
import '../../presentation/screens/social/follow_list_screen.dart';
import '../../presentation/screens/social/friends_screen.dart';
import '../../presentation/screens/social/discover_users_screen.dart';
import '../../presentation/screens/social/user_profile_screen.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import 'route_names.dart';

/// Configurazione centralizzata di GoRouter.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter createRouter(Ref ref) {
    final refresh = GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    );
    ref.onDispose(refresh.dispose);
    ref.listen(myProfileProvider, (previous, next) {
      if (previous?.id != next.id ||
          previous?.onboardingCompleted != next.onboardingCompleted ||
          previous?.createdAt != next.createdAt) {
        refresh.profileChanged();
      }
    });
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,
      refreshListenable: refresh,
      observers: <NavigatorObserver>[_NavigationObserver()],
      redirect: (context, state) {
        final currentUser = Supabase.instance.client.auth.currentUser;
        final path = state.uri.path;

        const informationPaths = {
          '/privacy-policy',
          '/terms-of-service',
          '/support',
        };
        if (informationPaths.contains(path)) return null;
        const publicPaths = {'/', '/welcome', '/login', '/spotify-connect'};

        final isPublic = publicPaths.contains(path);
        final isAuthenticated = currentUser != null;

        if (!isAuthenticated && !isPublic) {
          return '/login';
        }

        if (isAuthenticated) {
          final profile = ref.read(myProfileProvider);
          final bool profileLoaded = profile.id.isNotEmpty;
          final bool isLegacyUser =
              profile.createdAt != null &&
              profile.createdAt!.isBefore(DateTime(2026, 7, 27));

          // Se il profilo è caricato e l'onboarding non è completo (e non è un account legacy)
          if (profileLoaded && !profile.onboardingCompleted && !isLegacyUser) {
            if (path != '/onboarding') {
              return '/onboarding';
            }
            return null;
          }

          if (path == '/' || path == '/welcome' || path == '/login') {
            if (profileLoaded &&
                !profile.onboardingCompleted &&
                !isLegacyUser) {
              return '/onboarding';
            }
            return '/home';
          }
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/welcome',
          name: RouteNames.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/spotify-connect',
          name: RouteNames.spotifyConnect,
          builder: (context, state) => const SpotifyConnectScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingWizardScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              VibraShellScreen(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  name: RouteNames.home,
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/explore',
                  name: RouteNames.explore,
                  builder: (context, state) {
                    final initialQuery = state.uri.queryParameters['q'];
                    return ExploreScreen(initialQuery: initialQuery);
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/social-match',
                  name: RouteNames.socialMatch,
                  builder: (context, state) => AppConstants.spotifyEnabled
                      ? const SocialMatchScreen()
                      : const DiscoverUsersScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/conversations',
                  name: RouteNames.conversations,
                  builder: (context, state) => const ConversationsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: RouteNames.profile,
                  builder: (context, state) => const MyProfileScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/event-detail',
          name: RouteNames.eventDetail,
          builder: (context, state) => EventDetailScreen(
            event: state.extra is Event ? state.extra as Event : null,
          ),
        ),
        GoRoute(
          path: '/user-profile',
          name: RouteNames.userProfile,
          builder: (context, state) {
            final extra = state.extra;
            if (extra is String) {
              return UserProfileScreen(userId: extra);
            }
            return const UserProfileScreen();
          },
        ),
        GoRoute(
          path: '/friends',
          name: RouteNames.friends,
          builder: (context, state) => const FriendsScreen(),
        ),
        GoRoute(
          path: '/messages',
          name: RouteNames.messages,
          builder: (context, state) =>
              const ConversationsScreen(showBackButton: true),
        ),
        GoRoute(
          path: '/chat',
          name: RouteNames.chat,
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null;
            return ChatScreen(
              otherUserId: extra?['otherUserId'] as String? ?? '',
              otherDisplayName: extra?['otherDisplayName'] as String? ?? 'Chat',
            );
          },
        ),
        GoRoute(
          path: '/social',
          name: RouteNames.social,
          builder: (context, state) => const DiscoverUsersScreen(),
        ),
        GoRoute(
          path: '/live',
          name: RouteNames.live,
          builder: (context, state) =>
              LiveScreen(initialEventId: state.uri.queryParameters['eventId']),
        ),
        GoRoute(
          path: '/follow-list',
          name: RouteNames.followList,
          builder: (context, state) {
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null;
            return FollowListScreen(
              userId: extra?['userId'] as String? ?? '',
              displayName: extra?['displayName'] as String? ?? 'Utente',
              initialTabIndex: extra?['initialTabIndex'] as int? ?? 0,
            );
          },
        ),
        GoRoute(
          path: '/music-stats',
          name: RouteNames.musicStats,
          builder: (context, state) => AppConstants.spotifyEnabled
              ? const MusicStatsScreen()
              : const SpotifyUnavailableScreen(),
        ),
        GoRoute(
          path: '/my-events',
          name: RouteNames.myEvents,
          builder: (context, state) => const MyEventsScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: RouteNames.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/edit-profile',
          name: RouteNames.editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/privacy-policy',
          name: RouteNames.privacyPolicy,
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/privacy-controls',
          builder: (context, state) => const PrivacyControlsScreen(),
        ),
        GoRoute(
          path: '/terms-of-service',
          name: RouteNames.termsOfService,
          builder: (context, state) => const TermsOfServiceScreen(),
        ),
        GoRoute(
          path: '/support',
          name: RouteNames.support,
          builder: (context, state) => const SupportScreen(),
        ),
        GoRoute(
          path: '/help-center',
          name: RouteNames.helpCenter,
          builder: (context, state) => const HelpCenterScreen(),
        ),
        GoRoute(
          path: '/report-problem',
          name: RouteNames.reportProblem,
          builder: (context, state) => ReportProblemScreen(
            initialDescription: state.extra is String
                ? state.extra as String
                : null,
          ),
        ),
        GoRoute(
          path: '/about',
          name: RouteNames.about,
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    );
  }
}

class _NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    VibraLogger.navigation(route.settings.name ?? route.settings.toString());
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.asBroadcastStream().listen((AuthState authState) {
      final userId = authState.session?.user.id;
      if (userId != _userId || !_initialized) {
        _initialized = true;
        _userId = userId;
        notifyListeners();
      }
    });
  }

  String? _userId;
  bool _initialized = false;

  void profileChanged() => notifyListeners();
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
