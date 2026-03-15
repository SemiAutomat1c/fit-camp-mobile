# Sprint 3 — Real-Time Chat: Mobile Design Spec

## Checkpoint

```
Platform:   iOS + Android
Framework:  Flutter + Riverpod + GoRouter
3 Principles:
1. Reversed ListView.builder for chat — only render visible bubbles
2. 48dp+ touch targets on send button, retry tap, conversation rows
3. Dispose polling timer + stop on app background via WidgetsBindingObserver

Anti-Patterns Avoided:
1. ScrollView for messages → reversed ListView.builder
2. Polling when backgrounded → pause via lifecycle observer
3. No mounted check after await → always check before context usage
```

---

## Screen 1: Chat Tab (Member — Auto-Route to Room)

Members skip the conversation list. The Chat tab widget:
1. Fetches `getMyConversation`
2. If loading → centered spinner
3. If no trainer → empty state (no trainer assigned)
4. If no conversation → "Start chatting" screen with button → calls `startConversation`
5. If conversation exists → render ChatRoomScreen inline (no navigation push)

This means the Chat tab IS the chat room for members. No intermediate list.

### No Trainer Empty State
- Person-off icon, 64dp, muted
- "No trainer assigned yet" heading4, white
- "Contact your gym admin to get started." body, muted
- Centered vertically

### Start Conversation Screen
- Chat bubble icon, 64dp, neon green at 30% opacity
- "Chat with your trainer" heading4, white
- "Send messages about training, diet, or schedule." body, muted
- PrimaryButton: "Start Conversation" → calls startConversation → transitions to room

---

## Screen 2: Chat Tab (Trainer — Conversation List)

### Layout

```
┌──────────────────────────────────────┐
│  Messages                            │  AppBar title
├──────────────────────────────────────┤
│  ┌────────────────────────────────┐  │
│  │ 👤  Juan Dela Cruz            │  │  Row: avatar 44dp + name + last msg preview
│  │     "Thanks coach, see yo..."  │  │  Last message truncated 50 chars, muted
│  │                     2:30 PM   │  │  Relative timestamp, trailing
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │ 👤  Maria Santos              │  │
│  │     "What time tomorrow?"      │  │
│  │                     Yesterday │  │
│  └────────────────────────────────┘  │
│                                      │
│  ... (scrollable, ListView.builder)  │
└──────────────────────────────────────┘
```

### Conversation Row Styling
- Height: 72dp minimum (48dp touch + padding)
- Avatar: 44dp circle, left
- Name: heading4, white
- Last message: body, muted, maxLines 1, overflow ellipsis
- Timestamp: caption, muted, trailing aligned
- Divider: #222222, 1dp, indented 72dp from left
- Tap → push ChatRoomScreen(conversationId, otherName, otherAvatar)
- Polling: every 15 seconds via Timer.periodic, paused on background

### Empty State (Trainer)
- Chat bubbles icon, 64dp, muted
- "No conversations yet" heading4
- "Members will appear here when they start chatting." body, muted

### Loading
- 4 skeleton list tiles with shimmer

---

## Screen 3: Chat Room

### Layout

```
┌──────────────────────────────────────┐
│  ← Coach Maria                       │  AppBar: back arrow + other person's name
├──────────────────────────────────────┤
│                                      │
│         ── Today ──                  │  Day group header, centered, muted
│                                      │
│  ┌──────────────┐                    │  Received: left-aligned
│  │ Hey! How was │                    │  #1A1A1A bg, white text
│  │ your workout?│                    │  12dp radius
│  └──────────────┘                    │
│           9:15 AM                    │  Timestamp below, caption, muted
│                                      │
│              ┌──────────────────┐    │  Own: right-aligned
│              │ It was great!    │    │  #39FF14 bg, black text
│              │ Hit a new PR!    │    │  12dp radius
│              └──────────────────┘    │
│                          9:17 AM     │
│                                      │
│              ┌──────────────────┐    │  Pending: right, 70% opacity
│              │ Can we do legs   │    │
│              │ tomorrow?        │    │  If failed: red ! icon
│              └──────────────────┘    │
│                        Sending...    │
│                                      │
├──────────────────────────────────────┤
│  ┌─────────────────────────┐  [▶]  │  Input bar: TextField + send button
│  │ Type a message...        │       │  #111111 bg, #222222 top border
│  └─────────────────────────┘        │  Send: 48dp neon green IconButton
│  (safe area padding below)          │
└──────────────────────────────────────┘
```

### Message Bubble Styling

**Own messages (sent by current user):**
- Alignment: right (CrossAxisAlignment.end)
- Background: #39FF14 (neon green)
- Text: black, body style
- Max width: 75% of screen width
- Border radius: 12dp all corners, bottom-right 4dp (tail effect)
- Padding: 12h × 8v

**Received messages:**
- Alignment: left (CrossAxisAlignment.start)
- Background: #1A1A1A (elevated)
- Text: white, body style
- Max width: 75% of screen width
- Border radius: 12dp all corners, bottom-left 4dp (tail effect)
- Padding: 12h × 8v

**Pending messages (optimistic):**
- Same as own messages but 70% opacity
- Below bubble: "Sending..." in caption, muted

**Failed messages:**
- Same as own messages but 70% opacity
- Red circle with ! icon (20dp) at bottom-right of bubble
- Below bubble: "Failed · Tap to retry" in caption, error red
- Tap bubble → resend mutation

### Day Group Headers
- Centered text: "Today", "Yesterday", or "March 5, 2026"
- Style: caption, muted
- 24dp vertical padding above, 8dp below
- Divider lines on each side (thin, #222222)

### Timestamp
- Below each bubble, aligned to bubble side
- Style: caption, muted
- Format: "2:30 PM"
- Only show if >5 min gap from previous message by same sender

### Input Bar
- Background: #111111
- Top border: #222222, 1dp
- Padding: 8dp horizontal, 8dp vertical + safe area bottom
- TextField: #1A1A1A fill, #222222 border, 12dp radius, "Type a message..." placeholder
- Send IconButton: Icon(Icons.send_rounded), #39FF14 color, 48dp tap area
- Disabled state: send icon at 30% opacity when text is empty
- Character counter: shows "3856/4000" when over 3800 chars, caption, muted

### Scroll Behavior
- `reverse: true` on ListView.builder — newest messages at bottom without manual scrolling
- On send: auto at bottom (reverse list handles this)
- ScrollController for "scroll to bottom" FAB when user scrolls up 2+ screens

### Keyboard
- `resizeToAvoidBottomInset: true` — Scaffold handles this
- Input bar stays above keyboard naturally
- On keyboard open: list stays at bottom (reverse list handles this)

---

## Polling Design

```dart
// In ChatRoomScreen State
late final Timer _pollTimer;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _pollTimer = Timer.periodic(
    const Duration(seconds: 5),
    (_) => ref.invalidate(messagesProvider(widget.conversationId)),
  );
  // Mark messages as read on entry
  _markRead();
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) _pollTimer.cancel();
  if (state == AppLifecycleState.resumed) {
    _pollTimer = Timer.periodic(...);
    ref.invalidate(messagesProvider(widget.conversationId));
  }
}

@override
void dispose() {
  _pollTimer.cancel();
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
}
```

---

## Animation Specs

| Animation | Type | Duration | Notes |
|---|---|---|---|
| New message appear | FadeTransition 0→1 | 150ms | On own send (optimistic) |
| Pending → confirmed | Opacity 0.7→1.0 | 200ms | When poll returns real message |
| Failed → retry sending | Opacity pulse | 300ms | Subtle pulse on resend |
| Conversation list load | Staggered fade-in | 100ms per item | On initial load only |

---

## File Structure

```
lib/src/features/chat/
├── domain/entities/
│   ├── message.dart              # Message entity
│   └── conversation.dart         # Conversation entity
├── data/
│   ├── chat_repository.dart      # Abstract interface
│   └── convex_chat_repository.dart  # Convex implementation + provider
└── presentation/
    ├── providers/
    │   └── chat_provider.dart    # ChatNotifier, MessagesNotifier, pending msg state
    ├── screens/
    │   ├── chat_tab_screen.dart  # Role-aware: member→room, trainer→list
    │   ├── chat_list_screen.dart # Trainer conversation list
    │   └── chat_room_screen.dart # The actual chat room
    └── widgets/
        ├── message_bubble.dart   # Own/received/pending/failed bubble
        ├── chat_input.dart       # Input bar with send button
        ├── day_header.dart       # Day group separator
        └── conversation_tile.dart # Conversation list row (trainer)
```

Update:
- `app_router.dart` — add `/chat/:conversationId` route
- `main_scaffold.dart` — wire Chat tab
