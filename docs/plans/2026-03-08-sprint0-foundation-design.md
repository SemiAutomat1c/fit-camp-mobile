# Sprint 0 — Foundation Design
**24 Fit Camp Flutter Mobile App**
Date: 2026-03-08 | Platform: iOS + Android | Theme: Dark default + light toggle

---

## Decisions Made

| Decision | Choice |
|---|---|
| Platform | iOS + Android (both) |
| Theme | Dark default (`#0A0A0A`) + light mode toggle |
| Splash | Animated logo — fade in + green pulse, 1.2s minimum |
| Brand accent | `#39FF14` neon green (dark) / `#2DB80F` (light) |
| Skeleton loaders | `shimmer` package, surface→elevated shimmer |

---

## 1. Color System

### Dark Theme (default)
```dart
background:    Color(0xFF0A0A0A)  // brand-black
surface:       Color(0xFF111111)  // brand-surface (cards)
elevated:      Color(0xFF1A1A1A)  // brand-elevated (modals, sheets)
border:        Color(0xFF222222)  // brand-border
primary:       Color(0xFF39FF14)  // brand-green (neon, CTAs, active states)
primaryMuted:  Color(0xFF7EC820)  // brand-green-muted
textPrimary:   Color(0xFFFFFFFF)
textMuted:     Color(0xFFA1A1AA)
error:         Color(0xFFEF4444)
success:       Color(0xFF22C55E)
warning:       Color(0xFFF59E0B)
```

### Light Theme (toggle)
```dart
background:    Color(0xFFF5F5F5)
surface:       Color(0xFFFFFFFF)
elevated:      Color(0xFFEEEEEE)
border:        Color(0xFFDDDDDD)
primary:       Color(0xFF2DB80F)  // darker green for WCAG AA on white
textPrimary:   Color(0xFF0A0A0A)
textMuted:     Color(0xFF555555)
```

**Note:** `#39FF14` fails WCAG AA on white backgrounds. Use `#2DB80F` for light theme primary.

---

## 2. App State Machine

```
INITIALIZING → AUTH CHECK → ONBOARDING CHECK → MAIN APP
      ↓              ↓              ↓
  (splash)      (→ login)    (→ onboarding)
```

### Global AppInitState enum
```dart
enum AppInitState {
  loading,          // → /splash
  unauthenticated,  // → /login
  needsOnboarding,  // → /onboarding/goal
  ready,            // → allow navigation
}
```

### Splash Screen Behavior
- `#0A0A0A` full-screen background
- "24 FIT CAMP" text + logo fades in (FadeTransition, 600ms)
- Scale pulse: 1.0 → 1.05 → 1.0 (ScaleTransition, once)
- Auth check runs in background simultaneously
- 1.2s minimum display before navigating
- GoRouter redirect handles destination — no manual `Navigator.push`

### No Connection Screen (`lib/src/shared/screens/no_connection_screen.dart`)
- Triggered when auth check fails with connection error
- Full-screen: wifi-off icon + "Can't connect to server" + "Retry" button
- Retry re-runs `authNotifier.checkAuth()`
- Distinct from inline `ErrorView` (which is for feature-level errors)

### In-app Connectivity Banner (`lib/src/shared/widgets/connectivity_banner.dart`)
- Shown when user loses connection while already inside the app
- Thin banner slides down from top: "No internet connection"
- Auto-dismisses when connectivity returns
- Uses `connectivity_plus` package
- `ConnectivityBanner` wraps `MainScaffold` body

---

## 3. Shared Widget Inventory

### Core Widgets (`lib/src/shared/widgets/`)

| Widget | File | Purpose |
|---|---|---|
| `PrimaryButton` | `primary_button.dart` | Green CTA; `label, onPressed, isLoading, icon`; inline spinner |
| `AppCard` | `app_card.dart` | Dark surface card; consistent border radius + padding |
| `AppTextField` | `app_text_field.dart` | Consistent dark-styled input; `label, hint, validator, obscureText` |
| `AppAvatar` | `app_avatar.dart` | Photo or initials fallback (initials on `#39FF14` circle) |
| `LoadingIndicator` | `loading_indicator.dart` | Centered green `CircularProgressIndicator` |
| `ErrorView` | `error_view.dart` | Inline: icon + message + retry button |
| `EmptyState` | `empty_state.dart` | Icon + title + subtitle |
| `AppSnackbar` | `app_snackbar.dart` | Static helper: `.success(ctx, msg)` / `.error(ctx, msg)` |
| `MainScaffold` | `main_scaffold.dart` | ShellRoute; `NavigationBar` 5 tabs; role-aware labels |
| `NoConnectionScreen` | `no_connection_screen.dart` | Full-screen connection error |
| `ConnectivityBanner` | `connectivity_banner.dart` | In-app connectivity loss banner |

### Skeleton Widgets (`lib/src/shared/widgets/skeletons/`)

| Widget | Used In |
|---|---|
| `SkeletonCard` | Booking cards, plan cards, notification items |
| `SkeletonListTile` | Chat list, trainer list |
| `SkeletonText` | Any single-line text placeholder |
| `SkeletonGrid` | Progress photo grid |
| `SkeletonChart` | Progress weight chart |

Shimmer base: surface (`#111111`) → elevated (`#1A1A1A`) sweep animation.

### AppTextField Notes
- Every form screen uses this (login, profile setup, booking notes, progress log)
- Dark: `fillColor: #111111`, border: `#222222`, focused border: `#39FF14`
- Light: white fill, standard border, green focus
- Build in Sprint 0 to avoid divergent styling across sprints

### AppAvatar Notes
- Accepts `imageUrl?` + `name` (required for initials fallback)
- If no image: show first 2 initials in uppercase on `#39FF14` circle
- Sizes: `sm` (32px), `md` (40px), `lg` (56px), `xl` (80px)
- Used in: chat list, chat room, booking cards, trainer selector, profile screen

---

## 4. Router & Navigation

### Route Map
```
/splash
/login
/onboarding/goal
/onboarding/waiver
/onboarding/assessment
/onboarding/profile-setup

/ (ShellRoute — MainScaffold)
  /home
  /booking
  /booking/calendar
  /booking/slots
  /booking/confirm
  /chat
  /chat/:conversationId
  /training
  /training/:planId
  /diet/:planId
  /progress
  /progress/log

/profile
/notifications
```

### Redirect Logic
```dart
redirect: (context, state) {
  switch (ref.read(appInitProvider)) {
    case AppInitState.loading:       return '/splash';
    case AppInitState.unauthenticated: return '/login';
    case AppInitState.needsOnboarding: return '/onboarding/goal';
    case AppInitState.ready:         return null; // allow
  }
}
```

### Deep Links (planned from day one)
```
fitcamp://booking/:id        → /booking (show booking)
fitcamp://chat/:id           → /chat/:id
fitcamp://notifications      → /notifications
```

### Navigation Bar Tabs
| Index | Label (Member) | Label (Trainer) | Icon |
|---|---|---|---|
| 0 | Home | Clients | home |
| 1 | Booking | Schedule | calendar |
| 2 | Chat | Chat | chat_bubble |
| 3 | Training | Training | fitness_center |
| 4 | Progress | Progress | trending_up |

Active indicator: `#39FF14` | Inactive: `#A1A1AA`

---

## 5. Easy-to-Miss Platform Setup

### Status Bar & Nav Bar (Sprint 0, `main.dart`)
```dart
SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light, // dark theme
  systemNavigationBarColor: Color(0xFF0A0A0A),
  systemNavigationBarIconBrightness: Brightness.light,
));
```
Set in `main()` before `runApp`. Also update when theme toggles.

### Keyboard Dismiss (Sprint 0, `main_scaffold.dart`)
```dart
GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  child: child, // scaffold body
)
```

### App Icon & Launch Screen
- Android: replace `ic_launcher` in `android/app/src/main/res/mipmap-*/`
- iOS: replace `AppIcon` in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Android splash: `android/app/src/main/res/drawable/launch_background.xml` → `#0A0A0A` background
- iOS splash: `ios/Runner/Base.lproj/LaunchScreen.storyboard` → dark background

---

## 6. New Dependencies to Add

```yaml
dependencies:
  shimmer: ^3.0.0              # skeleton loaders
  connectivity_plus: ^6.0.0    # in-app connectivity banner
  flutter_secure_storage: ^9.2.4
  fl_chart: ^0.69.0
  table_calendar: ^3.1.2
  riverpod_annotation: ^2.6.1
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

dev_dependencies:
  riverpod_generator: ^2.4.3
  build_runner: ^2.4.9
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

---

## 7. Sprint 0 File Checklist

```
lib/
├── main.dart                                     (rewrite)
└── src/
    ├── core/
    │   ├── models/app_user.dart
    │   └── services/
    │       ├── convex_service.dart
    │       ├── convex_provider.dart
    │       └── storage_service.dart
    ├── shared/
    │   ├── theme/
    │   │   ├── app_colors.dart                   ← #39FF14 brand palette
    │   │   ├── app_text_styles.dart
    │   │   └── app_theme.dart                    ← dark() + light()
    │   ├── router/
    │   │   └── app_router.dart                   ← GoRouter + redirect
    │   └── widgets/
    │       ├── primary_button.dart
    │       ├── app_card.dart
    │       ├── app_text_field.dart               ← NEW (was missing)
    │       ├── app_avatar.dart                   ← NEW (was missing)
    │       ├── app_snackbar.dart
    │       ├── loading_indicator.dart
    │       ├── error_view.dart
    │       ├── empty_state.dart
    │       ├── main_scaffold.dart
    │       ├── connectivity_banner.dart           ← NEW (was missing)
    │       ├── no_connection_screen.dart          ← NEW (was missing)
    │       └── skeletons/
    │           ├── skeleton_card.dart
    │           ├── skeleton_list_tile.dart
    │           ├── skeleton_text.dart
    │           ├── skeleton_grid.dart
    │           └── skeleton_chart.dart
    └── features/
        └── auth/
            └── presentation/screens/
                └── splash_screen.dart            ← animated logo
```

---

## What's NOT in Sprint 0

- No auth logic (Sprint 1)
- No feature screens (Sprint 1+)
- No Freezed/Riverpod code generation yet (no @riverpod annotations in Sprint 0)
- No `build_runner` needed until Sprint 1
