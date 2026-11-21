# Save/Load system
extends Node

const SAVE_PATH = "user://savegame.save"

func save_game():
    var data = {
        "relationships": GameManager.relationships,
        "flags": GameManager.flags,
        "inventory": GameManager.inventory_items,
        "player_pos": _get_player_pos(),
        "player_rot": _get_player_rot(),
        "timestamp": OS.get_datetime(),
    }
    var f = File.new()
    var err = f.open(SAVE_PATH, File.WRITE)
    if err == OK:
        f.store_string(to_json(data))
        f.close()
        print("Game saved")
        return true
    else:
        push_error("Failed to save: " + str(err))
        return false

func load_game() -> bool:
    var f = File.new()
    if not f.file_exists(SAVE_PATH):
        return false
    var err = f.open(SAVE_PATH, File.READ)
    if err != OK:
        return false
    var text = f.get_as_text()
    f.close()
    var data = parse_json(text)
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
        var p = GameManager.player.global_transform.origin
        return [p.x, p.y, p.z]
    return [0,0,0]

func _get_player_rot() -> Array:
    if GameManager.player and is_instance_valid(GameManager.player):
        var r = GameManager.player.rotation
        return [r.x, r.y, r.z]
    return [0,0,0]

func _set_player_pos(arr: Array):
    if GameManager.player and is_instance_valid(GameManager.player) and arr.size() == 3:
        GameManager.player.global_transform.origin = Vector3(arr[0], arr[1], arr[2])

func _set_player_rot(arr: Array):
    if GameManager.player and is_instance_valid(GameManager.player) and arr.size() == 3:
        GameManager.player.rotation = Vector3(arr[0], arr[1], arr[2])

func delete_save():
    var dir = Directory.new()
    if dir.file_exists(SAVE_PATH):
        dir.remove(SAVE_PATH)