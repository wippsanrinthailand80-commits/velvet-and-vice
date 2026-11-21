# Corruption System - tracks moral corruption / dark path
extends Node

var corruption: int = 0  # 0-100
var corruption_tier: String = "innocent"

signal corruption_changed(value, tier)

const TIERS = [
    {"name": "innocent", "min": 0},
    {"name": "curious", "min": 15},
    {"name": "tempted", "min": 35},
    {"name": "corrupted", "min": 60},
    {"name": "depraved", "min": 85},
]

func _ready():
    pass

func add(amount: int):
    corruption = clamp(corruption + amount, 0, 100)
    _update_tier()
    emit_signal("corruption_changed", corruption, corruption_tier)
    GameManager.set_flag("corruption_" + corruption_tier)

func set_value(v: int):
    corruption = clamp(v, 0, 100)
    _update_tier()
    emit_signal("corruption_changed", corruption, corruption_tier)

func _update_tier():
    var new_tier = "innocent"
    for t in TIERS:
        if corruption >= t["min"]:
            new_tier = t["name"]
    if new_tier != corruption_tier:
        corruption_tier = new_tier