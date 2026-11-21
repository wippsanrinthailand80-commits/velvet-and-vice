# HUD - in-game overlay
extends Control

onready var interact_prompt = get_node_or_null("InteractPrompt")
onready var crosshair = get_node_or_null("Crosshair")
onready var status_label = get_node_or_null("StatusLabel")

var player: Node = null

func _ready():
    player = GameManager.player

func _process(delta):
    if player and is_instance_valid(player):
        var prompt = ""
        if player.has_method("get_interact_prompt"):
            prompt = player.get_interact_prompt()
        if interact_prompt:
            interact_prompt.text = prompt
            interact_prompt.visible = prompt != ""

func show_status(text: String, duration: float = 2.0):
    if status_label:
        status_label.text = text
        status_label.visible = true
        yield(get_tree().create_timer(duration), "timeout")
        status_label.visible = false