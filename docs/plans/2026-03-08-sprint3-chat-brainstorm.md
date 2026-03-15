# Sprint 3 — Real-Time Chat: Brainstorm

## "Real-Time" Strategy

convex_flutter returns Futures, not streams. Use polling:
- Chat room open: poll every 5 seconds
- Chat list open (trainer): poll every 15 seconds
- App backgrounded: stop polling (WidgetsBindingObserver)
- Pull-to-refresh as manual fallback

## Member vs Trainer Flow

**Member:**
1. Tap Chat tab → fetch `getMyConversation`
2. Conversation exists → direct to chat room (skip list)
3. No conversation → "Start chatting with your trainer" button → `startConversation` → chat room
4. No trainer assigned → empty state

**Trainer:**
1. Tap Chat tab → conversation list (`getMyConversations`)
2. Each row: member avatar, name, last message preview (50 chars), relative timestamp
3. Tap row → chat room

## Chat Room Design

- Reversed `ListView.builder` — newest at bottom
- Day group headers: "Today", "Yesterday", "March 5, 2026"
- Own messages: right, neon green bg, black text
- Received: left, #1A1A1A bg, white text
- Bubble: 12dp radius, max 75% width, 12h+8v padding
- Timestamp below each bubble: "2:30 PM", caption, muted

## Input Bar

- Fixed bottom, #111111 bg, #222222 top border
- TextField + send IconButton (neon green, enabled when non-empty)
- No attachments for v1
- Max 4000 chars, show counter at 3800+
- Send: lightImpact haptic

## Optimistic Send

1. Tap send → message appears at 0.7 opacity in bubble
2. Mutation succeeds → opacity 1.0, next poll brings real message
3. Mutation fails → red error icon + "Tap to retry" on bubble
4. Pending messages tracked in provider state

## Mark Read

- Call `messages:markRead` when entering a chat room
- Don't show read receipts in UI for v1

## Polling Implementation

```dart
Timer.periodic(Duration(seconds: 5), (_) {
  if (mounted) ref.invalidate(messagesProvider(conversationId));
});
```
- Dispose timer in dispose()
- Pause when app backgrounded (WidgetsBindingObserver.didChangeAppLifecycleState)

## Haptics

| Action | Haptic |
|---|---|
| Send message | lightImpact |
| Tap retry on failed message | selectionClick |
| Pull-to-refresh trigger | selectionClick |

## Empty States

| State | Display |
|---|---|
| Loading conversations (trainer) | 3 skeleton list tiles |
| Loading messages | Centered spinner |
| No conversations (trainer) | "No conversations yet." |
| No trainer (member) | Person-off icon + "No trainer assigned yet." |
| Empty conversation | "Say hello! Send your first message." |
| Send failed | Red icon on bubble + "Tap to retry" |
| Network error | "Couldn't load messages." + pull-to-refresh |

## YAGNI — Not Building

- No typing indicators
- No read receipt UI (blue checkmarks)
- No image/photo messages (defer to Sprint 6)
- No message editing/deletion
- No search within messages
- No unread badge on Chat tab
- No sound effects
- No message pagination (collect all for now — cap at reasonable limit)

## Backend Endpoints Used

- `mobile:getMyConversation` — member's single conversation
- `mobile:getMyConversations` — trainer's conversation list
- `mobile:startConversation` — member creates conversation
- `mobile:sendMessage` — send message (content + optional storageId)
- `messages:listByConversation` — all messages in conversation (oldest first)
- `messages:markRead` — mark other party's messages as read
