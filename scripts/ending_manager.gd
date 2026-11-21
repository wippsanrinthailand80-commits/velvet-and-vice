# Ending Manager - determines and shows ending based on state
extends Node

var endings = {
    "innocent": {
        "title": "The Innocent Path",
        "text": "You resisted the darkness. The building remains a mystery to you. You move out, carrying only memories of what could have been. Some doors, once closed, stay closed forever.",
        "corruption_range": [0, 14]
    },
    "curious": {
        "title": "The Curious Path",
        "text": "You dipped your toes into the depths but never dove in. You leave with a taste of forbidden fruit, wondering 'what if' for the rest of your life.",
        "corruption_range": [15, 34]
    },
    "tempted": {
        "title": "The Tempted Path",
        "text": "You walked the line between light and dark. Some relationships blossomed; others withered. You leave the building changed — not fully corrupted, but no longer innocent.",
        "corruption_range": [35, 59]
    },
    "corrupted": {
        "title": "The Corrupted Path",
        "text": "The darkness embraced you. You became a regular at the Pleasure Club. The residents know you by name. You've lost something, but gained something else. Was it worth it?",
        "corruption_range": [60, 84]
    },
    "depraved": {
        "title": "The Depraved Path",
        "text": "You descended fully into the abyss. Nothing is forbidden anymore. The building is your kingdom of desire. But in the quiet moments, you wonder if there's anything left of who you used to be.",
        "corruption_range": [85, 100]
    }
}

func get_ending() -> Dictionary:
    var c = CorruptionSystem.corruption
    for key in endings.keys():
        var r = endings[key]["corruption_range"]
        if c >= r[0] and c <= r[1]:
            return endings[key]
    return endings["innocent"]

func trigger_ending():
    var ending = get_ending()
    GameManager.set_state(GameManager.GameState.PAUSED)
    # Show ending UI
    var scene = load("res://scenes/ending.tscn")
    if scene:
        var inst = scene.instance()
        get_tree().root.add_child(inst)
        if inst.has_method("show_ending"):
            inst.show_ending(ending)