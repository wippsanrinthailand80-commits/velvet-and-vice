# Settings Menu
extends Control

@onready var volume_slider = get_node_or_null("VBox/VolumeSlider")
@onready var sensitivity_slider = get_node_or_null("VBox/SensitivitySlider")
@onready var close_btn = get_node_or_null("VBox/CloseButton")

func _ready():
    if volume_slider:
        volume_slider.value = GameManager.master_volume * 100
        volume_slider.connect("value_changed", Callable(self, "_on_volume_changed"))
    if sensitivity_slider:
        sensitivity_slider.value = GameManager.mouse_sensitivity * 1000
        sensitivity_slider.connect("value_changed", Callable(self, "_on_sensitivity_changed"))
    if close_btn:
        close_btn.connect("pressed", Callable(self, "_on_close"))

func _on_volume_changed(val):
    GameManager.master_volume = val / 100.0
    AudioServer.set_bus_volume_db(0, linear_to_db(GameManager.master_volume))

func _on_sensitivity_changed(val):
    GameManager.mouse_sensitivity = val / 1000.0

func _on_close():
    visible = false

func _input(event):
    if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
        visible = !visible