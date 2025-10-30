🧩 Project Overview
====================
#### Video Demo:  
[![](https://markdown-videos-api.jorgenkh.no/youtube/LyEoXzJGtZI)](https://www.youtube.com/watch?v=LyEoXzJGtZI)

ChatConnect is a full-stack messaging built as a monorepo, containing:
- An iOS app using SwiftUI
- A Flask-based backend server

The app mimics a real-time chat platform, where users can select a character from a list and exchange messages. The backend simulates message exchanges, creating the illusion of live conversations.

Description Detailed
=====================

ChatConnect combines a SwiftUI MVVM client with a Flask backend, and the repository keeps the code paths separated so swapping one layer does not disturb the others. `Source/ChatConnectApp.swift` remains intentionally small: the `@main` entry point loads `ChatListView` inside a `WindowGroup`, pushing all navigation and data coordination into the feature folders.

`Features/ChatList/ChatListView.swift` renders the roster with a `NavigationStack` and a scoped `NavigationPath`, allowing each selection to push a detail screen without embedding networking logic. The layout observes the view model and presents a progress indicator, an error message, or the populated list as needed. Row presentation is delegated to `ChatItemView`, which keeps navigation state and visual styling separate.

`Features/ChatItem/ChatItemView.swift` manages the appearance of individual rows. It uses `ChatUser.initials` to draw a monogram avatar, keeps heights consistent for predictable scrolling, and colours the status text according to the online flag. The component reads the environment `colorScheme`, so light and dark themes render correctly without additional overrides.

`Features/ChatList/ChatListViewModel.swift` provides the backing state for the roster. Marked with `@Observable`, it publishes the current user identifier, the fetched `ChatUser` array, a loading flag, and any error text. The initializer accepts any `ChatUsersService`, defaulting to `RemoteChatUsersService.live`. `fetchUsers()` clears previous errors, awaits the service, and translates failures into `FetchError.reason` so the interface can show consistent copy.

`Features/Chat/ChatViewModel.swift` manages the lifecycle of a conversation. It retains peer metadata, the `messages` array, the input draft, and guards that prevent duplicate socket connections. `start()` acquires an `AsyncThrowingStream` from the injected `ChatSocketService` and launches a listener task. History events replace the transcript, message events append to it, and errors surface as short descriptions. `sendDraft()` trims whitespace, clears the field to reflect the optimistic send, and restores the original text only if the service throws.

`Features/Chat/ChatView.swift` maps that state onto the chat screen. A header presents the peer name, status, and a back control. The message list sits inside a `ScrollViewReader` so the latest entry stays visible, and the composer disables its send button whenever the sanitized draft is empty. Bubble colours are sourced from `AppSystemDesign`, keeping theming centralized. Lifecycle hooks call `start()` inside `.task` and `stop()` on disappearance, aligning the socket lifetime with navigation.

`Models/ChatUser.swift` describes each participant as `Codable`, `Identifiable`, and `Hashable`, and provides a guarded `initials` property for avatar rendering. `Models/ChatMessage.swift` stores normalized chat data with a stable identifier supplied by the creator. `Models/ChatSocketEnvelope.swift` mirrors the JSON structure emitted by the server, distinguishes between history and single-message payloads, parses ISO-8601 timestamps, and throws `ChatSocketServiceError.decodingFailed` when required fields are absent.

`Services/Protocols` records the abstraction boundaries used throughout the app. `ChatUsersService` exposes a single asynchronous fetch method. `ChatSocketService` defines the contract for connecting, sending text, and disconnecting, and is complemented by `ChatWebSocketClient`, which wraps `URLSessionWebSocketTask`. Error types in `Services/Errors` express network and decoding issues in domain terms so view models can present clear status messages. Implementations sit alongside these contracts: `RemoteChatUsersService` constructs the `http://127.0.0.1:5001/api/users` endpoint with `URLComponents`, validates 2xx responses, and decodes the payload into models, mapping other cases to the appropriate `FetchError`. `WebSocketChatService` creates a `URLSessionWebSocketTask`, automatically selects `ws` or `wss`, and keeps the active client so `send` and `disconnect` act on the same connection.

The streaming pipeline relies on Swift concurrency. `WebSocketChatService.connect` returns an `AsyncThrowingStream` whose continuation cancels the socket when the consumer stops listening. An internal receive task awaits frames, normalizes text or binary payloads into `Data`, and passes them through `ChatSocketEnvelope`. Graceful closures finish the stream, while unrecoverable errors surface as `ChatSocketServiceError`. `URLSessionChatWebSocketClient` wraps the system socket APIs so tests can substitute deterministic clients.

The Flask backend honours the same contracts. `backend/app.py` wires the REST and WebSocket components together. `backend/rest/users.py` pulls presence data from `data.store.get_users()` and returns JSON records with `id`, `name`, `status`, and `isOnline`. `backend/sockets/chat.py` expects `userId` and `withId`, tracks active sockets per user, seeds new pairs with two starter messages, echoes outgoing text, and when the peer is online, emits an automated reply flagged with `auto`. Payloads follow the `type: history|message` structure with either `items` or `item`, matching `ChatSocketEnvelope`.

Mock content and presence rules live in `backend/data/store.py`. The module defines a catalogue of characters, divides them into always-online, random, and always-off buckets, and resamples the random group so roughly twenty percent appear online on each request. Manual overrides let the socket handler mark users online while a WebSocket session is active. A rotating lorem list supplies automated replies and keeps demos consistent.

`ChatConnectUnitTests` shows how the protocol seams make the project testable. `Mocks/MockURLProtocol` intercepts HTTP requests so `ChatUserServiceTests` can assert both decoding success and failure modes. `Mocks/MockChatWebSocketClient` scripts socket frames for `ChatSocketServiceTests`, exercising history delivery, message forwarding, send behaviour, and error propagation. `Mocks/MockChatSocketService` supplies `ChatViewModel` with controlled streams, letting the tests verify start-up, draft handling, and orderly disconnects without opening real sockets. Together these suites confirm that the view layer depends only on the published contracts, which keeps future backend changes or offline features manageable.


🧑🏻‍💻 Chat Backend Bird's Eye
========================

- REST API with one endpoint:  
  - `GET /api/users` → list of users with `id`, `name`, `isOnline`, `status`.
- WebSocket endpoint `GET /ws/chat?userId=<uid>&withId=<uid>` for live chat exchanges.
- In-memory data only (mocked values), no database.
- When a user sends a message, the backend immediately replies on behalf of the recipient (if online).

⚙️ Running the server
---------------------

1. Create/activate a Python environment:
   ```bash
   python3 -m venv .venv && source .venv/bin/activate 
   ```
2. Install dependencies (requires internet access):
   ```bash
   pip install -r backend/requirements.txt
   ```
3. Start the app with a WebSocket-capable server (Flask-sock):
   ```bash
   python backend/app.py
   ```

🧑🏻‍💻 iOS App ChatConnect Bird's Eye
===============================

#### 📲 iOS App (SwiftUI)

- Two screens: 
   - Home: A list of users (“friends”).
   - Chat: Real-time messaging UI with light/dark mode support.
- WebSocket-based messaging, real-time updates using a persistent socket connection.
- Protocol-based architecture services for easy testability.
- Uses @Observation for reactive UI with clean state handling.

#### ✅ Extra Touches

- First-time chat auto-seeding: Preloaded messages make sure chat doesn’t appear empty.
- Resilient messaging:
- Reconnection handling, graceful socket closures, and input restoration on send failures.
- Smooth scrolling: Manual ScrollViewReader keeps the latest messages visible.
- Extensive testing:
- Unit and socket tests simulate real traffic and error cases using custom mocks and helpers.

🛠️ Known Limitations & Future Improvements
------------------------------------------

- 🔼 Show online users first in the user list.
- 🧠 Better error UI/UX, with friendly retry buttons on network or socket failures.
- 🧪 Consider adding message persistence or a basic message database.
- 💡 Add support for sending media or reactions in chat.