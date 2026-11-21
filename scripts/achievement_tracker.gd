# Achievement Tracker - expanded achievements for quality content
extends Node

# Additional achievements to register (these are loaded from files)
# This script provides runtime achievement checking

func check_all_achievements():
    for id in Achievements.achievements.keys():
        Achievements.check(id)

# Check on various game events
func on_sex_scene_complete():
    Achievements.check("first_intimate")
    if SexSceneManager.get_arousal("player") >= 100:
        Achievements.unlock("climax_master")

func on_quest_complete(quest_id: String):
    Achievements.check("completionist")
    if quest_id == "trial_surrender":
        Achievements.check("club_member")

func on_corruption_changed():
    Achievements.check("corrupted_50")
    Achievements.check("depraved")

func on_affinity_changed(npc_id: String, value: int):
    if npc_id == "sister" and value >= 20:
        Achievements.check("family_ties")
    if npc_id == "mother" and value >= 20:
        Achievements.check("family_ties")