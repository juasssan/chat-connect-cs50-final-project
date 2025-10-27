from flask import Flask, jsonify
import random

app = Flask(__name__)

# --- Lord of the Rings characters ---
lotr_names = [
    "Frodo Baggins", "Samwise Gamgee", "Gandalf", "Aragorn", "Legolas",
    "Gimli", "Boromir", "Galadriel", "Elrond", "Saruman",
    "Gollum", "Éowyn", "Faramir", "Bilbo Baggins", "Sauron"
]

# --- Character statuses ---
statuses = {
    "Frodo Baggins": "lost again",
    "Samwise Gamgee": "boiling potatoes",
    "Gandalf": "sending fireworks",
    "Aragorn": "on the road",
    "Legolas": "counting arrows",
    "Gimli": "needs more ale",
    "Boromir": "arguing with Frodo",
    "Galadriel": "swimming",
    "Elrond": "another long meeting",
    "Saruman": "open to help",
    "Gollum": "precious time",
    "Éowyn": "cooking soup",
    "Orc": "what orcs does",
    "Bilbo Baggins": "missing the Shire",
    "Sauron": "just watching"
}


@app.route("/api/users", methods=["GET"])
def users_list():
    users = []
    # Mocking 5 first always be online
    for i, name in enumerate(lotr_names[:3], start=1):
        users.append({
            "id": i,
            "name": name,
            "isOnline": True,
            "status": statuses.get(name)
        })

    # Mocking 5 to have 20% of chance to be online
    for i, name in enumerate(lotr_names[3:10], start=6):
        is_online = random.randint(1, 10) <= 2  # 20% chance
        users.append({
            "id": i,
            "name": name,
            "isOnline": is_online,
            "status": statuses.get(name)
        })

    # Mocking last 5 to be offline
    for i, name in enumerate(lotr_names[10:], start=11):
        users.append({
            "id": i,
            "name": name,
            "isOnline": False,
            "status": statuses.get(name)
        })

    return jsonify(users)

@app.route("/")
def home():
    return "<h3>🧙 Flask LOTR API<br>→ /api/users<br>→ /api/messages</h3>"

if __name__ == "__main__":
    app.run(port=5001, debug=True)