# Character NPC
extends Node3D

@export var npc_id: String = "npc_01"
@export var display_name: String = "Character"
@export var dialogue_file: String = ""

var affinity: int = 0
var current_anim: String = "idle"
var body: StaticBody3D = null

signal dialogue_started(npc)
signal dialogue_ended

func _ready():
    add_to_group("characters")
    affinity = GameManager.get_affinity(npc_id)
    _add_collision()

func _add_collision():
    body = StaticBody3D.new()
    body.name = "Body"
    add_child(body)
    var col = CollisionShape.new()
    var shape = CapsuleShape.new()
    shape.radius = 0.3
    shape.height = 1.6
    col.shape = shape
    body.add_child(col)
    body.transform.origin = Vector3(0, 0.9, 0)

func interact(player):
    change_affinity(2)
    if DialogueSystem.start_dialogue(npc_id, self):
        emit_signal("dialogue_started", self)
    else:
        # fallback: start sex scene directly
        start_sex_scene()

func end_dialogue():
    emit_signal("dialogue_ended")
    GameManager.set_state(GameManager.GameState.PLAYING)

func change_affinity(delta: int):
    affinity = clamp(affinity + delta, 0, 100)
    GameManager.set_affinity(npc_id, affinity)

func start_sex_scene(pose: String = ""):
    SexSceneManager.start_scene(["player", npc_id])
    if pose != "":
        SexSceneManager.set_pose(pose)

func get_prompt() -> String:
    return "Talk to " + display_name