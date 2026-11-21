# Achievements UI
extends Control

onready var label = get_node_or_null("AchLabel")

func _ready():
    Achievements.connect("achievement_unlocked", self, "_on_unlocked")
    _refresh()

func _on_unlocked(id, title):
    if label:
        label.text = "★ " + title + " ★"
        # flash
        yield(get_tree().create_timer(3.0), "timeout")
        _refresh()

func _refresh():
    if not label:
        return
    var count = Achievements.unlocked.size()
    var total = Achievements.achievements.size()
    label.text = "Achievements: %d/%d" % [count, total]