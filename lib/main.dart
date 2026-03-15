import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/services/convex_service.dart';
import 'src/core/services/crashlytics_service.dart';
import 'src/features/push_notifications/services/local_notification_service.dart';
import 'src/features/push_notifications/services/push_notification_service.dart';
import 'src/shared/router/app_router.dart';
import 'src/shared/theme/app_colors.dart';
import 'src/shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on phone. Landscape support for tablets comes later.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style system bars for dark theme (default).
  // When the user switches to light theme in Sprint 6, call this again with
  // statusBarIconBrightness: Brightness.dark.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark, // iOS
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Firebase: guarded so the app still runs without google-services.json /
  // GoogleService-Info.plist during development or CI.
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await LocalNotificationService().initialize();
    await CrashlyticsService().initialize();
  } catch (e) {
    // Firebase not configured yet — app continues without push / crash reporting.
    debugPrint('Firebase init skipped: $e');
  }

  // Initialize the Convex client singleton before the widget tree runs.
  // Sprint 1 will gate further startup on a successful connection check.
  try {
    await ConvexService.initialize();
  } catch (_) {
    // If initialization fails (e.g. no network at cold start), the
    // NoConnectionScreen flow in Sprint 1 handles the retry path.
    // Sprint 0: allow app to continue — splash will handle state transition.
  }

  runApp(
    const ProviderScope(child: FitCampApp()),
  );

  // Catch all uncaught platform-level errors after runApp.
  PlatformDispatcher.instance.onError = (error, stack) {
    CrashlyticsService().recordError(error, stack, fatal: true);
    return true;
  };
}

/// Root application widget.
///
/// Configures [MaterialApp.router] with:
/// - Dark theme by default ([ThemeMode.dark])
/// - Light theme ready for Sprint 6 toggle
/// - [GoRouter] from [routerProvider]
class FitCampApp extends ConsumerWidget {
  const FitCampApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '24 Fit Camp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark, // Sprint 6 adds a user-controlled toggle
      routerConfig: router,
    );
  }
}
