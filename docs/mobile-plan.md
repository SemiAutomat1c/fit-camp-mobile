# 24 Fit Camp — Mobile Development Plan

**Version 1.0 | March 2026**  
**Stack: Flutter + Riverpod + GoRouter + convex_flutter**

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart) |
| State Management | Riverpod (riverpod_annotation) |
| Navigation | GoRouter |
| Backend | convex_flutter |
| Charts | fl_chart |
| Secure Storage | flutter_secure_storage |
| Calendar | table_calendar |

---

## 1. Feature-First Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── router.dart
│   │   └── route_names.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_text_styles.dart
│
├── core/
│   ├── convex/
│   │   ├── convex_client_provider.dart
│   │   └── convex_repository.dart
│   ├── models/
│   │   ├── user.dart
│   │   └── user_role.dart
│   └── utils/
│       ├── validators.dart
│       └── date_formatters.dart
│
├── shared/
│   └── widgets/
│       ├── fit_button.dart
│       ├── fit_text_field.dart
│       ├── fit_avatar.dart
│       ├── fit_card.dart
│       ├── loading_overlay.dart
│       ├── error_state_widget.dart
│       └── empty_state_widget.dart
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── auth_repository.dart
    │   │   └── models/
    │   │       └── auth_state.dart
    │   └── presentation/
    │       ├── providers/
    │       │   ├── auth_provider.dart
    │       │   └── onboarding_provider.dart
    │       ├── screens/
    │       │   ├── splash_screen.dart
    │       │   ├── login_screen.dart
    │       │   ├── register_screen.dart
    │       │   ├── goal_selection_screen.dart
    │       │   ├── waiver_screen.dart
    │       │   └── pre_assessment_screen.dart
    │       └── widgets/
    │           └── goal_chip.dart
    │
    ├── booking/
    │   ├── data/
    │   │   ├── booking_repository.dart
    │   │   └── models/
    │   │       ├── time_slot.dart
    │   │       └── booking.dart
    │   └── presentation/
    │       ├── providers/
    │       │   ├── slots_provider.dart
    │       │   └── user_bookings_provider.dart
    │       ├── screens/
    │       │   ├── booking_calendar_screen.dart
    │       │   ├── time_slots_screen.dart
    │       │   └── booking_confirm_screen.dart
    │       └── widgets/
    │           ├── date_strip.dart
    │           ├── slot_tile.dart
    │           └── booking_card.dart
    │
    ├── chat/
    │   ├── data/
    │   │   ├── chat_repository.dart
    │   │   └── models/
    │   │       ├── conversation.dart
    │   │       └── message.dart
    │   └── presentation/
    │       ├── providers/
    │       │   ├── conversations_provider.dart
    │       │   └── chat_room_provider.dart
    │       ├── screens/
    │       │   ├── chat_list_screen.dart
    │       │   └── chat_room_screen.dart
    │       └── widgets/
    │           ├── conversation_tile.dart
    │           ├── message_bubble.dart
    │           └── chat_input_bar.dart
    │
    ├── training/
    │   ├── data/
    │   │   ├── training_repository.dart
    │   │   └── models/
    │   │       └── training_plan.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── training_provider.dart
    │       ├── screens/
    │       │   ├── training_plan_screen.dart
    │       │   └── diet_plan_screen.dart
    │       └── widgets/
    │           └── exercise_tile.dart
    │
    ├── progress/
    │   ├── data/
    │   │   ├── progress_repository.dart
    │   │   └── models/
    │   │       └── measurement.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── progress_provider.dart
    │       ├── screens/
    │       │   ├── progress_dashboard_screen.dart
    │       │   ├── log_measurement_screen.dart
    │       │   └── photo_log_screen.dart
    │       └── widgets/
    │           ├── weight_chart.dart
    │           └── bmi_gauge.dart
    │
    └── profile/
        ├── data/
        │   └── profile_repository.dart
        └── presentation/
            ├── providers/
            │   └── profile_provider.dart
            └── screens/
                └── profile_screen.dart
```

---

## 2. Riverpod State Management Patterns

### Auth Provider

```dart
@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    return ref.read(authRepositoryProvider).restoreSession();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider)
          .signIn(email: email, password: password);
      ref.read(convexClientProvider).setAuth(user.convexToken);
      return AuthState(user: user, role: user.role);
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.read(convexClientProvider).clearAuth();
    state = const AsyncData(AuthState());
  }
}
```

### Booking Provider (with Optimistic Updates)

```dart
@riverpod
class BookingSlots extends _$BookingSlots {
  @override
  Future<List<TimeSlot>> build(DateTime date) async {
    return ref.read(bookingRepositoryProvider).getSlotsForDate(date);
  }

  Future<void> bookSlot(String slotId) async {
    final previous = state.requireValue;
    
    // Optimistic update
    state = AsyncData(
      previous.map((s) => s.id == slotId
          ? s.copyWith(status: SlotStatus.booked)
          : s).toList(),
    );

    try {
      await ref.read(bookingRepositoryProvider).bookSlot(slotId);
      ref.invalidate(userBookingsProvider);
    } catch (e) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}
```

### Chat Provider (Real-Time Stream)

```dart
@riverpod
class ChatRoom extends _$ChatRoom {
  @override
  Stream<List<Message>> build(String conversationId) {
    return ref.read(chatRepositoryProvider).watchMessages(conversationId);
  }

  Future<void> sendMessage(String text) async {
    await ref.read(chatRepositoryProvider).sendMessage(
      conversationId: arg,
      senderId: ref.read(authProvider).requireValue.user!.id,
      text: text,
    );
  }
}
```

---

## 3. GoRouter Navigation Structure

```dart
@riverpod
GoRouter router(Ref ref) {
  final authAsync = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    
    redirect: (context, state) {
      final auth = authAsync.valueOrNull;
      final loggedIn = auth?.isAuthenticated ?? false;
      final onboarded = auth?.isOnboardingComplete ?? false;
      
      if (!loggedIn) return '/auth/login';
      if (!onboarded) return '/onboarding/goals';
      return null;
    },

    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      
      // Onboarding
      GoRoute(path: '/onboarding/goals', builder: (_, __) => const GoalSelectionScreen()),
      GoRoute(path: '/onboarding/waiver', builder: (_, __) => const WaiverScreen()),
      GoRoute(path: '/onboarding/assessment', builder: (_, __) => const PreAssessmentScreen()),
      
      // Main Shell (5 tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/booking', builder: (_, __) => const BookingCalendarScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/chat', builder: (_, __) => const ChatListScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/training', builder: (_, __) => const TrainingPlanScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())]),
        ],
      ),
    ],
  );
}
```

---

## 4. Convex Integration

```dart
// ConvexClient Provider
@riverpod
ConvexClient convexClient(Ref ref) {
  final client = ConvexClient(
    deploymentUrl: const String.fromEnvironment('CONVEX_URL'),
  );

  ref.listen<AsyncValue<AuthState>>(authProvider, (prev, next) {
    next.whenData((auth) {
      if (auth.isAuthenticated) {
        client.setAuth(auth.user!.convexToken);
      } else {
        client.clearAuth();
      }
    });
  });

  ref.onDispose(client.close);
  return client;
}

// Repository Pattern
abstract class ConvexRepository {
  final ConvexClient client;
  ConvexRepository(this.client);

  Future<T> query<T>(String fn, Map<String, dynamic> args, T Function(dynamic) fromJson);
  Future<dynamic> mutation(String fn, Map<String, dynamic> args);
  Stream<T> watch<T>(String fn, Map<String, dynamic> args, T Function(dynamic) fromJson);
}
```

---

## 5. Build Order — 6 Sprints

### Sprint 0 — Foundation (3 days)
- [ ] pubspec.yaml — all deps locked
- [ ] app_colors.dart + app_theme.dart
- [ ] convex_client_provider.dart
- [ ] Shared widgets: FitButton, FitTextField, LoadingOverlay
- [ ] router.dart (shell scaffold, all routes declared)

### Sprint 1 — Auth & Onboarding (5 days)
- [ ] SplashScreen
- [ ] LoginScreen
- [ ] RegisterScreen
- [ ] GoalSelectionScreen
- [ ] WaiverScreen
- [ ] PreAssessmentScreen

### Sprint 2 — Booking (5 days)
- [ ] HomeScreen (dashboard)
- [ ] BookingCalendarScreen
- [ ] BookingTimeSlotsScreen
- [ ] BookingConfirmScreen
- [ ] Optimistic booking update

### Sprint 3 — Chat (4 days)
- [ ] ChatListScreen
- [ ] ChatRoomScreen
- [ ] ChatInputBar
- [ ] Real-time via StreamNotifier

### Sprint 4 — Training & Diet Plans (3 days)
- [ ] TrainingPlanScreen
- [ ] DietPlanScreen
- [ ] View-only (trainer assigns)

### Sprint 5 — Progress Tracking (4 days)
- [ ] ProgressDashboardScreen
- [ ] LogMeasurementScreen
- [ ] PhotoLogScreen
- [ ] fl_chart for graphs

### Sprint 6 — Polish (3 days)
- [ ] ProfileScreen
- [ ] Dark mode QA
- [ ] Accessibility audit

---

## 6. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^15.0.0
  convex_flutter: ^3.0.0
  flutter_secure_storage: ^9.2.4
  fl_chart: ^0.69.0
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
  table_calendar: ^3.1.2
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  intl: ^0.19.0

dev_dependencies:
  riverpod_generator: ^2.6.1
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

---

## 7. Key Architecture Decisions

| Concern | Decision |
|---------|----------|
| State scope | AsyncNotifier per feature |
| Real-time data | StreamNotifier → Convex watchQuery |
| Optimistic UI | Manual state patch + rollback on error |
| Auth token | flutter_secure_storage (Keychain/Keystore) |
| Navigation guard | GoRouter redirect watches authProvider |
| Chat screen | Pushed above shell (full-screen) |
| Code generation | riverpod_annotation + freezed |

---

*Document prepared by Group 6 — Software Engineering*  
*24 Fit Camp: Gym Management Ecosystem | Mobile Plan v1.0 | March 2026*
