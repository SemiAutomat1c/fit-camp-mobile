# Sprint 5 — Progress Tracking: Brainstorm

## Data Shape

**ProgressLog:** memberId, date (epoch), weight?, bmi?, notes?, photoUrl?
- Member-only feature (trainers can't log)
- Photos uploaded via Convex storage (generateUploadUrl → HTTP PUT → storageId → logProgress)
- photoUrl resolved server-side from storageId

## Photo Upload Flow

1. User picks image (camera or gallery via `image_picker`)
2. Call `messages:generateUploadUrl` → get presigned URL
3. HTTP PUT the image bytes to that URL → get storageId from response
4. Pass `photoStorageId` to `mobile:logProgress`
5. Server resolves to photoUrl via `ctx.storage.getUrl()`

**Note:** `image_picker` needs to be added to pubspec.yaml. Also `http` package for the PUT request.

## Screen Structure

### ProgressHomeScreen
- Stats summary at top: current weight, BMI, total logs
- Weight chart (fl_chart LineChart) — weight over time
- BMI indicator bar
- Progress photo grid (most recent photos)
- "Log Today" FAB at bottom-right

### LogProgressScreen
- Date picker (defaults to today)
- Weight input (numeric)
- Auto-BMI calculation (needs height from profile — read from storage or profile endpoint)
- Notes text field
- Optional photo (camera/gallery picker)
- "Save" button

## Chart Design

**Weight Chart:**
- fl_chart LineChart
- X-axis: dates (last 30 days or all entries)
- Y-axis: weight in kg
- Neon green line with dots at data points
- Touch tooltip showing exact weight + date
- Grid lines: #222222
- If only 1 data point: show single dot, no line

**BMI Indicator:**
- Horizontal colored bar: Underweight (amber) | Normal (green) | Overweight (amber) | Obese (red)
- Marker showing current BMI position
- Category label below

## Stats Summary Cards

Row of 3 small cards at top:
- Current Weight: latest log weight, "kg" unit
- Current BMI: latest log BMI, category label
- Total Logs: count of all progress logs

## Photo Grid

- 3-column grid of progress photos
- Each photo: square thumbnail with date label overlay at bottom
- Tap: fullscreen view (Hero animation)
- Most recent first
- If no photos: "No progress photos yet"

## Empty States

| State | Message |
|---|---|
| No progress logs | "Start tracking your progress today!" + arrow pointing to FAB |
| No photos | "No progress photos yet. Add one with your next log!" |
| Chart with < 2 points | "Log more entries to see your trend." |

## Haptics

| Action | Haptic |
|---|---|
| Save progress log | mediumImpact |
| Pick photo | selectionClick |
| Error | heavyImpact |

## YAGNI — Not Building

- No personal best celebration (defer to Sprint 6)
- No streak counter
- No progress comparison (before/after)
- No photo deletion
- No editing past logs
- No weight goal setting
- No export/share
- No trainer view of member progress (web dashboard feature)

## BMI Auto-Calculation

BMI = weight / (height_m²)

Need member's height. Options:
1. Read from profile (stored during onboarding as heightCm in memberProfile)
2. Fetch via `mobile:getMyProfile` endpoint

Use option 2 — fetch profile once, extract heightCm, calculate BMI client-side.
