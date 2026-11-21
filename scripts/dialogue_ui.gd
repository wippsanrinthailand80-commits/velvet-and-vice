# Dialogue UI
extends Control

onready var text_label = get_node_or_null("TextLabel")
onready var choices_container = get_node_or_null("Choices")

func _ready():
    DialogueSystem.connect("dialogue_started", self, "_on_started")
    DialogueSystem.connect("dialogue_node_changed", self, "_on_node_changed")
    DialogueSystem.connect("dialogue_ended", self, "_on_ended")
    visible = false

func _on_started(npc_id):
    visible = true

func _on_ended():
    visible = false
    if text_label:
        text_label.text = ""
    if choices_container:
        for c in choices_container.get_children():
            c.queue_free()

func _on_node_changed(node_id, text, choices):
    if text_label:
        text_label.text = text
    if choices_container:
        for c in choices_container.get_children():
            c.queue_free()
        for i in range(choices.size()):
            var b = Button.new()
            b.text = choices[i].get("text", "...")
            b.connect("pressed", self, "_on_choice", [i])
            choices_container.add_child(b)

func _on_choice(idx: int):
    DialogueSystem.choose(idx)