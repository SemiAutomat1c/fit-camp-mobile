import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Slides in from the top when the device loses internet connectivity.
///
/// Auto-dismisses 1 second after connectivity returns. Uses [SlideTransition]
/// (compositor-safe — transform only).
///
/// Place at the top of [MainScaffold]'s body [Column]:
/// ```dart
/// Column(children: [
///   const ConnectivityBanner(),
///   Expanded(child: child),
/// ])
/// ```
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _isOffline = false;
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _subscription = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (r) => r != ConnectivityResult.none,
    );

    if (!hasConnection) {
      _reconnectTimer?.cancel();
      if (!_isOffline) {
        setState(() => _isOffline = true);
        _controller.forward();
      }
    } else {
      if (_isOffline) {
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(seconds: 1), () {
          if (mounted) {
            _controller.reverse().then((_) {
              if (mounted) setState(() => _isOffline = false);
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always in the tree so the SlideTransition can animate in smoothly.
    // Wrap in ClipRect so the banner doesn't paint outside its bounds while
    // sliding in from above (overflow is invisible but wastes compositor work).
    return ClipRect(
      child: SlideTransition(
        position: _slideAnimation,
        child: _isOffline ? const _BannerContent() : const SizedBox.shrink(),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.error,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: const Text(
        'No internet connection',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
