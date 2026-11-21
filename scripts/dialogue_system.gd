# Dialogue System - JSON-based branching dialogue (Godot 4.7)
extends Node

var dialogues: Dictionary = {}
var current_dialogue: Dictionary = {}
var current_node: String = ""
var current_npc: Node = null

signal dialogue_started(npc_id)
signal dialogue_node_changed(node_id, text, choices)
signal dialogue_ended

func _ready():
    _load_all_dialogues()

func _load_all_dialogues():
    var dir = DirAccess.open("res://dialogues/")
    if dir == null:
        DirAccess.make_dir_recursive_absolute("res://dialogues/")
        return
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".json"):
            var f = FileAccess.open("res://dialogues/" + file_name, FileAccess.READ)
            if f:
                var text = f.get_as_text()
                f.close()
                var json = JSON.new()
                if json.parse(text) == OK:
                    var data = json.data
                    if data and data.has("npc_id"):
                        dialogues[data["npc_id"]] = data
        file_name = dir.get_next()
    dir.list_dir_end()
    print("Loaded dialogues: ", dialogues.keys())

func start_dialogue(npc_id: String, npc_node: Node = null):
    if not dialogues.has(npc_id):
        push_warning("No dialogue for: " + npc_id)
        return false
    current_dialogue = dialogues[npc_id]
    current_node = "start"
    current_npc = npc_node
    GameManager.set_state(GameManager.GameState.DIALOGUE)
    dialogue_started.emit(npc_id)
    _show_node()
    return true

func _show_node():
    if not current_dialogue.has("nodes"):
        return
    var node = current_dialogue["nodes"].get(current_node, {})
    var text = node.get("text", "...")
    var choices = node.get("choices", [])
    var filtered = []
    for c in choices:
        if _choice_available(c):
            filtered.append(c)
    if filtered.is_empty() and node.has("next"):
        current_node = node["next"]
        _show_node()
        return
    dialogue_node_changed.emit(current_node, text, filtered)

func _choice_available(choice: Dictionary) -> bool:
    if choice.has("req_affinity"):
        if GameManager.get_affinity(current_dialogue["npc_id"]) < choice["req_affinity"]:
            return false
    if choice.has("req_flag"):
        if not GameManager.get_flag(choice["req_flag"]):
            return false
    if choice.has("req_item"):
        if not Inventory.has_item(choice["req_item"]):
            return false
    if choice.has("req_corruption"):
        if CorruptionSystem.corruption < choice["req_corruption"]:
            return false
    return true

func choose(choice_index: int):
    var node = current_dialogue["nodes"].get(current_node, {})
    var choices = node.get("choices", [])
    var filtered = []
    for c in choices:
        if _choice_available(c):
            filtered.append(c)
    if choice_index < 0 or choice_index >= filtered.size():
        return
    var choice = filtered[choice_index]
    if choice.has("affinity"):
        GameManager.add_affinity(current_dialogue["npc_id"], choice["affinity"])
    if choice.has("flag"):
        GameManager.set_flag(choice["flag"])
    if choice.has("item"):
        if str(choice["item"]).begins_with("-"):
            Inventory.remove_item(str(choice["item"]).substr(1))
        else:
            Inventory.add_item(str(choice["item"]))
    if choice.has("corruption"):
        CorruptionSystem.add(choice["corruption"])
    if choice.has("sex_scene"):
        var npc_id = current_dialogue["npc_id"]
        end_dialogue()
        SexSceneManager.start_scene(["player", npc_id])
        if choice.has("pose"):
            SexSceneManager.set_pose(choice["pose"])
        return
    if choice.has("quest"):
        QuestSystem.start_quest(choice["quest"])
    if choice.has("next"):
        current_node = choice["next"]
        _show_node()
    else:
        end_dialogue()

func end_dialogue():
    current_dialogue = {}
    current_node = ""
    current_npc = null
    GameManager.set_state(GameManager.GameState.PLAYING)
    dialogue_ended.emit()