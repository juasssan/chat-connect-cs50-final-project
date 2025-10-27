from rest.users import app
from sockets.chat import init_chat_sockets

try:
    init_chat_sockets(app)
except Exception:
    pass

@app.route("/")
def home():
    return "<h3>🧙 Flask LOTR API<br>→ /api/users<br>→ /ws/chat</h3>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
