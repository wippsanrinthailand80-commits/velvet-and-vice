# Quest System (Godot 4.7)
extends Node

var quests: Dictionary = {}
var active_quests: Array = []
var completed_quests: Array = []

signal quest_started(quest_id)
signal quest_completed(quest_id)
signal quest_updated(quest_id)

func _ready():
    _load_quests()

func _load_quests():
    var dir = DirAccess.open("res://quests/")
    if dir == null:
        DirAccess.make_dir_recursive_absolute("res://quests/")
        return
    dir.list_dir_begin()
    var fn = dir.get_next()
    while fn != "":
        if fn.ends_with(".json"):
            var f = FileAccess.open("res://quests/" + fn, FileAccess.READ)
            if f:
                var json = JSON.new()
                if json.parse(f.get_as_text()) == OK:
                    var data = json.data
                    if data and data.has("id"):
                        quests[data["id"]] = data
                f.close()
        fn = dir.get_next()
    dir.list_dir_end()

func start_quest(quest_id: String):
    if not quests.has(quest_id):
        push_warning("Unknown quest: " + quest_id)
        return
    if quest_id in active_quests or quest_id in completed_quests:
        return
    active_quests.append(quest_id)
    quest_started.emit(quest_id)

func complete_objective(quest_id: String, obj_id: String):
    if not quests.has(quest_id):
        return
    var q = quests[quest_id]
    for o in q.get("objectives", []):
        if o["id"] == obj_id:
            o["done"] = true
    var all_done = true
    for o in q.get("objectives", []):
        if not o.get("done", false):
            all_done = false
            break
    if all_done:
        _complete_quest(quest_id)
    else:
        quest_updated.emit(quest_id)

func _complete_quest(quest_id: String):
    if quest_id in completed_quests:
        return
    completed_quests.append(quest_id)
    if quest_id in active_quests:
        active_quests.erase(quest_id)
    var q = quests[quest_id]
    var reward = q.get("reward", {})
    if reward.has("affinity"):
        for npc in reward["affinity"].keys():
            GameManager.add_affinity(npc, reward["affinity"][npc])
    if reward.has("item"):
        Inventory.add_item(reward["item"])
    if reward.has("flag"):
        GameManager.set_flag(reward["flag"])
    if reward.has("corruption"):
        CorruptionSystem.add(reward["corruption"])
    quest_completed.emit(quest_id)

func get_quest(quest_id: String) -> Dictionary:
    return quests.get(quest_id, {})