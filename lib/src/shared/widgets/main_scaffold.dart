import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../core/services/convex_provider.dart';
import '../../features/chat/presentation/providers/chat_provider.dart';
import '../../features/notifications/presentation/widgets/notification_bell.dart';
import '../theme/app_colors.dart';
import 'connectivity_banner.dart';

// ---------------------------------------------------------------------------
// Role provider (re-exported from convex_provider for backward compat)
// ---------------------------------------------------------------------------

// _roleProvider is an alias so the rest of this file compiles unchanged.
final _roleProvider = userRoleProvider;

// ---------------------------------------------------------------------------
// Tab configuration
// ---------------------------------------------------------------------------

const List<String> _memberLabels = [
  'Home',
  'Booking',
  'Chat',
  'Training',
  'Progress',
];

const List<String> _trainerLabels = [
  'Clients',
  'Schedule',
  'Chat',
  'Training',
  'Progress',
];

/// Filled icons for active tab state.
const List<IconData> _tabIconsFilled = [
  Icons.home_rounded,
  Icons.calendar_month_rounded,
  Icons.chat_bubble_rounded,
  Icons.fitness_center_rounded,
  Icons.trending_up_rounded,
];

/// Outlined icons for inactive tab state.
const List<IconData> _tabIconsOutlined = [
  Icons.home_outlined,
  Icons.calendar_today_outlined,
  Icons.chat_bubble_outline_rounded,
  Icons.fitness_center_outlined,
  Icons.trending_up,
];

const List<String> _memberTabRoutes = [
  '/home',
  '/booking',
  '/chat',
  '/training',
  '/progress',
];

const List<String> _trainerTabRoutes = [
  '/clients',
  '/booking',
  '/chat',
  '/training',
  '/progress',
];

List<String> _getTabRoutes(bool isTrainer) =>
    isTrainer ? _trainerTabRoutes : _memberTabRoutes;

// Chat tab is at index 2.
const int _chatTabIndex = 2;

// ---------------------------------------------------------------------------
// MainScaffold
// ---------------------------------------------------------------------------

/// Shell scaffold providing the [NavigationBar] for all main-tab screens.
///
/// Wraps the [child] (ShellRoute child widget) with:
/// - [ConnectivityBanner] above the content
/// - [GestureDetector] to dismiss the keyboard on tap outside a text field
/// - [NavigationBar] at the bottom with 5 role-aware tabs
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  void _onTabTapped(int index, List<String> tabRoutes) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(tabRoutes[index]);
  }

  int _indexFromRoute(String location, List<String> tabRoutes) {
    for (int i = 0; i < tabRoutes.length; i++) {
      if (location.startsWith(tabRoutes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(_roleProvider);
    final isTrainer = roleAsync.valueOrNull == AppUserRole.trainer ||
        roleAsync.valueOrNull == AppUserRole.admin;
    final labels = isTrainer ? _trainerLabels : _memberLabels;
    final tabRoutes = _getTabRoutes(isTrainer);

    // Unread badge — watch value; fallback to 0 while loading/errored.
    final unreadCount =
        ref.watch(unreadChatCountProvider).valueOrNull ?? 0;

    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = _indexFromRoute(location, tabRoutes);
    if (activeIndex != _currentIndex) {
      // Sync index when navigating programmatically (e.g. deep link).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = activeIndex);
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: Text(
          isTrainer
              ? _trainerLabels[_currentIndex]
              : _memberLabels[_currentIndex],
        ),
        actions: [
          const NotificationBell(),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => _onTabTapped(index, tabRoutes),
        destinations: List.generate(
          _tabIconsFilled.length,
          (i) {
            // Build the inactive icon — wrap in Badge for chat tab.
            final outlinedIcon = Icon(_tabIconsOutlined[i]);
            final inactiveIcon = (i == _chatTabIndex && unreadCount > 0)
                ? Badge(
                    label: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                    ),
                    child: outlinedIcon,
                  )
                : outlinedIcon;

            return NavigationDestination(
              icon: inactiveIcon,
              selectedIcon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_tabIconsFilled[i]),
                  const SizedBox(height: 2),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (_, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(120),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              label: labels[i],
            );
          },
        ),
      ),
    );
  }
}
