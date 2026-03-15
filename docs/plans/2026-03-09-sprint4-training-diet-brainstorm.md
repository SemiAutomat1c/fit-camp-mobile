# Sprint 4 — Training & Diet Plans: Brainstorm

## Core Concept

Read-only display. No mutations. Trainers assign plans on web dashboard; mobile shows them.

## Data Shape

**Training Plan:** name, description?, exercises[] (name, sets?, reps?, duration?, notes?), isActive, trainerId, memberId, createdAt. Backend joins trainer/member snapshot.

**Diet Plan:** name, description?, meals[] (name, time, foods[], calories?, notes?), isActive, trainerId, memberId, createdAt. Same join pattern.

## Screen Structure

**Training tab** — two sub-tabs: Workout Plans / Diet Plans

Each tab shows a list of plan cards. Tapping a card opens a detail screen.

**Member view:** sees own plans. Active plans at top with green badge, inactive below.
**Trainer view:** sees all plans they've assigned. Each card shows the member's name.

## Plan Card Design

- Plan name (heading4)
- Trainer name (member view) or Member name (trainer view), muted
- Active/Inactive badge
- Exercise count or meal count as subtitle
- Created date, muted

## Training Plan Detail

- Header: plan name + active badge + trainer name
- Description if present
- Exercises as `ExpansionTile` list — tap to expand
- Collapsed: exercise name + sets×reps or duration chip
- Expanded: notes, all fields visible

## Diet Plan Detail

- Header: plan name + active badge + trainer name
- Description if present
- Meals as timeline cards (vertical line on left)
- Each meal: time badge, meal name, food items as chips, calories badge, notes

## Empty States

| State | Message |
|---|---|
| No training plans (member) | "Your trainer hasn't assigned a workout plan yet." |
| No diet plans (member) | "Your trainer hasn't assigned a diet plan yet." |
| No training plans (trainer) | "You haven't assigned any workout plans yet." |
| No diet plans (trainer) | "You haven't assigned any diet plans yet." |

## YAGNI — Not Building

- No plan creation/editing on mobile
- No exercise images/videos
- No "mark exercise as done" toggle
- No plan comparison
- No plan history/versioning
- No filtering by active/inactive (just sort active first)
- No search
