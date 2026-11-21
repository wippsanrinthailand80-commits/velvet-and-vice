# Hint System - contextual hints for the player
extends Node

var hints: Array = []
var current_hint: String = ""
var hint_timer: float = 0.0
var hint_cooldown: float = 60.0

signal hint_changed(hint)

func _ready():
    _load_hints()

func _load_hints():
    hints = [
        "Talk to Maya first — she's the friendliest resident.",
        "Press E to interact with objects and characters.",
        "Press I to open your inventory.",
        "Press J to open your journal.",
        "Press TAB to open settings.",
        "F5 to save, F9 to load.",
        "Build affinity with characters to unlock new dialogue.",
        "Corruption opens darker content. Choose wisely.",
        "The Pleasure Club is in the basement. Ask Riko.",
        "Kenji teaches bondage and trust. Visit him.",
        "Family members live in the Family Home. Take the hallway door.",
        "Aoi holds the key to the club. Complete her trials.",
        "Random events happen every 5 minutes. Watch for notifications.",
        "Check your journal for story progress.",
        "Different corruption levels lead to different endings.",
    ]

func _process(delta):
    if GameManager.state != GameManager.GameState.PLAYING:
        return
    hint_timer += delta
    if hint_timer >= hint_cooldown:
        hint_timer = 0.0
        _show_random_hint()

func _show_random_hint():
    if hints.empty():
        return
    var h = hints[randi() % hints.size()]
    current_hint = h
    emit_signal("hint_changed", h)

func get_current_hint() -> String:
    return current_hint