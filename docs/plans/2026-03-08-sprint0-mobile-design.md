# Sprint 0 — Mobile Design Specification
**24 Fit Camp Flutter Mobile App**
Date: 2026-03-08 | Platform: iOS + Android | Framework: Flutter

---

## 🧠 Checkpoint

```
Platform:   iOS + Android (Cross-platform)
Framework:  Flutter + Material 3
Files Read: mobile-design-thinking.md, touch-psychology.md, mobile-performance.md,
            mobile-color-system.md, mobile-navigation.md, platform-ios.md, platform-android.md

3 Principles Applied:
1. const constructors everywhere — prevent unnecessary rebuilds
2. 48dp minimum touch targets — extend hit areas with padding, not sizing
3. GPU-accelerated animations only — transform + opacity, never layout properties

Anti-Patterns Avoided:
1. ListView (not .builder) → always ListView.builder or similar lazy builders
2. Animating width/height/margin → only transform/opacity
3. Inline widget functions → extract named const widgets
```

---

## 1. Splash Screen

### Behavior Spec
- Full screen `#0A0A0A` background — zero power OLED
- Logo fade: `FadeTransition` on `AnimationController` (600ms, `Curves.easeIn`)
- Scale pulse: `ScaleTransition` 1.0 → 1.05 → 1.0 (`Curves.easeInOut`, once, starts at 200ms)
- Auth check runs concurrently (not blocking animation)
- Minimum 1200ms total display — `Future.wait([authFuture, minDelay])`
- Navigation handled entirely by GoRouter redirect — no `Navigator.push`

### Performance Rules
- `AnimationController` disposed in `dispose()` — no leak
- Only `Opacity` + `Transform.scale` animated — GPU compositor layer
- `RepaintBoundary` wraps the logo widget — isolates repaint

### Touch
- No interaction on splash — passive screen, no tappable elements

---

## 2. NavigationBar (MainScaffold)

### Layout
```
Android (Material 3 NavigationBar):
├── Height: 80dp
├── Active indicator: pill shape, #39FF14 at 20% opacity
├── Active icon: filled variant, #39FF14
├── Inactive icon: outlined variant, #A1A1AA
├── Labels: always visible (accessibility)
└── Elevation: 0 (flat, matches #0A0A0A background)

iOS (CupertinoTabBar feel via Material):
├── Height: 49pt + safe area inset
├── Safe area: MediaQuery.of(context).padding.bottom
├── Background: #0A0A0A with border-top #222222
└── Icons: identical — Material 3 icons acceptable on iOS
```

### State Preservation
```dart
// IndexedStack — preserves tab state, DO NOT use PageView
IndexedStack(
  index: _currentIndex,
  children: const [
    HomeTab(),
    BookingTab(),
    ChatTab(),
    TrainingTab(),
    ProgressTab(),
  ],
)
```

### Tab Touch Targets
- Each tab item: minimum 48dp height × full-width-divided touch area
- Flutter's `NavigationBar` handles this correctly by default
- Do NOT add extra padding that shrinks the tappable area

### Role-Aware Labels
```dart
// Trainer vs Member labels (read from authProvider role)
tabs = role == AppUserRole.trainer
  ? ['Clients', 'Schedule', 'Chat', 'Training', 'Progress']
  : ['Home', 'Booking', 'Chat', 'Training', 'Progress'];
```

---

## 3. Shared Widget Touch Targets

### PrimaryButton
```
Height: 56dp (Material 3 large button standard)
Min width: full-width in forms, 200dp standalone
Touch target: self — already large enough
Corner radius: 12dp (brand style)
Loading state: swap label + icon for CircularProgressIndicator (20dp, white)
Disabled: 38% opacity, no ripple
```

### AppCard
```
Padding: 16dp all sides
Corner radius: 16dp
Background: #111111 (brand-surface)
Border: 1dp solid #222222
Elevation: 0 (flat on dark — shadows don't read on dark backgrounds)
Touch: if tappable, InkWell with splash color #39FF14 at 8% opacity
```

### AppTextField
```
Height: 56dp (Material 3 standard)
Corner radius: 12dp
Fill: #111111 (dark) / #FFFFFF (light)
Unfocused border: 1dp #222222 (dark) / #DDDDDD (light)
Focused border: 2dp #39FF14 (dark) / #2DB80F (light)
Error border: 2dp #EF4444
Label: floats above on focus/fill
Hint: #A1A1AA color
Input text: #FFFFFF (dark) / #0A0A0A (light)
Keyboard: dismiss on scaffold GestureDetector tap
```

### AppAvatar
```
Sizes:
├── sm: 32dp (touch with ListTile — ListTile handles target)
├── md: 40dp (standard list item)
├── lg: 56dp (profile header)
└── xl: 80dp (profile screen, booking confirm)

Initials fallback:
├── Circle background: #39FF14
├── Text color: #0A0A0A (max contrast on neon green)
├── Font: AppTextStyles.label, bold, uppercase
└── Letters: first 2 chars of name.trim().split(' ') → initials

Image loading: CachedNetworkImage with shimmer placeholder
```

### LoadingIndicator
```
Widget: CircularProgressIndicator.adaptive()
Color: #39FF14 (valueColor: AlwaysStoppedAnimation)
Size: 24dp
Wrapper: Center() + Padding(16dp)
Touch: none — non-interactive
```

### EmptyState
```
Layout: Column, center-aligned, 40dp vertical padding
Icon: 64dp, #A1A1AA color
Title: AppTextStyles.heading3, #FFFFFF
Subtitle: AppTextStyles.body, #A1A1AA, center-aligned, max 2 lines
CTA button (optional): PrimaryButton, 48dp top margin
```

### ErrorView
```
Layout: Column, center-aligned
Icon: Icons.error_outline, 48dp, #EF4444
Message: AppTextStyles.body, #A1A1AA, center-aligned
Retry: TextButton "Try Again", #39FF14 text color
Min retry touch area: 48dp height
```

---

## 4. Skeleton Loaders

### Performance Rule
- Use `shimmer` package — `Shimmer.fromColors()`
- Shimmer animates via shader — NOT layout properties → GPU safe
- Base color: `#111111` (surface), highlight color: `#1A1A1A` (elevated)
- `Container` with `BorderRadius` matching real widget shape

### SkeletonCard
```
Width: double.infinity
Height: 120dp
Corner radius: 16dp (matches AppCard)
Inner rows: 3 × SkeletonText (16dp, 12dp, 12dp heights)
```

### SkeletonListTile
```
Leading: 40dp × 40dp circle (AppAvatar md)
Title line: width ~60%, height 14dp, radius 4dp
Subtitle line: width ~40%, height 12dp, radius 4dp
Spacing: 12dp vertical between lines
```

### SkeletonText
```
Height: 14dp (default), configurable
Width: configurable (default: 100%)
Corner radius: 4dp
```

### SkeletonGrid
```
2-column grid, gap 8dp
Each cell: aspect ratio 1:1, corner radius 8dp
```

### SkeletonChart
```
Width: double.infinity
Height: 200dp
Corner radius: 8dp
```

---

## 5. Connectivity Banner

### Design
```
Position: top of body (below AppBar if present, below status bar otherwise)
Height: 44dp (including 8dp vertical padding)
Background: #EF4444 (error red — universal "bad" signal)
Text: "No internet connection", #FFFFFF, AppTextStyles.caption, centered
Animation: SlideTransition from top, Curves.easeOut, 300ms
Auto-dismiss: reverse animation when connectivity returns, 1s delay
```

### Placement in Widget Tree
```dart
// In MainScaffold body:
Column(
  children: [
    const ConnectivityBanner(),  // Always in tree, animates in/out
    Expanded(child: child),      // ShellRoute child
  ],
)
```

### Touch
- Banner is passive — no tap interaction
- Does not block scroll or content below

---

## 6. System Bar Styling

### Setup (main.dart, before runApp)
```dart
SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,        // white icons on dark bg
  statusBarBrightness: Brightness.dark,             // iOS
  systemNavigationBarColor: Color(0xFF0A0A0A),      // matches app background
  systemNavigationBarIconBrightness: Brightness.light,
));

// Force portrait only for mobile (landscape allowed on tablet — future)
SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
]);
```

### Theme Toggle Update
When user switches theme, call `SystemChrome.setSystemUIOverlayStyle` again with:
- Dark theme: `statusBarIconBrightness: Brightness.light`
- Light theme: `statusBarIconBrightness: Brightness.dark`

---

## 7. Typography Scale

### AppTextStyles
```
heading1: fontSize 32, fontWeight w700, height 1.2
heading2: fontSize 24, fontWeight w700, height 1.25
heading3: fontSize 20, fontWeight w600, height 1.3
heading4: fontSize 18, fontWeight w600, height 1.35
body:     fontSize 16, fontWeight w400, height 1.5
bodyMed:  fontSize 16, fontWeight w500, height 1.5
caption:  fontSize 14, fontWeight w400, height 1.4, color textMuted
label:    fontSize 12, fontWeight w500, height 1.3, letterSpacing 0.5
button:   fontSize 16, fontWeight w600, height 1.0, letterSpacing 0.25

All: TextOverflow.ellipsis default, maxLines: 1 unless noted
No hardcoded sizes that override textScaleFactor
```

---

## 8. Global State Feedback

### App Startup Sequence
```
1. Splash shows (min 1200ms)
2. ConvexClient.connect() fires
3. If connect fails → NoConnectionScreen (not redirect to login)
4. If connect ok → check auth token in SecureStorage
5. No token → redirect /login
6. Token → verify with Convex getUser
7. getUser fails (expired) → delete token → redirect /login
8. getUser ok + onboarding_complete → redirect /home
9. getUser ok + no onboarding → redirect /onboarding/goal
```

### No Connection Screen
```
Position: full-screen replacement for splash while offline
Background: #0A0A0A
Icon: Icons.wifi_off, 64dp, #A1A1AA
Title: "Can't connect to server"
Subtitle: "Check your internet connection"
Button: PrimaryButton "Retry" → re-runs authNotifier.checkAuth()
```

---

## 9. Performance Constraints

### Widget Build Rules
- All leaf widgets: `const` constructor where stateless
- List items: always named `const`-compatible widgets, not inline builders
- `select()` on providers when only one field needed:
  ```dart
  ref.watch(authProvider.select((u) => u?.role))
  ```

### Animation Rules
- Splash logo: `FadeTransition` + `ScaleTransition` (compositor-safe)
- Connectivity banner: `SlideTransition` (compositor-safe)
- Skeleton shimmer: `Shimmer.fromColors()` (shader-based)
- NEVER animate: width, height, padding, margin, top/left/right/bottom

### Dispose Pattern (mandatory for Sprint 0 widgets)
```dart
// Any widget with AnimationController, TextEditingController, StreamSubscription:
@override
void dispose() {
  _controller.dispose();
  _textController.dispose();
  _subscription.cancel();
  super.dispose();
}
```

---

## 10. Safe Area Rules

### iOS
- `SafeArea` wraps all screens that don't extend behind system bars
- Splash: `extendBody: true`, no SafeArea (full-screen effect)
- MainScaffold: `NavigationBar` already respects bottom inset
- Custom bottom sheets: `bottomSheetPadding = MediaQuery.of(context).viewInsets.bottom`

### Android
- `WindowCompat.setDecorFitsSystemWindows(window, false)` via Flutter's default — handled
- Keyboard: `Scaffold(resizeToAvoidBottomInset: true)` on all form screens
- System nav bar: `#0A0A0A` background set in `setSystemUIOverlayStyle`

---

## Summary: Sprint 0 Mobile Design Decisions

| Component | Decision |
|---|---|
| Splash animation | FadeTransition + ScaleTransition (GPU-safe) |
| Auth wait | Future.wait([authFuture, 1200ms minimum]) |
| Tab state | IndexedStack (not PageView) |
| Touch targets | 48dp minimum, extend via Padding not widget size |
| AppTextField height | 56dp (Material 3 standard) |
| Dark skeleton base/highlight | #111111 → #1A1A1A |
| Connectivity banner | SlideTransition from top, red (#EF4444) |
| System bar icons | Brightness.light (white) on dark theme |
| No connection recovery | Full-screen → retry re-runs checkAuth() |
| Animation properties | transform + opacity ONLY |
