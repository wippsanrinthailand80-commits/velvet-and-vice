# Save/Load system (Godot 4.7)
extends Node

const SAVE_PATH = "user://savegame.save"

func save_game():
    var data = {
        "relationships": GameManager.relationships,
        "flags": GameManager.flags,
        "inventory": GameManager.inventory_items,
        "player_pos": _get_player_pos(),
        "player_rot": _get_player_rot(),
        "timestamp": Time.get_datetime_dict_from_system(),
    }
    var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))
        f.close()
        print("Game saved")
        return true
    else:
        push_error("Failed to save")
        return false

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not f:
        return false
    var text = f.get_as_text()
    f.close()
    var json = JSON.new()
    var err = json.parse(text)
    if err != OK:
        return false
    var data = json.data
    if data == null:
        return false
    GameManager.relationships = data.get("relationships", {})
    GameManager.flags = data.get("flags", {})
    GameManager.inventory_items = data.get("inventory", [])
    _set_player_pos(data.get("player_pos", [0,0,0]))
    _set_player_rot(data.get("player_rot", [0,0,0]))
    print("Game loaded")
    return true

func _get_player_pos() -> Array:
    if GameManager.player and is_instance_valid(GameManager.player):
        var p = GameManager.player.global_position
        return [p.x, p.y, p.z]
    return [0,0,0]

func _get_player_rot() -> Array:
    if GameManager.player and is_instance_valid(GameManager.player):
        var r = GameManager.player.rotation
        return [r.x, r.y, r.z]
    return [0,0,0]

func _set_player_pos(arr):
    if GameManager.player and is_instance_valid(GameManager.player) and arr.size() == 3:
        GameManager.player.global_position = Vector3(arr[0], arr[1], arr[2])

func _set_player_rot(arr):
    if GameManager.player and is_instance_valid(GameManager.player) and arr.size() == 3:
        GameManager.player.rotation = Vector3(arr[0], arr[1], arr[2])

func delete_save():
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(SAVE_PATH)