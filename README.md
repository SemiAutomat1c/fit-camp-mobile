# 24 Fit Camp - Mobile App

Gym Management Ecosystem mobile app for Members and Trainers of 24 Fit Camp Playground & Fitness Gym, Tagum City, Philippines.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Routing | GoRouter |
| Backend | Convex (via convex_flutter) |
| Icons | Material Design + Flutter SVG |

## Project Structure

```
lib/
├── src/
│   ├── features/
│   │   ├── auth/           # Login, registration, onboarding
│   │   │   ├── data/       # Data sources, repositories
│   │   │   ├── domain/     # Entities, use cases
│   │   │   └── presentation/ # Screens, widgets, providers
│   │   ├── booking/        # Session booking
│   │   ├── chat/           # Real-time chat
│   │   ├── progress/       # Weight, BMI, photos
│   │   ├── training/       # Workout/diet plans
│   │   ├── subscription/   # Membership status
│   │   └── profile/        # Member/Trainer profiles
│   ├── shared/
│   │   ├── widgets/        # Reusable widgets
│   │   ├── theme/          # Colors, text styles
│   │   └── router/         # GoRouter configuration
│   └── core/
│       ├── services/       # Convex service, storage
│       └── models/         # Data models
└── main.dart

assets/
├── images/
├── icons/
└── fonts/
```

## Commands

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build APK
flutter build apk

# Build iOS (macOS only)
flutter build ios

# Run tests
flutter test

# Generate code (if using build_runner)
flutter pub run build_runner build
```

## User Roles

| Role | Features |
|------|----------|
| Member | Booking, progress tracking, chat with trainer, view plans |
| Trainer | Client management, schedule, assign plans, chat with members |

## Features

### Member App
- Registration & onboarding (goal selection, waiver, pre-assessment)
- Dashboard (BMI, weight log, upcoming sessions)
- Session booking (calendar, time slots, history)
- Real-time chat with trainer & admin
- View training & diet plans
- Progress tracking (photos, weight, BMI)
- Subscription status

### Trainer App
- Client list with health indicators
- Schedule management
- Create/assign training & diet plans
- Track client progress
- Session notes
- Direct chat with members
- Report equipment issues

## Dependencies

Key packages in `pubspec.yaml`:

```yaml
dependencies:
  convex_flutter: ^0.4.0      # Convex backend integration
  flutter_riverpod: ^2.5.1    # State management
  go_router: ^14.0.0          # Navigation
  image_picker: ^1.0.7        # Progress photos
  intl: ^0.19.0               # Date formatting
  cached_network_image: ^3.3.1 # Image caching
  flutter_svg: ^2.0.10+1      # SVG support
```

## Team

| Name | Role |
|------|------|
| Ryan Christian Deniega | Project Lead |
| Jovan Reguya | Frontend Developer |
| Nemuel Laid Jr. | QA / Integration |
| Ric Angelo Galo | Backend Developer |

## Related Repositories

- **Web Admin + Backend**: `24-fit-camp-web` (React + Convex)

---

*Software Engineering Academic Project | 2026*
