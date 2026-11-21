# Save/Load extended - auto-save and multiple slots (Godot 4.7)
extends Node

const MAX_SLOTS = 3
const AUTO_SAVE_INTERVAL = 300.0

var auto_save_timer: float = 0.0

func _process(delta):
    if GameManager.state != GameManager.GameState.PLAYING:
        return
    auto_save_timer += delta
    if auto_save_timer >= AUTO_SAVE_INTERVAL:
        auto_save_timer = 0.0
        _auto_save()

func _auto_save():
    SaveSystem.save_game()
    print("Auto-saved")

func save_slot(slot: int) -> bool:
    if slot < 0 or slot >= MAX_SLOTS:
        return false
    var data = {
        "relationships": GameManager.relationships,
        "flags": GameManager.flags,
        "inventory": GameManager.inventory_items,
        "player_pos": [GameManager.player.global_position.x, GameManager.player.global_position.y, GameManager.player.global_position.z],
        "player_rot": [GameManager.player.rotation.x, GameManager.player.rotation.y, GameManager.player.rotation.z],
        "corruption": CorruptionSystem.corruption,
        "reputation": ReputationSystem.reputation,
        "quests_completed": QuestSystem.completed_quests,
        "achievements": Achievements.unlocked,
        "timestamp": Time.get_datetime_dict_from_system(),
        "slot": slot,
    }
    var f = FileAccess.open("user://save_slot_%d.save" % slot, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))
        f.close()
        return true
    return false

func load_slot(slot: int) -> bool:
    if slot < 0 or slot >= MAX_SLOTS:
        return false
    var path = "user://save_slot_%d.save" % slot
    if not FileAccess.file_exists(path):
        return false
    var f = FileAccess.open(path, FileAccess.READ)
    if not f:
        return false
    var json = JSON.new()
    var err = json.parse(f.get_as_text())
    f.close()
    if err != OK:
        return false
    var data = json.data
    if data == null:
        return false
    GameManager.relationships = data.get("relationships", {})
    GameManager.flags = data.get("flags", {})
    GameManager.inventory_items = data.get("inventory", [])
    CorruptionSystem.corruption = data.get("corruption", 0)
    ReputationSystem.reputation = data.get("reputation", 0)
    QuestSystem.completed_quests = data.get("completed_quests", [])
    Achievements.unlocked = data.get("achievements", [])
    return true

func get_slot_info(slot: int) -> Dictionary:
    var path = "user://save_slot_%d.save" % slot
    if not FileAccess.file_exists(path):
        return {"empty": true}
    var f = FileAccess.open(path, FileAccess.READ)
    if not f:
        return {"empty": true}
    var json = JSON.new()
    var err = json.parse(f.get_as_text())
    f.close()
    if err != OK:
        return {"empty": true}
    var data = json.data
    if data == null:
        return {"empty": true}
    return {
        "empty": false,
        "corruption": data.get("corruption", 0),
        "slot": slot,
    }