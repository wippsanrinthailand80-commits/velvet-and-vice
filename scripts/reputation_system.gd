# Reputation System - tracks player reputation in the building
extends Node

var reputation: int = 0  # -100 to 100
var reputation_tier: String = "stranger"

signal reputation_changed(value, tier)

const TIERS = [
    {"name": "outcast", "min": -100},
    {"name": "stranger", "min": -20},
    {"name": "acquaintance", "min": 10},
    {"name": "friend", "min": 30},
    {"name": "popular", "min": 50},
    {"name": "legend", "min": 80},
]

func _ready():
    pass

func add(amount: int):
    reputation = clamp(reputation + amount, -100, 100)
    _update_tier()
    emit_signal("reputation_changed", reputation, reputation_tier)

func _update_tier():
    var new_tier = "stranger"
    for t in TIERS:
        if reputation >= t["min"]:
            new_tier = t["name"]
    if new_tier != reputation_tier:
        reputation_tier = new_tier

func get_tier() -> String:
    return reputation_tier