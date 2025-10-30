🧩 Project Overview
====================

ChatConnect is a full-stack messaging demo built as a monorepo, containing:
- An iOS app using SwiftUI
- A Flask-based backend server

The app mimics a real-time chat platform, where users can select a character from a list and exchange messages. The backend simulates message exchanges, creating the illusion of live conversations.


🧑🏻‍💻 Chat Backend Overview
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

🧑🏻‍💻 iOS App ChatConnect Overview
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