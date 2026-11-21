# NPC Schedule System - characters move around based on time of day
extends Node

# schedule: npc_id -> {period: room_scene}
var schedules: Dictionary = {
    "maya": {
        "morning": "bedroom",
        "afternoon": "bedroom",
        "evening": "hallway",
        "night": "bedroom",
    },
    "riko": {
        "morning": "apartment_riko",
        "afternoon": "office_aoi",
        "evening": "apartment_riko",
        "night": "apartment_riko",
    },
    "kenji": {
        "morning": "bedroom",
        "afternoon": "bedroom",
        "evening": "bedroom",
        "night": "bedroom",
    },
    "aoi": {
        "morning": "office_aoi",
        "afternoon": "office_aoi",
        "evening": "office_aoi",
        "night": "office_aoi",
    },
    "yuki": {
        "morning": "study_yuki",
        "afternoon": "study_yuki",
        "evening": "study_yuki",
        "night": "study_yuki",
    },
    "sister": {
        "morning": "family_home",
        "afternoon": "family_home",
        "evening": "family_home",
        "night": "family_home",
    },
    "mother": {
        "morning": "family_home",
        "afternoon": "family_home",
        "evening": "family_home",
        "night": "family_home",
    },
}

func get_location(npc_id: String) -> String:
    var sched = schedules.get(npc_id, {})
    var period = TimeSystem.get_period()
    return sched.get(period, "bedroom")

func is_available(npc_id: String, current_scene: String) -> bool:
    return get_location(npc_id) == current_scene