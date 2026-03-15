# Sprint 2 — Booking & Scheduling: Mobile Design Spec

## Checkpoint

```
Platform:   iOS + Android (Cross-platform)
Framework:  Flutter + Riverpod + GoRouter
Files Read: mobile-design-thinking.md, touch-psychology.md, mobile-performance.md

3 Principles Applied:
1. ListView.builder with const item widgets for booking lists
2. 48dp minimum touch targets — calendar row height 52dp, slot cards 64dp, buttons 48dp+
3. Only animate transform/opacity (SlideTransition + FadeTransition for card insertion)

Anti-Patterns Avoided:
1. ScrollView for lists → ListView.builder with itemExtent
2. setState overuse → Riverpod targeted watches with .select()
3. Gesture-only interactions → swipe-to-cancel has visible long-press menu alternative
```

## Design Commitment

```
Project: 24 Fit Camp — Booking Sprint
Default I will NOT use: FAB for "Book Session" — bottom sheet flow instead, triggered from booking list screen button
Context focus: Gym booking is time-sensitive; members need fast date→slot→confirm flow (3 taps)
Platform differences:
  iOS: Edge swipe back from calendar/confirmation
  Android: System back button respects GoRouter stack
Performance focus: Calendar rendering — avoid rebuilding month grid on slot selection
Unique challenge: trainerAvailability is by dayOfWeek, not specific dates — must map recurring slots to calendar dates
```

---

## Screen 1: Booking Home Screen

### Decomposition

```
SCREEN: BookingHomeScreen
├── PRIMARY ACTION: Book a session (button at top)
│   └── In comfortable zone (below app bar, above list)
│
├── TOUCH TARGETS:
│   ├── "Book a Session" button: 48dp height, full width → Sufficient
│   ├── Tab bar items: 48dp height → Sufficient
│   ├── Booking cards: 88dp height minimum → Sufficient
│   └── Swipe-to-cancel: 64dp reveal area → Sufficient
│
├── SCROLLABLE CONTENT:
│   ├── Is it a list? → Yes, ListView.builder
│   ├── Item count: ~5-20 bookings typical → Low, but use builder anyway
│   └── Fixed height? → No (notes may vary) → No itemExtent
│
├── STATE:
│   ├── Booking list: Global (Riverpod StreamNotifier from Convex subscription)
│   ├── Tab index: Local (TabController)
│   └── Cancel loading: Local per card (setState)
│
└── PERFORMANCE:
    ├── Const constructors on status badges
    ├── Riverpod .select() for status filtering in each tab
    └── AnimatedList for optimistic cancel removal
```

### Layout

```
┌──────────────────────────────────────┐
│  ← Bookings                         │  AppBar: title only, no actions
├──────────────────────────────────────┤
│  [════════ Book a Session ═════════] │  PrimaryButton, 48dp, full width, 16dp horizontal padding
│                                      │
├──────────────────────────────────────┤
│  [ Upcoming ]  [ Past ]             │  TabBar: 2 tabs, neon green indicator on #111111 background
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐  │
│  │  👤 Coach Maria               │  │  Booking card: trainer avatar (40dp circle) + name
│  │  Mon, Mar 10 · 9:00–10:00 AM │  │  Date + time on second line
│  │  ● Confirmed                  │  │  Status badge: green dot + text
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  👤 Coach Maria               │  │
│  │  Wed, Mar 12 · 2:00–3:00 PM  │  │
│  │  ● Pending                    │  │  Amber badge; swipeable left to reveal cancel
│  └────────────────────────────────┘  │
│                                      │
│  ... (scrollable)                    │
│                                      │
└──────────────────────────────────────┘
```

### Tab Bar Styling

- Background: `#111111` (surface)
- Indicator: `#39FF14` (neon green), 3dp thick, pill shape
- Selected text: `#39FF14`
- Unselected text: `#A1A1AA`
- Tab height: 48dp
- Divider below tabs: `#222222`, 1dp

### Booking Card Styling

- Background: `#111111` (surface)
- Border: `#222222`, 1dp, radius 12dp
- Padding: 16dp
- Min height: 80dp
- Trainer avatar: 40dp circle, left-aligned
- Text: name `heading4` white, date/time `body` muted, status `caption`
- Status colors: Pending `#F59E0B` (amber), Confirmed `#39FF14` (green), Completed `#3B82F6` (blue), Cancelled `#EF4444` (red) at 60% opacity

### Swipe-to-Cancel

- Only on pending cards in Upcoming tab
- `Dismissible` widget with `direction: DismissDirection.endToStart`
- Background: `#EF4444` (red) at 20% opacity
- Icon: trash icon, white, centered in reveal area
- Threshold: 0.3 of card width
- On threshold reached: `mediumImpact` haptic
- On dismiss: show cancel confirmation bottom sheet (don't delete immediately)
- Accessibility alternative: long press → bottom sheet with "Cancel Booking" option

### Empty States

- Upcoming empty: calendar icon (48dp, muted) + "No upcoming sessions" heading4 + "Book your first session!" body muted
- Past empty: clock icon (48dp, muted) + "No past sessions yet." body muted

### Loading Skeleton

- 3 skeleton cards matching card layout dimensions
- Shimmer: base `#111111`, highlight `#1A1A1A`, 1200ms duration

---

## Screen 2: Booking Calendar Screen

### Decomposition

```
SCREEN: BookingCalendarScreen
├── PRIMARY ACTION: Select date + time slot
│   └── Calendar is mid-screen (OK zone), slots below (EASY zone)
│
├── TOUCH TARGETS:
│   ├── Calendar day cells: 52dp height (via rowHeight) → Sufficient
│   ├── Time slot cards: 64dp height → Sufficient
│   ├── Month navigation arrows: 48dp tap area → Sufficient
│   └── Back button: 48dp → Sufficient
│
├── SCROLLABLE CONTENT:
│   ├── Calendar: Not scrollable (month grid)
│   ├── Time slots: ListView.separated below calendar
│   ├── Item count: ~8-12 slots per day
│   └── Fixed height? → Yes, 64dp → Use itemExtent
│
├── STATE:
│   ├── Selected date: Local (StatefulWidget)
│   ├── Trainer availability: Global (Riverpod query)
│   ├── Existing bookings for conflict display: Global (already loaded)
│   └── Selected slot: Local → triggers bottom sheet
│
└── PERFORMANCE:
    ├── Calendar: TableCalendar with const day builders
    ├── Slot list: itemExtent: 64 for fast layout
    └── Avoid rebuilding calendar when slot is selected (split state)
```

### Layout

```
┌──────────────────────────────────────┐
│  ← Book a Session                    │  AppBar with back arrow
├──────────────────────────────────────┤
│                                      │
│  ◀  March 2026  ▶                   │  Month/year header, 48dp tap arrows
│                                      │
│  Mo  Tu  We  Th  Fr  Sa  Su        │  Day-of-week headers, muted text
│  ┌──┬──┬──┬──┬──┬──┬──┐            │
│  │  │  │  │  │  │ 1│ 2│            │  Row height: 52dp
│  ├──┼──┼──┼──┼──┼──┼──┤            │  Today: neon green circle outline
│  │ 3│ 4│ 5│ 6│ 7│ 8│ 9│            │  Available days: green dot below number
│  ├──┼──┼──┼──┼──┼──┼──┤            │  Selected day: filled neon green circle
│  │10│11│12│13│14│15│16│            │  Past days: 40% opacity, not tappable
│  └──┴──┴──┴──┴──┴──┴──┘            │  Unavailable days: normal, no dot
│                                      │
├──────────────────────────────────────┤  Divider: #222222
│                                      │
│  Available Slots                     │  Section header, heading4
│                                      │
│  ┌────────────────────────────────┐  │
│  │  🕐  9:00 AM – 10:00 AM      │  │  Time slot card: 64dp, clock icon + time
│  └────────────────────────────────┘  │  Border: neon green outline when available
│  ┌────────────────────────────────┐  │
│  │  🕐  10:00 AM – 11:00 AM     │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │  🕐  2:00 PM – 3:00 PM       │  │
│  └────────────────────────────────┘  │
│                                      │
└──────────────────────────────────────┘
```

### Calendar Styling (TableCalendar)

- `formatButtonVisible: false` — no format toggle, always month
- `rowHeight: 52` — ensures 48dp+ touch targets
- `headerStyle`: center title, arrows are `IconButton` with 48dp implicit tap area
- `calendarStyle`:
  - `todayDecoration`: circle outline, neon green, 1dp border
  - `selectedDecoration`: filled circle, neon green
  - `selectedTextStyle`: black text on green
  - `defaultTextStyle`: white
  - `disabledTextStyle`: white at 40% opacity
  - `outsideDaysVisible: false`
- `calendarBuilders.markerBuilder`: neon green dot (6dp circle) below day number for available days
- `enabledDayPredicate`: only today and future dates

### Time Slot Card Styling

- Background: `#111111`
- Border: `#39FF14` at 30% opacity (available), `#222222` (unavailable)
- Height: 64dp
- Padding: 16dp horizontal
- Icon: clock outline, 20dp, muted
- Text: time range in `body` style, white
- Tap: `selectionClick` haptic → opens confirmation bottom sheet
- Already-booked slot (by this user): amber border + "Pending"/"Confirmed" trailing badge, not tappable

### No Slots State

- Below calendar, centered
- Calendar outline icon, 48dp, muted
- "No available slots on this day." body, muted
- "Try selecting another date." caption, muted

### Mapping dayOfWeek to Calendar Dates

- `trainerAvailability` gives `dayOfWeek` (0=Sunday, 6=Saturday) + `startTime`/`endTime`
- For each visible month, compute which dates fall on available days-of-week
- Mark those dates with green dot
- On date tap, filter availability slots matching that date's `dayOfWeek`
- Generate 1-hour slot cards from each availability window (e.g., 9:00-12:00 → three cards: 9-10, 10-11, 11-12)

---

## Screen 3: Booking Confirmation Bottom Sheet

### Layout

```
┌──────────────────────────────────────┐
│          ─────                        │  Drag handle: 32dp wide, 4dp tall, #222222, centered
│                                      │
│  Confirm Session                     │  heading3, white
│                                      │
│  ┌────────────────────────────────┐  │
│  │  👤  Coach Maria              │  │  Trainer avatar (48dp) + name, inside surface card
│  └────────────────────────────────┘  │
│                                      │
│  📅  Monday, March 10, 2026         │  Date with icon, body, white
│  🕐  9:00 AM – 10:00 AM            │  Time with icon, body, white
│                                      │
│  ┌────────────────────────────────┐  │
│  │  Notes to trainer (optional)  │  │  AppTextField, max 200 chars, multiline 3 lines
│  │                                │  │
│  └────────────────────────────────┘  │
│                                      │
│  [═══════ Request Session ════════]  │  PrimaryButton, 48dp height
│                                      │
│  (16dp bottom padding + safe area)   │
└──────────────────────────────────────┘
```

### Styling

- `showModalBottomSheet` with `isScrollControlled: true`
- Background: `#0A0A0A`
- Border radius: top 16dp
- Max height: 50% of screen (content doesn't need more)
- Drag handle: centered, 32×4dp, `#222222`, 8dp top padding
- Trainer card: `#111111` background, 12dp radius, 16dp padding
- Date/time rows: icon 20dp muted + 12dp gap + text
- Notes field: 3-line max, `#111111` fill, `#222222` border
- Button: full width, 16dp horizontal margin, 16dp bottom margin above safe area

### Submit Flow

1. Tap "Request Session" → `mediumImpact` haptic
2. Button shows loading spinner (disable tap)
3. Call `mobile:requestBooking` with `date` (epoch), `startTime`, `endTime`, `notes`
4. Success → dismiss bottom sheet → dismiss calendar screen (pop to booking list) → green snackbar "Booking request sent!" → new card appears in Upcoming tab
5. Error → `heavyImpact` haptic → red snackbar with message → button re-enables

---

## Screen 4: Cancel Confirmation Bottom Sheet

### Layout

```
┌──────────────────────────────────────┐
│          ─────                        │  Drag handle
│                                      │
│  Cancel Session?                     │  heading3, white
│                                      │
│  📅  Monday, March 10, 2026         │  Date reminder
│  🕐  9:00 AM – 10:00 AM            │  Time reminder
│                                      │
│  [══════ Cancel Booking ═══════════] │  Red button: #EF4444 background, white text
│                                      │
│  [         Keep It         ]         │  Text button: muted, no background
│                                      │
│  (16dp bottom + safe area)           │
└──────────────────────────────────────┘
```

### Styling

- Background: `#0A0A0A`
- Max height: 35% of screen
- Cancel button: `#EF4444` background, white text, 48dp height, full width
- "Keep It" button: text only, muted, 48dp height (touch target)
- 12dp gap between buttons

### Cancel Flow

1. Tap "Cancel Booking" → `mediumImpact` haptic
2. Button shows loading spinner
3. Call `mobile:cancelMyBooking` with `bookingId`
4. Success → dismiss bottom sheet → optimistic card removal (AnimatedList slide-out, 200ms) → snackbar "Booking cancelled"
5. Error → `heavyImpact` haptic → red snackbar → card remains

---

## Screen 5: Home Screen "Next Session" Card

### Layout (replaces placeholder on existing HomeScreen)

```
┌────────────────────────────────────┐
│  Next Session                      │  Section header, heading4
│                                    │
│  ┌──────────────────────────────┐  │
│  │  👤  Coach Maria             │  │  Trainer avatar 40dp + name
│  │  Tomorrow · 9:00 AM         │  │  Relative date + time
│  │  ● Confirmed                │  │  Status badge
│  └──────────────────────────────┘  │
└────────────────────────────────────┘
```

### Relative Date Formatting

- Today: "Today at 9:00 AM"
- Tomorrow: "Tomorrow at 9:00 AM"
- This week: "Wednesday at 2:00 PM"
- Further: "Mon, Mar 17 at 9:00 AM"

### No Booking State

```
┌────────────────────────────────────┐
│  Next Session                      │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  No upcoming sessions        │  │  body, muted, centered
│  │  [Book Now]                  │  │  Text button, neon green, underlined
│  └──────────────────────────────┘  │
└────────────────────────────────────┘
```

- Card: `#111111`, 12dp radius, 16dp padding
- "Book Now" navigates to `/booking/calendar`
- Tap on booking card navigates to `/booking` (booking list)

---

## Animation Specs

| Animation | Type | Duration | Easing |
|---|---|---|---|
| Card insertion (optimistic) | SlideTransition (x: 1→0) + FadeTransition | 250ms | Curves.easeOut |
| Card removal (cancel) | SlideTransition (x: 0→1) + FadeTransition | 200ms | Curves.easeIn |
| Bottom sheet open | Default Material `showModalBottomSheet` | ~250ms | Curves.easeOut |
| Tab switch | Default TabBarView swipe | ~300ms | Curves.easeInOut |
| Calendar date select | Instant (no animation needed) | 0ms | — |
| Slot card highlight | Background color fade | 150ms | Curves.easeOut |

All animations use only transform + opacity (GPU-accelerated).

---

## File Structure

```
lib/src/features/booking/
├── domain/entities/
│   ├── booking.dart              # Freezed: Booking entity
│   └── trainer_slot.dart         # Freezed: TrainerSlot entity
├── data/
│   ├── booking_repository.dart   # Abstract interface
│   └── convex_booking_repository.dart  # Convex implementation
└── presentation/
    ├── providers/
    │   └── booking_provider.dart  # Riverpod notifiers
    ├── screens/
    │   ├── booking_home_screen.dart     # Tabs: Upcoming/Past
    │   └── booking_calendar_screen.dart # Calendar + slots
    └── widgets/
        ├── booking_card.dart           # Reusable booking card
        ├── time_slot_card.dart         # Time slot selection card
        ├── booking_confirm_sheet.dart  # Confirmation bottom sheet
        └── booking_cancel_sheet.dart   # Cancel confirmation sheet
```

Plus update:
- `home_screen.dart` — add Next Session card
- `app_router.dart` — add `/booking`, `/booking/calendar` routes
- `main_scaffold.dart` — wire up Booking tab
