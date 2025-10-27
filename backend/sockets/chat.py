import json
from datetime import datetime, timezone
from typing import Dict, List, Tuple, Set, Any
from flask import request
from flask_sock import Sock
from data.store import (
    is_online_by_id as store_is_online,
    set_online_by_id as store_set_online,
    get_user_by_id,
    next_lorem,
)

def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()

def _pair(a: int, b: int) -> Tuple[int, int]:
    return (a, b) if a <= b else (b, a)

_connections: Dict[int, Set[Any]] = {}
_history: Dict[Tuple[int, int], List[Dict[str, Any]]] = {}

def init_chat_sockets(app) -> None:
    sock = Sock(app)

    @sock.route("/ws/chat")
    def ws_chat(ws):
        me_id = int(request.args.get("userId", "0"))
        peer_id = int(request.args.get("withId", "0"))
        if me_id <= 0 or peer_id <= 0:
            return

        _connections.setdefault(me_id, set()).add(ws)
        store_set_online(me_id, True)

        key = _pair(me_id, peer_id)
        if key not in _history:
            me_user = get_user_by_id(me_id) or {"name": str(me_id)}
            peer_user = get_user_by_id(peer_id) or {"name": str(peer_id)}
            _history[key] = [
                {"from": peer_user["name"], "to": me_user["name"], "message": "Hi there!", "timestamp": _now_iso()},
                {"from": me_user["name"], "to": peer_user["name"], "message": "Hello!", "timestamp": _now_iso()},
            ]

        ws.send(json.dumps({"type": "history", "items": _history[key]}))

        while True:
            incoming = ws.receive()
            if incoming is None:
                bucket = _connections.get(me_id, set())
                if ws in bucket:
                    bucket.discard(ws)
                if not bucket:
                    store_set_online(me_id, False)
                break

            text = str(incoming)
            me_user = get_user_by_id(me_id) or {"name": str(me_id)}
            peer_user = get_user_by_id(peer_id) or {"name": str(peer_id)}
            out = {"from": me_user["name"], "to": peer_user["name"], "message": text, "timestamp": _now_iso()}
            _history[key].append(out)
            ws.send(json.dumps({"type": "message", "item": out}))

            if store_is_online(peer_id):
                auto = {"from": peer_user["name"], "to": me_user["name"], "message": next_lorem(), "timestamp": _now_iso(), "auto": True}
                _history[key].append(auto)
                ws.send(json.dumps({"type": "message", "item": auto}))
                for pws in list(_connections.get(peer_id, set())):
                    pws.send(json.dumps({"type": "message", "item": auto}))
