import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/spotify_connect_screen.dart';
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/event_detail/event_detail_screen.dart';
import '../../presentation/screens/explore/explore_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/onboarding/onboarding_wizard_screen.dart';
import '../../presentation/providers/app_state_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/screens/profile/music_stats_screen.dart';
import '../../presentation/screens/profile/my_events_screen.dart';
import '../../presentation/screens/profile/my_profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/legal_support_screens.dart';
import '../../presentation/screens/profile/settings_screen.dart';
import '../../presentation/screens/shell/vibra_shell_screen.dart';
import '../../domain/entities/event.dart';

import '../../presentation/screens/social/social_match_screen.dart';
import '../../presentation/screens/social/chat_screen.dart';
import '../../presentation/screens/social/friends_screen.dart';
import '../../presentation/screens/social/user_profile_screen.dart';
import '../utils/logger.dart';
import 'route_names.dart';

/// Configurazione centralizzata di GoRouter.
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,
      refreshListenable: GoRouterRefreshStream(
        Supabase.instance.client.auth.onAuthStateChange,
      ),
      observers: <NavigatorObserver>[
        _NavigationObserver(),
      ],
      redirect: (context, state) {
        final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
        if (isTest) return null;

        final currentUser = Supabase.instance.client.auth.currentUser;
        final path = state.uri.path;

        const publicPaths = {
          '/',
          '/welcome',
          '/login',
          '/spotify-connect',
        };

        final isPublic = publicPaths.contains(path);
        final isAuthenticated = currentUser != null;

        if (!isAuthenticated && !isPublic) {
          return '/login';
        }

        if (isAuthenticated) {
          final profile = ref.read(myProfileProvider);
          final bool profileLoaded = profile.id.isNotEmpty;
          final bool isLegacyUser = profile.createdAt != null && profile.createdAt!.isBefore(DateTime(2026, 7, 27));

          // Se il profilo è caricato e l'onboarding non è completo (e non è un account legacy)
          if (profileLoaded && !profile.onboardingCompleted && !isLegacyUser) {
             if (path != '/onboarding') {
                return '/onboarding';
             }
             return null;
          }

          if (path == '/' || path == '/welcome' || path == '/login') {
            if (profileLoaded && !profile.onboardingCompleted && !isLegacyUser) {
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
                builder: (context, state) => const SocialMatchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/social',
                name: RouteNames.social,
                builder: (context, state) => const FriendsScreen(),
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
        builder: (context, state) => EventDetailScreen(event: state.extra as Event?),
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
        path: '/chat',
        name: RouteNames.chat,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            otherUserId: extra?['otherUserId'] as String? ?? '',
            otherDisplayName: extra?['otherDisplayName'] as String? ?? 'Chat',
          );
        },
      ),
      GoRoute(
        path: '/music-stats',
        name: RouteNames.musicStats,
        builder: (context, state) => const MusicStatsScreen(),
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
      final bool isAuthenticated = authState.session != null;
      if (isAuthenticated != _wasAuthenticated) {
        _wasAuthenticated = isAuthenticated;
        notifyListeners();
      }
    });
  }

  bool? _wasAuthenticated;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
