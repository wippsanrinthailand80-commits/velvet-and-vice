# Ending UI
extends Control

@onready var title_label = get_node_or_null("VBox/Title")
@onready var text_label = get_node_or_null("VBox/Text")
@onready var restart_btn = get_node_or_null("VBox/RestartButton")

func _ready():
    if restart_btn:
        restart_btn.connect("pressed", Callable(self, "_on_restart"))

func show_ending(ending: Dictionary):
    if title_label:
        title_label.text = ending.get("title", "Ending")
    if text_label:
        text_label.text = ending.get("text", "")
    visible = true

func _on_restart():
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")