# Mood System - tracks character mood and affects dialogue/interactions
extends Node

# Mood values: -100 (depressed) to 100 (euphoric)
var mood: Dictionary = {}  # actor_id -> mood value
var mood_labels = {
    "depressed": [-100, -60],
    "sad": [-59, -20],
    "neutral": [-19, 19],
    "happy": [20, 59],
    "euphoric": [60, 100],
}

signal mood_changed(actor_id, value, label)

func _ready():
    pass

func get_mood(actor_id: String) -> int:
    return mood.get(actor_id, 0)

func get_mood_label(actor_id: String) -> String:
    var v = get_mood(actor_id)
    for lbl in mood_labels.keys():
        var r = mood_labels[lbl]
        if v >= r[0] and v <= r[1]:
            return lbl
    return "neutral"

func add_mood(actor_id: String, delta: int):
    var old = get_mood(actor_id)
    mood[actor_id] = clamp(old + delta, -100, 100)
    var new_label = get_mood_label(actor_id)
    emit_signal("mood_changed", actor_id, mood[actor_id], new_label)

func set_mood(actor_id: String, value: int):
    mood[actor_id] = clamp(value, -100, 100)
    emit_signal("mood_changed", actor_id, mood[actor_id], get_mood_label(actor_id))

# Mood effects on arousal
func mood_arousal_modifier(actor_id: String) -> float:
    var v = get_mood(actor_id)
    # Happy characters get aroused faster
    return 1.0 + (v / 200.0)