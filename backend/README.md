Chat Backend

Overview

- REST API with two endpoints:
  - `GET /users` → list of users with `id`, `name`, `isOnline`, `status`.
  - `POST /messages` → accepts JSON `{ "from": user_id, "to": user_id, "message": "..." }`.
- In-memory data only (mocked values), no database.
