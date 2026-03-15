import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../providers/intro_provider.dart';

class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  ConsumerState<OnboardingIntroScreen> createState() =>
      _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState
    extends ConsumerState<OnboardingIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_IntroSlide> _slides = [
    _IntroSlide(
      icon: Icons.calendar_month_rounded,
      title: 'Book Sessions Anytime',
      subtitle:
          'Easily schedule training sessions with your personal trainer',
    ),
    _IntroSlide(
      icon: Icons.trending_up_rounded,
      title: 'Track Your Journey',
      subtitle:
          'Log progress, view stats, and celebrate your fitness milestones',
    ),
    _IntroSlide(
      icon: Icons.chat_bubble_rounded,
      title: 'Stay Connected',
      subtitle:
          'Chat directly with your trainer and get real-time guidance',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _slides.length - 1;

  Future<void> _complete() async {
    HapticFeedback.mediumImpact();
    await ref.read(introNotifierProvider.notifier).markSeen();
    if (mounted) context.go('/login');
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_isLastPage) {
      _complete();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    HapticFeedback.lightImpact();
    _complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button row
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip',
                  style:
                      AppTextStyles.bodyMed.copyWith(color: AppColors.textMuted),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) =>
                    _SlidePage(slide: _slides[index]),
              ),
            ),
            // Dot indicator
            _DotIndicator(
              count: _slides.length,
              current: _currentPage,
            ),
            const SizedBox(height: 32),
            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  child: Text(
                    _isLastPage ? 'Get Started' : 'Next',
                    style: AppTextStyles.button
                        .copyWith(color: AppColors.background),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _IntroSlide {
  const _IntroSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

// ---------------------------------------------------------------------------
// Slide page
// ---------------------------------------------------------------------------

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});

  final _IntroSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withAlpha(60), width: 1.5),
            ),
            child: Icon(
              slide.icon,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            slide.title,
            style: AppTextStyles.heading1
                .copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dot indicator
// ---------------------------------------------------------------------------

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
