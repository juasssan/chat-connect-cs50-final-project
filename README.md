Chat Backend
============

Overview
--------

- REST API with one endpoint:  
  - `GET /api/users` → list of users with `id`, `name`, `isOnline`, `status`.
- WebSocket endpoint `GET /ws/chat?userId=<uid>&withId=<uid>` for live chat exchanges.
- In-memory data only (mocked values), no database.

Running the server
------------------

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

Endpoints
---------
- `GET http://127.0.0.1:5001/api/users`
- `GET ws://127.0.0.1:5001/ws/chat?userId=<uid>&withId=<uid>`
