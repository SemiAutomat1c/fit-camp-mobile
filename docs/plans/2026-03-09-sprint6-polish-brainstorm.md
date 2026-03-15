# Sprint 6 — Polish: Brainstorm

## Scope Decision

Keep it tight. Build the missing screens + quality pass. Cut anything that's a refactor.

### Building
1. **Profile screen** — view profile info, subscription card, trainer card, sign out
2. **Notifications** — bell icon + badge, notification list, mark read, tap-to-navigate
3. **Accessibility pass** — Semantics labels on interactive elements, touch target audit

### NOT Building (YAGNI)
- No light mode toggle (entire app is dark-themed, refactoring all AppColors is Sprint 7 territory)
- No profile editing (updateMyProfile exists but adding edit forms is feature work, not polish)
- No haptics audit (already added per-feature during Sprints 1-5)
- No empty state audit (already added per-feature)
- No push notifications (requires native config, FCM setup — separate effort)
- No confetti/celebration animations

---

## Profile Screen

### Data Sources
- `mobile:getMyProfile` → profile fields (goal, height, weight, age, gender) + trainer snapshot + user info (name, email, phone, avatarUrl)
- `mobile:getMySubscription` → active subscription (type, startDate, endDate, pricePaid, isStudent)

### Layout
1. Avatar (large, 80dp circle) + name + email
2. Phone number
3. Subscription card (if active): type badge, date range, student discount indicator
4. Trainer card: avatar + name, or "No trainer assigned"
5. Profile details: goal, age, gender, height, weight (read-only info chips)
6. Sign Out button (red text, bottom)

### Sign Out Flow
- Tap "Sign Out" → confirmation dialog: "Are you sure you want to sign out?"
- Confirm → call authNotifier.signOut() (already clears storage + resets state)
- Redirect happens via GoRouter redirect (appInitProvider → unauthenticated → /login)

### No Subscription State
- "No active subscription" muted text
- "Contact your gym admin" caption

---

## Notifications

### Backend Endpoints (all use requireUser, mobile-safe)
- `notifications:listForCurrentUser` (query) → 50 most recent, newest first
- `notifications:getUnreadCount` (query) → number
- `notifications:markRead` (mutation) → { notificationId }
- `notifications:markAllRead` (mutation) → no args

### Notification Types → Navigation
| Type | Navigate To |
|---|---|
| booking_request | /booking |
| booking_confirmed | /booking |
| new_message | /chat |
| training_plan_assigned | /training |
| diet_plan_assigned | /training |
| subscription_expiring | /profile |
| subscription_expired | /profile |
| maintenance_reported | (none — just show) |

### Bell Icon
- In MainScaffold AppBar (visible on all tabbed screens)
- Badge with unread count (red dot if > 0, number if > 0)
- Tap → push /notifications screen
- Poll unread count every 30 seconds (or just fetch on each tab switch)

### Notification List Screen
- AppBar: "Notifications" + "Mark All Read" text button
- ListView.builder of notification cards
- Each card: type icon + title + message + relative timestamp
- Unread: slightly brighter background (#1A1A1A vs #111111)
- Tap: mark as read + navigate based on type
- Empty: "You're all caught up!" with checkmark icon

### Type Icons
| Type | Icon |
|---|---|
| booking_request | Icons.calendar_today_rounded |
| booking_confirmed | Icons.event_available_rounded |
| new_message | Icons.chat_bubble_rounded |
| training_plan_assigned | Icons.fitness_center_rounded |
| diet_plan_assigned | Icons.restaurant_menu_rounded |
| subscription_expiring | Icons.warning_rounded |
| subscription_expired | Icons.error_rounded |
| maintenance_reported | Icons.build_rounded |

---

## Accessibility Pass

Focus areas (audit, not rebuild):
1. Add `Semantics` labels to icon buttons that have no text (notification bell, send button, etc.)
2. Verify all `InkWell`/`GestureDetector` tappable areas are 48dp+
3. Ensure `TextScaler` is not overridden anywhere
4. Verify contrast ratios on status badges (neon green on dark bg = fine, amber on dark = check)

---

## File Structure

```
lib/src/features/profile/
└── presentation/
    ├── providers/
    │   └── profile_provider.dart
    └── screens/
        └── profile_screen.dart

lib/src/features/notifications/
├── domain/entities/
│   └── app_notification.dart
├── data/
│   ├── notification_repository.dart
│   └── convex_notification_repository.dart
└── presentation/
    ├── providers/
    │   └── notification_provider.dart
    ├── screens/
    │   └── notifications_screen.dart
    └── widgets/
        ├── notification_bell.dart
        └── notification_card.dart
```

Update:
- `app_router.dart` — add /profile, /notifications routes
- `main_scaffold.dart` — add notification bell to AppBar
