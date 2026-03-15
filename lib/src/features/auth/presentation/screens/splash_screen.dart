import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/convex_provider.dart';
import '../../../../shared/router/app_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/auth_provider.dart';

/// Animated launch screen for 24 Fit Camp.
///
/// Displays for a minimum of 1200 ms while the auth check runs concurrently.
/// After both complete, [AppInitState] is updated by [AuthNotifier.checkAuth]
/// and GoRouter's redirect handles navigation — no [Navigator.push] calls.
///
/// Special case: if the auth check results in [AppInitState.unauthenticated]
/// and the intro carousel has not been seen, this screen navigates to `/intro`
/// before GoRouter's redirect can send the user to `/login`.
///
/// Animations:
/// - [FadeTransition] on the logo block: 600 ms, [Curves.easeIn]
/// - [ScaleTransition]: 1.0 → 1.05 → 1.0, starts at 200 ms, 400 ms duration
/// - Pulsing neon ring behind the logo: expands + fades out on loop
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _ringController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_scaleController);

    // Ring: scale 0.8 → 1.4, opacity 0.6 → 0, looping
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _ringScale = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeIn),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    _fadeController.forward();

    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (mounted) _scaleController.forward();

    // Auth check and minimum display time run concurrently.
    // checkAuth() updates appInitProvider when done; GoRouter redirects.
    await Future.wait<void>([
      ref.read(authNotifierProvider.notifier).checkAuth(),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);

    if (!mounted) return;

    // If unauthenticated and the intro carousel has never been seen,
    // push to /intro before GoRouter's redirect fires.
    if (ref.read(appInitProvider) == AppInitState.unauthenticated) {
      final storage = ref.read(storageServiceProvider);
      final seen = await storage.getIntroSeen();
      if (!seen && mounted) {
        context.go('/intro');
        return;
      }
    }
    // GoRouter redirect handles all other transitions.
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Center(
        child: RepaintBoundary(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing neon ring
                  AnimatedBuilder(
                    animation: _ringController,
                    builder: (context, _) {
                      return Opacity(
                        opacity: _ringOpacity.value,
                        child: Transform.scale(
                          scale: _ringScale.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Logo block
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: const _LogoBlock(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            size: 44,
            color: AppColors.background,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '24 FIT CAMP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 4,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'GYM MANAGEMENT ECOSYSTEM',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            letterSpacing: 2.5,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
