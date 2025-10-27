import random
from typing import Dict, List, Optional, Set


# Mocked user catalog

_characters: List[Dict[str, Dict[str, Optional[str]]]] = [
    {"character": {"name": "Frodo Baggins", "statuses": "lost again"}},
    {"character": {"name": "Samwise Gamgee", "statuses": "boiling potatoes"}},
    {"character": {"name": "Gandalf", "statuses": "sending fireworks"}},
    {"character": {"name": "Aragorn", "statuses": "on the road"}},
    {"character": {"name": "Legolas", "statuses": "counting arrows"}},
    {"character": {"name": "Gimli", "statuses": "needs more ale"}},
    {"character": {"name": "Boromir", "statuses": "arguing with Frodo"}},
    {"character": {"name": "Galadriel", "statuses": "swimming"}},
    {"character": {"name": "Elrond", "statuses": "writing elvish letters"}},
    {"character": {"name": "Saruman", "statuses": "open to help"}},
    {"character": {"name": "Gollum", "statuses": "precious time"}},
    {"character": {"name": "Eowyn", "statuses": "cooking soup"}},
    {"character": {"name": "Faramir", "statuses": None}},
    {"character": {"name": "Bilbo Baggins", "statuses": "missing the Shire"}},
    {"character": {"name": "Sauron", "statuses": "just watching"}},
]

_users: List[Dict] = [
    {
        "id": idx,
        "name": entry["character"]["name"],
        "status": entry["character"]["statuses"],
    }
    for idx, entry in enumerate(_characters, start=1)
]


# Presence bookkeeping

_always_online_ids: Set[int] = {1, 2, 3}
_random_bucket_ids: Set[int] = {4, 5, 6, 7, 8, 9, 10}
_always_offline_ids: Set[int] = {11, 12, 13, 14, 15}

_random_online_ids: Set[int] = set()
_manual_online_ids: Set[int] = set()


def _resample_random() -> None:
    """Regenerate the random bucket with a 20% chance per user."""
    global _random_online_ids
    _random_online_ids = {
        uid for uid in _random_bucket_ids if random.random() < 0.2
    }


def _effective_online(uid: int) -> bool:
    if uid in _manual_online_ids:
        return True
    if uid in _always_online_ids:
        return True
    if uid in _always_offline_ids:
        return False
    return uid in _random_online_ids


def get_users() -> List[dict]:
    """Return the mocked user list with fresh randomized presence."""
    _resample_random()
    return [
        {
            "id": user["id"],
            "name": user["name"],
            "status": user.get("status"),
            "isOnline": _effective_online(user["id"]),
        }
        for user in _users
    ]


def get_user_by_id(user_id: int) -> Optional[dict]:
    uid = int(user_id)
    if 1 <= uid <= len(_users):
        user = _users[uid - 1]
        return {
            "id": user["id"],
            "name": user["name"],
            "status": user.get("status"),
            "isOnline": _effective_online(user["id"]),
        }
    return None


def set_online_by_id(user_id: int, online: bool = True) -> None:
    uid = int(user_id)
    if online:
        _manual_online_ids.add(uid)
    else:
        _manual_online_ids.discard(uid)


def is_online_by_id(user_id: int) -> bool:
    uid = int(user_id)
    return _effective_online(uid)


# Mocked chat snippets

_LOREM: List[str] = [
    "Lorem ipsum dolor sit amet.",
    "Consectetur adipiscing elit.",
    "Sed do eiusmod tempor incididunt.",
    "Ut labore et dolore magna aliqua.",
    "Duis aute irure dolor in reprehenderit.",
    "Excepteur sint occaecat cupidatat non proident.",
]
_lorem_idx: int = 0


def next_lorem() -> str:
    """Return the next lorem message from the mocked set (cycled)."""
    global _lorem_idx
    if not _LOREM:
        return ""
    message = _LOREM[_lorem_idx % len(_LOREM)]
    _lorem_idx += 1
    return message


_resample_random()
