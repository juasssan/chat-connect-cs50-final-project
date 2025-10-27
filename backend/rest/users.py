from flask import Flask, jsonify
from data.store import get_users

app = Flask(__name__)

@app.route("/api/users", methods=["GET"])
def users_list():
    return jsonify(get_users())
