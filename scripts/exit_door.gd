# Exit Door - triggers ending
extends Node3D

@export var label: String = "Leave Building"

var body: StaticBody3D = null

func _ready():
    _add_collision()

func _add_collision():
    body = StaticBody3D.new()
    add_child(body)
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.extents = Vector3(0.5, 1.0, 0.1)
    col.shape = shape
    body.add_child(col)
    body.transform.origin = Vector3(0, 1.0, 0)

func interact(player):
    EndingManager.trigger_ending()

func get_prompt() -> String:
    return label + " (End Game)"