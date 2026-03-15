# Sprint 2 — Booking & Scheduling: Brainstorm

## Backend Constraints

- `requestBooking` resolves trainer **server-side** from `memberProfile.trainerId`
- Client does not pick a trainer — assigned by admin
- Only **pending** bookings can be cancelled by member
- Confirmed/completed bookings require trainer/admin action on web
- Conflict resolution is server-side (trainer confirms/rejects pending requests)
- `trainerAvailability` stores recurring slots by `dayOfWeek` (0–6), not specific dates

## Booking Flow (Member)

1. Tap "Book Session" → load assigned trainer's availability
2. If no trainer assigned → empty state: "No trainer assigned yet. Contact your gym admin."
3. Month calendar with neon green dot markers on days matching trainer's available dayOfWeek
4. Tap date → show available time slots below calendar (vertical list, not grid)
5. Tap slot → confirmation bottom sheet (trainer avatar, date, time, notes field)
6. Submit → optimistic "Pending" card appears → trainer notified

## Trainer Role (Mobile)

- Trainers see read-only list of their bookings (all statuses)
- No booking actions on mobile — manage via web dashboard
- Same two-tab layout (Upcoming / Past) but no cancel swipe

## Calendar UX

- **Month view** via `TableCalendar` — best for "when is my trainer free?" mental model
- Week view too cramped; list view loses date context
- Dot markers: neon green for available days, amber for days with pending bookings
- Tapping a date loads time slots below (no separate screen)
- Past dates greyed out, not tappable

## Time Slot Cards

- Vertical list below calendar (1-hour slots don't need grid density)
- Each card: time range ("9:00 AM – 10:00 AM")
- States: available (green outline), already booked by you (amber/green badge), past (greyed)
- No conflict check client-side — all requests go in as "pending"

## Empty States

| Scenario | Message |
|---|---|
| No trainer assigned | Trainer silhouette icon + "No trainer assigned yet. Contact your gym admin." |
| No slots on selected date | "No available slots on this day. Try another date." |
| No upcoming bookings | "No upcoming sessions" + "Book Now" button |
| No past bookings | "No past sessions yet." |

## Feedback & Haptics

| Action | Haptic | Visual |
|---|---|---|
| Tap calendar date | `selectionClick` | Date highlights, slots load below |
| Tap time slot | `selectionClick` | Slot highlights, bottom sheet slides up |
| Submit booking | `mediumImpact` | Button spinner → dismiss sheet → green snackbar "Booking request sent!" |
| Cancel booking (confirm) | `mediumImpact` | AnimatedList slide-out → snackbar "Booking cancelled" |
| Error | `heavyImpact` | Red snackbar with message |

## Confirmation Bottom Sheet

- Trainer avatar + name
- Selected date (formatted: "Monday, March 10, 2026")
- Selected time ("9:00 – 10:00 AM")
- Optional notes text field (max 200 chars)
- "Request Session" primary button
- "Cancel" text button

## Cancel Flow

- Swipe-to-reveal on pending bookings only (Upcoming tab)
- Bottom sheet: "Cancel this session?" + date/time reminder
- Red "Cancel Booking" button + "Keep it" text button
- Optimistic removal → rollback on error

## Booking Home Screen Tabs

1. **Upcoming** — pending + confirmed, sorted by date ascending (nearest first)
2. **Past** — completed + cancelled, sorted by date descending

Cancelled bookings appear in Past with "Cancelled" badge. No separate tab.

## Booking Card Design

- Trainer avatar (small circle) + name
- Date: "Mon, Mar 10"
- Time: "9:00 – 10:00 AM"
- Status badge: Pending (amber), Confirmed (green), Completed (blue), Cancelled (red/muted)
- Swipe action: Cancel (pending only, Upcoming tab only)

## Home Screen Integration

- "Next Session" card shows nearest future booking (non-cancelled)
- Pending: amber "Awaiting confirmation" + date
- Confirmed: green "Confirmed" + relative time ("Tomorrow at 9 AM" / "In 3 days")
- No bookings: "No upcoming sessions" + "Book Now" text button

## YAGNI — Not Building

- No trainer selection UI (server-side assignment)
- No rescheduling (cancel + rebook)
- No recurring bookings
- No push notifications (Sprint 6)
- No separate booking detail screen (card shows all info)
- No timezone handling (single-gym, local timezone)
- No booking limits/cooldowns
