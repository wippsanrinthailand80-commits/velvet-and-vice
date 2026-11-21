# GameManager - global game state singleton
extends Node

# Game states
enum GameState { MENU, PLAYING, DIALOGUE, SEX_SCENE, PAUSED, INVENTORY }
var state: int = GameState.MENU

# Player reference
var player: Node = null
var current_scene_root: Node = null

# Relationship / stats
var relationships: Dictionary = {}  # npc_id -> affinity (0-100)
var flags: Dictionary = {}          # story flags
var inventory_items: Array = []

# Settings
var mouse_sensitivity: float = 0.003
var master_volume: float = 1.0

signal state_changed(new_state)
signal item_added(item_id)
signal relationship_changed(npc_id, value)

func _ready():
    print("GameManager ready")

func set_state(s: int):
    state = s
    emit_signal("state_changed", s)

func is_playing() -> bool:
    return state == GameState.PLAYING

func add_item(item_id: String, count: int = 1):
    for i in range(count):
        inventory_items.append(item_id)
    emit_signal("item_added", item_id)

func has_item(item_id: String) -> bool:
    return item_id in inventory_items

func remove_item(item_id: String) -> bool:
    var idx = inventory_items.find(item_id)
    if idx >= 0:
        inventory_items.remove_at(idx)
        return true
    return false

func get_affinity(npc_id: String) -> int:
    return relationships.get(npc_id, 0)

func set_affinity(npc_id: String, value: int):
    relationships[npc_id] = clamp(value, 0, 100)
    emit_signal("relationship_changed", npc_id, relationships[npc_id])

func add_affinity(npc_id: String, delta: int):
    set_affinity(npc_id, get_affinity(npc_id) + delta)

func set_flag(flag: String, value: bool = true):
    flags[flag] = value

func get_flag(flag: String) -> bool:
    return flags.get(flag, false)

func change_scene(path: String):
    # Defer scene change
    call_deferred("_do_change_scene", path)

func _do_change_scene(path: String):
    var new_scene = load(path).instance()
    get_tree().current_scene.queue_free()
    get_tree().root.add_child(new_scene)
    get_tree().current_scene = new_scene
    current_scene_root = new_scene

func pause_game():
    get_tree().paused = true
    set_state(GameState.PAUSED)

func resume_game():
    get_tree().paused = false
    set_state(GameState.PLAYING)