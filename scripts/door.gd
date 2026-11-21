# Door - scene transition trigger
extends Node3D

@export var target_scene: String = ""
@export var label: String = "Door"

var body: StaticBody3D = null

func _ready():
    _add_collision()

func _add_collision():
    body = StaticBody3D.new()
    add_child(body)
    var col = CollisionShape.new()
    var shape = BoxShape.new()
    shape.extents = Vector3(0.5, 1.0, 0.1)
    col.shape = shape
    body.add_child(col)
    body.transform.origin = Vector3(0, 1.0, 0)

func interact(player):
    if target_scene != "":
        AudioManager.play_door()
        GameManager.change_scene(target_scene)

func get_prompt() -> String:
    return "Enter " + label