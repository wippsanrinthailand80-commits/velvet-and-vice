# Time UI display
extends Control

onready var label = get_node_or_null("TimeLabel")

func _ready():
    TimeSystem.connect("time_changed", self, "_refresh")
    _refresh(TimeSystem.hour, TimeSystem.minute)

func _refresh(h, m):
    if label:
        label.text = "%02d:%02d  Day %d" % [h, m, TimeSystem.day]