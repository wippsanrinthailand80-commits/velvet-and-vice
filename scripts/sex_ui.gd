# Sex Scene UI overlay
extends Control

@onready var pose_container = get_node_or_null("PoseButtons")
@onready var arousal_label = get_node_or_null("ArousalLabel")
@onready var end_button = get_node_or_null("EndButton")
@onready var interact_buttons = get_node_or_null("InteractButtons")

var visible_panel: bool = false

func _ready():
    SexSceneManager.connect("scene_started", Callable(self, "_on_scene_started"))
    SexSceneManager.connect("scene_ended", Callable(self, "_on_scene_ended"))
    SexSceneManager.connect("pose_changed", Callable(self, "_on_pose_changed"))
    SexSceneManager.connect("arousal_changed", Callable(self, "_on_arousal_changed"))
    if end_button:
        end_button.connect("pressed", Callable(self, "_on_end_pressed"))
    visible = false

func _on_scene_started(participants):
    visible = true
    _build_pose_buttons(participants.size())
    _build_interact_buttons()
    _update_arousal()

func _on_scene_ended():
    visible = false

func _build_pose_buttons(count: int):
    if not pose_container:
        return
    # clear
    for c in pose_container.get_children():
        c.queue_free()
    var poses = SexSceneManager.available_poses_for(count)
    for pid in poses:
        var b = Button.new()
        b.text = SexSceneManager.poses[pid]["name"]
        b.pressed.connect(Callable(self, "_on_pose_pressed").bind(pid))
        pose_container.add_child(b)

func _build_interact_buttons():
    if not interact_buttons:
        return
    for c in interact_buttons.get_children():
        c.queue_free()
    var actions = ["kiss", "touch", "oral", "penetrate", "massage", "tease", "deep", "climax"]
    for a in actions:
        var b = Button.new()
        b.text = a.capitalize()
        b.pressed.connect(Callable(self, "_on_action_pressed").bind(a))
        interact_buttons.add_child(b)

func _on_pose_pressed(pid: String):
    SexSceneManager.set_pose(pid)

func _on_action_pressed(action: String):
    # apply to first participant (player) affecting partner
    SexSceneManager.apply_interaction(action, "player", 15)
    _update_arousal()

func _on_end_pressed():
    SexSceneManager.end_scene()

func _on_pose_changed(pose_id: String):
    pass

func _on_arousal_changed(actor_id: String, value: int):
    _update_arousal()

func _update_arousal():
    if not arousal_label:
        return
    var txt = ""
    for a in SexSceneManager.arousal.keys():
        txt += a + ": " + str(SexSceneManager.arousal[a]) + "%\n"
    arousal_label.text = txt