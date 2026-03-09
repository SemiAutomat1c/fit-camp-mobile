import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/onboarding/goal_selection_screen.dart';
import '../../features/auth/presentation/screens/onboarding/waiver_screen.dart';
import '../../features/auth/presentation/screens/onboarding/pre_assessment_screen.dart';
import '../../features/auth/presentation/screens/onboarding/profile_setup_screen.dart';
import '../../features/booking/presentation/screens/booking_calendar_screen.dart';
import '../../features/booking/presentation/screens/booking_home_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/chat/presentation/screens/chat_tab_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/training/domain/entities/diet_plan.dart';
import '../../features/training/domain/entities/training_plan.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/training/presentation/screens/diet_plan_detail_screen.dart';
import '../../features/progress/presentation/screens/log_progress_screen.dart';
import '../../features/progress/presentation/screens/progress_home_screen.dart'
    as progress_screens;
import '../../features/training/presentation/screens/training_home_screen.dart'
    as training_screens;
import '../../features/training/presentation/screens/training_plan_detail_screen.dart';
import '../widgets/main_scaffold.dart';

// ---------------------------------------------------------------------------
// App initialization state machine
// ---------------------------------------------------------------------------

/// Represents the stage the app is in during startup.
///
/// GoRouter's redirect uses this to push the user to the correct screen
/// without any manual [Navigator.push] calls.
enum AppInitState {
  /// Auth check in progress — show splash screen
  loading,

  /// No valid auth token found — route to login
  unauthenticated,

  /// User authenticated but onboarding not complete
  needsOnboarding,

  /// Fully authenticated and onboarded — allow free navigation
  ready,
}

/// Global app init state provider.
///
/// Sprint 1's `AuthNotifier` will update this after checking the stored token.
/// Sprint 0 only transitions from [AppInitState.loading] to
/// [AppInitState.unauthenticated] via the splash screen timer.
final StateProvider<AppInitState> appInitProvider =
    StateProvider<AppInitState>(
  (ref) => AppInitState.loading,
  name: 'appInitProvider',
);

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

/// Provides the configured [GoRouter] instance.
///
/// Uses a standard [Provider] (not @riverpod) to avoid circular dependency
/// with [appInitProvider] inside the redirect callback.
///
/// The router is intentionally not Riverpod-generated so that [ref.read]
/// inside [redirect] always accesses the current provider value synchronously.
final Provider<GoRouter> routerProvider = Provider<GoRouter>(
  (ref) {
    // Notifier that triggers GoRouter to re-evaluate redirects when
    // appInitProvider changes.
    final notifier = _AppInitNotifier(ref);

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: notifier,
      redirect: (context, state) {
        final initState = ref.read(appInitProvider);
        switch (initState) {
          case AppInitState.loading:
            return state.matchedLocation == '/splash' ? null : '/splash';
          case AppInitState.unauthenticated:
            const unauthAllowed = {'/login', '/forgot-password', '/reset-password'};
            return unauthAllowed.contains(state.matchedLocation) ? null : '/login';
          case AppInitState.needsOnboarding:
            return state.matchedLocation.startsWith('/onboarding')
                ? null
                : '/onboarding/goal';
          case AppInitState.ready:
            // Redirect away from auth-only screens when already authenticated.
            final isAuthScreen = state.matchedLocation == '/splash' ||
                state.matchedLocation == '/login' ||
                state.matchedLocation.startsWith('/onboarding');
            return isAuthScreen ? '/home' : null;
        }
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) =>
              ResetPasswordScreen(email: state.extra as String? ?? ''),
        ),
        GoRoute(
          path: '/onboarding/goal',
          builder: (context, state) => const GoalSelectionScreen(),
        ),
        GoRoute(
          path: '/onboarding/waiver',
          builder: (context, state) => const WaiverScreen(),
        ),
        GoRoute(
          path: '/onboarding/assessment',
          builder: (context, state) => const PreAssessmentScreen(),
        ),
        GoRoute(
          path: '/onboarding/profile-setup',
          builder: (context, state) => const ProfileSetupScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/booking',
              builder: (context, state) => const BookingHomeScreen(),
              routes: [
                GoRoute(
                  path: 'calendar',
                  builder: (context, state) => const BookingCalendarScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatTabScreen(),
            ),
            GoRoute(
              path: '/training',
              builder: (context, state) =>
                  const training_screens.TrainingHomeScreen(),
              routes: [
                GoRoute(
                  path: 'workout/:planId',
                  pageBuilder: (context, state) {
                    final plan = state.extra as TrainingPlan?;
                    if (plan == null) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => context.go('/training'),
                      );
                      return fadeSlideTransition(
                        key: state.pageKey,
                        child: const SizedBox.shrink(),
                      );
                    }
                    return fadeSlideTransition(
                      key: state.pageKey,
                      child: TrainingPlanDetailScreen(plan: plan),
                    );
                  },
                ),
                GoRoute(
                  path: 'diet/:planId',
                  pageBuilder: (context, state) {
                    final plan = state.extra as DietPlan?;
                    if (plan == null) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => context.go('/training'),
                      );
                      return fadeSlideTransition(
                        key: state.pageKey,
                        child: const SizedBox.shrink(),
                      );
                    }
                    return fadeSlideTransition(
                      key: state.pageKey,
                      child: DietPlanDetailScreen(plan: plan),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/progress',
              builder: (context, state) =>
                  const progress_screens.ProgressHomeScreen(),
              routes: [
                GoRoute(
                  path: 'log',
                  builder: (context, state) => const LogProgressScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/chat/:conversationId',
          pageBuilder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return fadeSlideTransition(
              key: state.pageKey,
              child: ChatRoomScreen(
                conversationId: conversationId,
                otherName: extra?['name'] as String? ?? 'Chat',
                otherAvatarUrl: extra?['avatarUrl'] as String?,
              ),
            );
          },
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => slideUpTransition(
            key: state.pageKey,
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => slideUpTransition(
            key: state.pageKey,
            child: const NotificationsScreen(),
          ),
        ),
      ],
    );
  },
  name: 'routerProvider',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// [ChangeNotifier] that calls [notifyListeners] whenever [appInitProvider]
/// changes, causing GoRouter to re-evaluate the redirect.
class _AppInitNotifier extends ChangeNotifier {
  _AppInitNotifier(Ref ref) {
    ref.listen<AppInitState>(appInitProvider, (_, __) => notifyListeners());
  }
}

// ---------------------------------------------------------------------------
// Custom page transitions
// ---------------------------------------------------------------------------

/// Fade + slide-right transition for detail screens.
CustomTransitionPage<T> fadeSlideTransition<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Slide-up transition for modal/overlay screens.
CustomTransitionPage<T> slideUpTransition<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}
