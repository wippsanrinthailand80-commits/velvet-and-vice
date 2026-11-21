# Sex scene manager - handles sexual scenes, poses, animations
extends Node

# Current scene state
var active: bool = false
var participants: Array = []  # NPC ids / player
var current_pose: String = ""
var arousal: Dictionary = {}   # actor_id -> 0..100

# Pose definitions: pose_id -> {name, anim, participants, description}
var poses: Dictionary = {
    "missionary": {"name": "Missionary", "anim": "pose_missionary", "min_participants": 2, "desc": "Face-to-face lying"},
    "doggy": {"name": "Doggy Style", "anim": "pose_doggy", "min_participants": 2, "desc": "From behind"},
    "cowgirl": {"name": "Cowgirl", "anim": "pose_cowgirl", "min_participants": 2, "desc": "Riding on top"},
    "blowjob": {"name": "Blowjob", "anim": "pose_blowjob", "min_participants": 2, "desc": "Oral sex"},
    "sixty_nine": {"name": "69", "anim": "pose_69", "min_participants": 2, "desc": "Mutual oral"},
    "standing": {"name": "Standing", "anim": "pose_standing", "min_participants": 2, "desc": "Standing sex"},
    "kneeling": {"name": "Kneeling", "anim": "pose_kneeling", "min_participants": 1, "desc": "Kneeling pose"},
    "spread_eagle": {"name": "Spread Eagle", "anim": "pose_spread", "min_participants": 1, "desc": "Bound spread eagle"},
    "reverse_cowgirl": {"name": "Reverse Cowgirl", "anim": "pose_rev_cowgirl", "min_participants": 2, "desc": "Riding backwards"},
    "spooning": {"name": "Spooning", "anim": "pose_spooning", "min_participants": 2, "desc": "Side by side"},
    "standing_wall": {"name": "Against Wall", "anim": "pose_wall", "min_participants": 2, "desc": "Pressed against wall"},
    "table": {"name": "On Table", "anim": "pose_table", "min_participants": 2, "desc": "On a table"},
    "chair": {"name": "On Chair", "anim": "pose_chair", "min_participants": 2, "desc": "Seated on chair"},
    "kneeling_oral": {"name": "Kneeling Oral", "anim": "pose_kneel_oral", "min_participants": 2, "desc": "Kneeling for oral"},
    "mutual_masturbation": {"name": "Mutual Masturbation", "anim": "pose_mutual", "min_participants": 2, "desc": "Hand in hand"},
}

signal scene_started(participants)
signal scene_ended
signal pose_changed(pose_id)
signal arousal_changed(actor_id, value)

func start_scene(actor_ids: Array):
    active = true
    participants = actor_ids.duplicate()
    for a in actor_ids:
        arousal[a] = 0
    GameManager.set_state(GameManager.GameState.SEX_SCENE)
    emit_signal("scene_started", participants)
    print("Sex scene started with: ", participants)

func end_scene():
    active = false
    participants.clear()
    arousal.clear()
    current_pose = ""
    GameManager.set_state(GameManager.GameState.PLAYING)
    emit_signal("scene_ended")
    print("Sex scene ended")

func set_pose(pose_id: String):
    if not poses.has(pose_id):
        push_warning("Unknown pose: " + pose_id)
        return
    current_pose = pose_id
    emit_signal("pose_changed", pose_id)
    print("Pose set: " + pose_id)

func add_arousal(actor_id: String, delta: int):
    if not arousal.has(actor_id):
        arousal[actor_id] = 0
    arousal[actor_id] = clamp(arousal[actor_id] + delta, 0, 100)
    emit_signal("arousal_changed", actor_id, arousal[actor_id])

func get_arousal(actor_id: String) -> int:
    return arousal.get(actor_id, 0)

func is_climax(actor_id: String) -> bool:
    return get_arousal(actor_id) >= 100

func apply_interaction(interaction: String, actor_id: String, delta: int = 10):
    # Fluid effects
    if interaction == "kiss" or interaction == "lick":
        FluidsSystem.on_kiss(actor_id)
    elif interaction == "oral":
        FluidsSystem.on_oral(actor_id)
    # Action-specific arousal deltas
    var deltas = {
        "kiss": 8,
        "touch": 10,
        "oral": 18,
        "penetrate": 20,
        "massage": 6,
        "lick": 12,
        "squeeze": 14,
        "tease": 5,
        "deep": 25,
        "climax": 40,
    }
    var d = deltas.get(interaction, delta)
    add_arousal(actor_id, d)
    var partner = _get_partner(actor_id)
    if partner != "":
        add_arousal(partner, int(d * 0.7))

func _get_partner(actor_id: String) -> String:
    for p in participants:
        if p != actor_id:
            return p
    return ""

func available_poses_for(participant_count: int) -> Array:
    var out = []
    for pid in poses.keys():
        if poses[pid]["min_participants"] <= participant_count:
            out.append(pid)
    return out