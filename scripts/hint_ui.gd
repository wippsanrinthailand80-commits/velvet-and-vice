# Hint UI
extends Control

onready var label = get_node_or_null("HintLabel")

func _ready():
    HintSystem.connect("hint_changed", self, "_on_hint")
    visible = true

func _on_hint(hint: String):
    if label:
        label.text = "💡 " + hint