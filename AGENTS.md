# 24 Fit Camp Mobile - Project Instructions for AI Assistants

This file provides context and guidelines for AI assistants working on the 24 Fit Camp Mobile App.

## Project Overview

24 Fit Camp is a gym management ecosystem developed as a Software Engineering academic project for 24 Fit Camp Playground & Fitness Gym in Tagum City, Philippines.

**This Repository Contains:**
- Flutter Mobile App for Members and Trainers

**User Roles:**
- **Member**: Book sessions, track progress, chat with trainer, view plans
- **Trainer**: Manage clients, schedule, assign plans, chat with members

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (flutter_riverpod)
- **Routing**: GoRouter
- **Backend**: Convex (via convex_flutter)
- **Icons**: Material Design + flutter_svg

## Commands

```bash
flutter pub get           # Install dependencies
flutter run               # Run on device/emulator
flutter build apk         # Build Android APK
flutter build ios         # Build iOS (macOS only)
flutter test              # Run tests
flutter analyze           # Static analysis
```

## Architecture

### Feature-First Structure

```
lib/
├── src/
│   ├── features/
│   │   └── {feature_name}/
│   │       ├── data/       # Repositories, data sources
│   │       ├── domain/     # Entities, use cases
│   │       └── presentation/ # Screens, widgets, providers
│   ├── shared/             # Shared widgets, theme, router
│   └── core/               # Services, models, constants
└── main.dart
```

### State Management

Use Riverpod for all state:

```dart
// Provider
final userProvider = StateProvider<User?>((ref) => null);

// Notifier
class BookingNotifier extends StateNotifier<List<Booking>> {
  BookingNotifier() : super([]);
}

final bookingProvider = StateNotifierProvider<BookingNotifier, List<Booking>>(
  (ref) => BookingNotifier(),
);
```

## Folder Conventions

```
lib/src/
├── features/
│   ├── auth/              # Authentication & onboarding
│   ├── booking/           # Session booking
│   ├── chat/              # Real-time messaging
│   ├── progress/          # Weight, BMI, photos tracking
│   ├── training/          # Workout & diet plans
│   ├── subscription/      # Membership status
│   └── profile/           # User profiles
├── shared/
│   ├── widgets/           # Reusable widgets (buttons, cards, inputs)
│   ├── theme/             # AppTheme, colors, text styles
│   └── router/            # GoRouter configuration
└── core/
    ├── services/          # ConvexService, StorageService
    └── models/            # Data models
```

## Coding Standards

1. **Dart**: Follow effective Dart guidelines
2. **Widgets**: Prefer stateless widgets. Use ConsumerWidget/ConsumerStatefulWidget for Riverpod
3. **Naming**:
   - Files: snake_case (`booking_screen.dart`)
   - Classes: PascalCase (`BookingScreen`)
   - Variables: camelCase (`bookingList`)
   - Constants: camelCase (`defaultPadding`)
4. **Imports**: Package imports first, then relative imports
5. **Comments**: Use doc comments (`///`) for public APIs

## Convex Integration

Convex backend lives in the `24-fit-camp-web` repository. This app connects via `convex_flutter`.

```dart
import 'package:convex_flutter/convex_flutter.dart';

// Queries
final bookings = await convex.query('bookings:getByMember', {
  'memberId': userId,
});

// Mutations
await convex.mutation('bookings:create', {
  'memberId': userId,
  'trainerId': trainerId,
  'date': '2026-02-23',
  'startTime': '09:00',
  'endTime': '10:00',
});
```

## Onboarding Flow

| Step | Screen | Description |
|------|--------|-------------|
| 1 | Onboarding Slides | 3–4 slides introducing app features |
| 2 | Registration | Name, email, phone, password |
| 3 | Goal Selection | Cardio / Lose Weight / Gain Muscle / Maintain Weight / Health Reason |
| 4 | Waiver Agreement | Digital waiver — must accept |
| 5 | Privacy Policy | Data handling — must accept |
| 6 | Pre-Assessment | Health history: injuries, conditions, medications |
| 7 | Profile Setup | Height, weight, age, gender, photo |
| 8 | Dashboard | Full app access |

## Feature Priorities

Based on stakeholder interviews:

1. **Session booking** - Replace verbal/Facebook booking
2. **Direct trainer-member chat** - Eliminate admin middleman
3. **Digital training/diet plans** - Currently verbal only
4. **Progress tracking** - Members currently track themselves
5. **Subscription status** - Replace card scanner system

## Security Notes

- All API calls over HTTPS
- Convex handles JWT authentication
- Store sensitive data in Flutter Secure Storage
- Pre-assessment data is private

## Pricing Reference

| Duration | Regular | Student |
|----------|---------|---------|
| 1 Month | PHP 1,000 | PHP 600 |
| 3 Months | PHP 2,700 | PHP 1,500 |
| 6 Months | PHP 4,500 | PHP 3,000 |
| 12 Months | PHP 6,500 | PHP 5,400 |
| Daily Walk-in | PHP 100 | PHP 80 |

## Out of Scope (v1.0)

- In-app payment processing
- Push notifications (in-app only)
- AI food classifier
- Third-party fitness device integration

## Related Documentation

- See `24-fit-camp-web/docs/` for full project documentation
- Database schema: `24-fit-camp-web/convex/schema.ts`

## Team

| Name | Role |
|------|------|
| Ryan Christian Deniega | Project Lead |
| Jovan Reguya | Frontend Developer |
| Nemuel Laid Jr. | QA / Integration |
| Ric Angelo Galo | Backend Developer |

---

*Document prepared for AI assistant context. Last updated: February 2026*
