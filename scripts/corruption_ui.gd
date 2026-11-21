# Corruption UI display
extends Control

onready var label = get_node_or_null("CorruptionLabel")

func _ready():
    CorruptionSystem.connect("corruption_changed", self, "_refresh")
    _refresh(CorruptionSystem.corruption, CorruptionSystem.corruption_tier)

func _refresh(value, tier):
    if label:
        label.text = "Corruption: %d%% (%s)" % [value, tier]