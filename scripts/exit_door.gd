# Exit Door - triggers ending
extends Spatial

export var label: String = "Leave Building"

var body: StaticBody = null

func _ready():
    _add_collision()

func _add_collision():
    body = StaticBody.new()
    add_child(body)
    var col = CollisionShape.new()
    var shape = BoxShape.new()
    shape.extents = Vector3(0.5, 1.0, 0.1)
    col.shape = shape
    body.add_child(col)
    body.transform.origin = Vector3(0, 1.0, 0)

func interact(player):
    EndingManager.trigger_ending()

func get_prompt() -> String:
    return label + " (End Game)"