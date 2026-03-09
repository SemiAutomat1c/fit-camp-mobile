import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../core/services/convex_provider.dart';
import '../../features/notifications/presentation/widgets/notification_bell.dart';
import '../theme/app_colors.dart';
import 'connectivity_banner.dart';

// ---------------------------------------------------------------------------
// Role provider
// ---------------------------------------------------------------------------

/// Provides the user's [AppUserRole] read from [storageServiceProvider].
///
/// Defaults to [AppUserRole.member] if no role is stored yet.
final _roleProvider = FutureProvider<AppUserRole>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  final stored = await storage.getRole();
  if (stored == null) return AppUserRole.member;
  return AppUserRole.fromString(stored);
});

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

const List<String> _tabRoutes = [
  '/home',
  '/booking',
  '/chat',
  '/training',
  '/progress',
];

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

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(_tabRoutes[index]);
  }

  int _indexFromRoute(String location) {
    for (int i = 0; i < _tabRoutes.length; i++) {
      if (location.startsWith(_tabRoutes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(_roleProvider);
    final isTrainer = roleAsync.valueOrNull == AppUserRole.trainer ||
        roleAsync.valueOrNull == AppUserRole.admin;
    final labels = isTrainer ? _trainerLabels : _memberLabels;

    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = _indexFromRoute(location);
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
          isTrainer ? _trainerLabels[_currentIndex] : _memberLabels[_currentIndex],
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
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
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
        onDestinationSelected: _onTabTapped,
        destinations: List.generate(
          _tabIconsFilled.length,
          (i) => NavigationDestination(
            icon: Icon(_tabIconsOutlined[i]),
            selectedIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_tabIconsFilled[i]),
                const SizedBox(height: 2),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            label: labels[i],
          ),
        ),
      ),
    );
  }
}
