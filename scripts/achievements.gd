# Achievements System
extends Node

var achievements: Dictionary = {}
var unlocked: Array = []

signal achievement_unlocked(id, title)

func _ready():
    _load_achievements()
    var t = Timer.new()
    t.wait_time = 2.0
    t.autostart = true
    t.connect("timeout", self, "_check_all")
    add_child(t)

func _check_all():
    for id in achievements.keys():
        check(id)

func _load_achievements():
    var dir = Directory.new()
    var path = "res://achievements/"
    if not dir.dir_exists(path):
        dir.make_dir_recursive(path)
        return
    dir.open(path)
    dir.list_dir_begin()
    var fn = dir.get_next()
    while fn != "":
        if fn.ends_with(".json"):
            var f = File.new()
            if f.open(path + fn, File.READ) == OK:
                var data = parse_json(f.get_as_text())
                f.close()
                if data and data.has("id"):
                    achievements[data["id"]] = data
        fn = dir.get_next()
    dir.list_dir_end()

func check(achievement_id: String) -> bool:
    if not achievements.has(achievement_id):
        return false
    if achievement_id in unlocked:
        return false
    var ach = achievements[achievement_id]
    # Check conditions
    var cond = ach.get("condition", {})
    if cond.has("corruption_min"):
        if CorruptionSystem.corruption < cond["corruption_min"]:
            return false
    if cond.has("affinity_min"):
        for npc in cond["affinity_min"].keys():
            if GameManager.get_affinity(npc) < cond["affinity_min"][npc]:
                return false
    if cond.has("flag"):
        if not GameManager.get_flag(cond["flag"]):
            return false
    if cond.has("quest"):
        if not (cond["quest"] in QuestSystem.completed_quests):
            return false
    unlock(achievement_id)
    return true

func unlock(id: String):
    if id in unlocked:
        return
    unlocked.append(id)
    if achievements.has(id):
        emit_signal("achievement_unlocked", id, achievements[id].get("title", id))

func is_unlocked(id: String) -> bool:
    return id in unlocked