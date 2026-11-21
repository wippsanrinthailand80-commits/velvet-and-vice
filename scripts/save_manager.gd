# Save/Load extended - auto-save and multiple slots
extends Node

const MAX_SLOTS = 3
const AUTO_SAVE_INTERVAL = 300.0  # 5 minutes

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
        "player_pos": [GameManager.player.global_transform.origin.x, GameManager.player.global_transform.origin.y, GameManager.player.global_transform.origin.z],
        "player_rot": [GameManager.player.rotation.x, GameManager.player.rotation.y, GameManager.player.rotation.z],
        "corruption": CorruptionSystem.corruption,
        "reputation": ReputationSystem.reputation,
        "quests_completed": QuestSystem.completed_quests,
        "achievements": Achievements.unlocked,
        "timestamp": OS.get_datetime(),
        "slot": slot,
    }
    var f = File.new()
    var path = "user://save_slot_%d.save" % slot
    var err = f.open(path, File.WRITE)
    if err == OK:
        f.store_string(to_json(data))
        f.close()
        return true
    return false

func load_slot(slot: int) -> bool:
    if slot < 0 or slot >= MAX_SLOTS:
        return false
    var path = "user://save_slot_%d.save" % slot
    var f = File.new()
    if not f.file_exists(path):
        return false
    var err = f.open(path, File.READ)
    if err != OK:
        return false
    var data = parse_json(f.get_as_text())
    f.close()
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
    var f = File.new()
    if not f.file_exists(path):
        return {"empty": true}
    var err = f.open(path, File.READ)
    if err != OK:
        return {"empty": true}
    var data = parse_json(f.get_as_text())
    f.close()
    if data == null:
        return {"empty": true}
    return {
        "empty": false,
        "day": data.get("timestamp", {}).get("day", 0),
        "corruption": data.get("corruption", 0),
        "slot": slot,
    }