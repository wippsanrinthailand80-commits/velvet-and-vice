# Event UI - shows random event notifications
extends Control

onready var title_label = get_node_or_null("TitleLabel")
onready var text_label = get_node_or_null("TextLabel")

var display_timer: float = 0.0
var showing: bool = false

func _ready():
    EventSystem.connect("event_triggered", self, "_on_event")
    visible = false

func _on_event(event_id, event_data):
    if title_label:
        title_label.text = event_data.get("title", "Event")
    if text_label:
        text_label.text = event_data.get("text", "")
    visible = true
    showing = true
    display_timer = 5.0

func _process(delta):
    if showing:
        display_timer -= delta
        if display_timer <= 0:
            showing = false
            visible = false