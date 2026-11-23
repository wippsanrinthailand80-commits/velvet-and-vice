# Wave Optics Lab - displays Raxter's wave optics simulation
extends Node3D

@onready var renderer = $WaveOpticsRenderer
@onready var display = $Display

func _ready():
    if renderer:
        renderer.resolution = Vector2i(256, 256)
    if display and renderer:
        var tex = renderer.get_texture()
        if tex:
            display.texture = tex

func _process(delta):
    if display and renderer:
        var tex = renderer.get_texture()
        if tex:
            display.texture = tex