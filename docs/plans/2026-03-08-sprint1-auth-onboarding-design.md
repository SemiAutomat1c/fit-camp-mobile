# Sprint 1 — Auth & Onboarding Design
**24 Fit Camp Flutter Mobile App**
Date: 2026-03-08

---

## Critical Fix: auth.ts Admin-Only Guard

The existing `convex/auth.ts` `createOrUpdateUser` callback blocks non-admin users from authenticating — it throws `"This portal is for administrators only"` for any pre-provisioned member or trainer on their first sign-in. This is a Sprint 1 blocker.

**Fix:** Remove the role guard for existing users. Security on web endpoints comes from `requireAdmin` checks in each function, not from the auth callback. New self-registration remains blocked by the `gymSettings` singleton.

```typescript
// BEFORE:
if (existingUser) {
  if (existingUser.role !== "admin") {
    throw new Error("This portal is for administrators only. Use the mobile app to sign in.");
  }
  return existingUser._id;
}

// AFTER:
if (existingUser) {
  // Allow all pre-provisioned users (members, trainers, admins) to authenticate.
  // Web portal endpoint security is enforced via requireAdmin() in each function.
  // Members/trainers cannot self-register — the gymSettings singleton block below
  // prevents that for any email without an existing users record.
  return existingUser._id;
}
```

---

## 1. Login Screen

### States

| State | UI | Haptic |
|---|---|---|
| Idle | Email + password fields, Sign In button, Forgot password? link | — |
| Loading | `isLoading: true` on PrimaryButton | — |
| Wrong credentials | Inline error below password field + shake animation | `HapticFeedback.heavyImpact()` |
| Suspended account | "Your account is inactive. Contact your gym admin." | `HapticFeedback.heavyImpact()` |
| Network error | `AppSnackbar.error("No connection. Check your internet.")` | — |
| Success | GoRouter redirects (via `appInitProvider` state change) | `HapticFeedback.mediumImpact()` |

### Shake Animation
```dart
// Shake controller: 300ms, repeat: false
// Tween: Offset(0,0) → Offset(0.05,0) → Offset(-0.05,0) → Offset(0,0)
// Applied via SlideTransition or Transform.translate
```

### Forgot Password Flow
2 screens — not a full modal stack, just inline navigation:
1. `ForgotPasswordScreen` — email field + "Send Code" button → calls `signIn("resend-otp", {email})`
2. `ResetPasswordScreen` — OTP code field + new password field + confirm password field → calls `signIn("password", {email, password, code})`

Both screens show "Having trouble? Contact your gym admin" at the bottom.

Routes: `/forgot-password` → `/reset-password`

### Error Mapping
```
"Invalid password" / "User not found" → "Invalid email or password."
"account inactive" / "isActive: false" → "Your account is inactive. Contact your gym admin."
"Registration is closed" → "Account not found. Contact your gym admin."
Network error → AppSnackbar (not inline — no credentials to fail on)
```

---

## 2. Splash Auth Check

Replaces the `Future.delayed` placeholder in `SplashScreen._startAnimations()`:

```
1. getToken() from StorageService
   ↓ null → set appInitProvider = unauthenticated
2. Call mobile:getMyProfile via ConvexClient
   ↓ throws 401/unauthorized → deleteAll() → set unauthenticated
3. Returns user → save AppUser to authProvider state
4. Check StorageService.get('onboarding_complete_{userId}')
   ↓ null/missing → set needsOnboarding
5. Present → set ready
```

Min 1200ms splash still enforced via `Future.wait`.

---

## 3. Auth Provider

### `auth_provider.dart`
```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<AppUser?> build() => const AsyncValue.data(null);

  Future<void> checkAuth() async { ... }
  Future<void> signIn(String email, String password) async { ... }
  Future<void> signOut() async { ... }
}
```

**`signIn` flow:**
1. `state = AsyncValue.loading()`
2. Call Convex `auth:signIn` with email/password
3. On success: call `mobile:getMyProfile` → parse AppUser → save token + userId + role to StorageService
4. Check onboarding flag → set `appInitProvider` appropriately
5. On failure: `state = AsyncValue.error(...)` with mapped error message

**`signOut` flow:**
1. Call Convex `auth:signOut`
2. `StorageService.deleteAll()`
3. `appInitProvider = unauthenticated`
4. `state = AsyncValue.data(null)`

**Session expiry interception:**
- `AuthNotifier.handleUnauthorized()` — called from any feature repository when it catches a 401
- Triggers `signOut()` → GoRouter redirects to login

---

## 4. Onboarding

### Multi-step State (`onboarding_provider.dart`)

```dart
class OnboardingState {
  final String? selectedGoal;
  final bool waiverAccepted;
  final String? injuries;
  final String? medicalConditions;
  final String? medications;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final double? heightCm;
  final double? weightKg;
  final int? age;
  final String? gender;
  final bool isSubmitting;
  final String? error;
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  // setGoal, acceptWaiver, setAssessment, setProfile
  // submit() → calls mobile:submitOnboarding → on success sets onboarding flag
}
```

### Step Screens

**Step 1 — Goal Selection** (`/onboarding/goal`)
- 2-column grid of 5 `GoalCard` widgets
- Goals: `lose_weight`, `build_muscle`, `improve_fitness`, `sports_performance`, `general_wellness`
- Tap: green border + checkmark + `selectionClick` haptic
- "Next" enabled when goal selected
- Back: disabled on step 1 (no back from first step)

**Step 2 — Waiver** (`/onboarding/waiver`)
- `ScrollController` on waiver body
- Checkbox disabled until scroll reaches bottom (`atEdge && pixels > 0`)
- On accept: `lightImpact` haptic
- Back: → goal selection (goal preserved in OnboardingNotifier)

**Step 3 — Pre-Assessment** (`/onboarding/assessment`)
- Required: emergency contact name, phone (with `textInputAction: next`, `focusNode` chain)
- Optional multiline: injuries, medical conditions, medications
- Back: → waiver

**Step 4 — Profile Setup** (`/onboarding/profile-setup`)
- Height (cm), weight (kg), age — `TextInputType.number`
- Gender: 4 `FilterChip` options
- Live BMI display: `weight / (height/100)²` with colored category label
- "Complete Setup" → `isSubmitting = true` → call `mobile:submitOnboarding`
- On fail: `AppSnackbar.error`, stay on screen, form intact
- On success: `mediumImpact` haptic + set `onboarding_complete_{userId}` in StorageService → `appInitProvider = ready`

### Onboarding Progress Bar
```dart
// 4-dot row at top of each step
// Active/completed: AppColors.primary (#39FF14)
// Future: AppColors.border (#222222)
```

---

## 5. Home Screen (Basic)

Replaces placeholder. Shows:
- Greeting: "Good morning, [name]" (time-aware)
- No-trainer banner (conditional, yellow, auto-dismisses via real-time)
- Subscription status card (active/expired/none)
- Next session card (if upcoming booking exists)
- Quick action buttons: "Book Session", "View Plans", "Log Progress"

### No-Trainer Banner
```dart
// Yellow (#F59E0B) background, 12dp radius card
// "Waiting for trainer assignment" message
// Watches memberProfileProvider — auto-hides when trainerId non-null
// Uses Convex real-time subscription (StreamNotifier)
```

---

## 6. Haptics Map (Sprint 1)

| Trigger | Haptic |
|---|---|
| Login success | `mediumImpact` |
| Login wrong password | `heavyImpact` |
| Goal card tap | `selectionClick` |
| Waiver accept | `lightImpact` |
| Onboarding complete | `mediumImpact` |
| Back button (onboarding) | `lightImpact` |

---

## 7. Files to Create (Sprint 1)

```
lib/src/features/auth/
├── data/
│   ├── auth_repository.dart            (abstract)
│   └── convex_auth_repository.dart     (implements)
├── domain/
│   └── auth_state.dart                 (Freezed union — first @freezed in project)
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart           (@riverpod AuthNotifier)
    │   └── onboarding_provider.dart     (@riverpod OnboardingNotifier)
    └── screens/
        ├── splash_screen.dart           (REWRITE — real auth check)
        ├── login_screen.dart            (REPLACE placeholder)
        ├── forgot_password_screen.dart  (NEW)
        ├── reset_password_screen.dart   (NEW)
        └── onboarding/
            ├── goal_selection_screen.dart
            ├── waiver_screen.dart
            ├── pre_assessment_screen.dart
            └── profile_setup_screen.dart

lib/src/features/home/
└── presentation/
    └── screens/
        └── home_screen.dart             (REPLACE placeholder)

convex/auth.ts                           (PATCH — remove admin-only guard)
```

After creating `@freezed` and `@riverpod` files, run:
```
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 8. Security Checklist

- [ ] No credentials logged (no `debugPrint` of email/password)
- [ ] Token stored in `FlutterSecureStorage` (encrypted Android prefs + iOS keychain)
- [ ] `deleteAll()` called on sign-out — no stale data
- [ ] Session expiry intercepted globally — no screen where 401 hangs silently
- [ ] Onboarding flag scoped to `userId` — switching accounts resets onboarding state
- [ ] Forgot-password OTP expires server-side (Convex handles, 1 hour per auth.ts)
