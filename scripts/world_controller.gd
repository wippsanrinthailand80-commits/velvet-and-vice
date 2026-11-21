# World controller - handles sex scene positioning in the bedroom
extends Node3D

@onready var bed = get_node_or_null("Bed")
@onready var female = get_node_or_null("Female")
@onready var male = get_node_or_null("Male")

func _ready():
    if SexSceneManager:
        SexSceneManager.connect("scene_started", Callable(self, "_on_scene_started"))
        SexSceneManager.connect("scene_ended", Callable(self, "_on_scene_ended"))
        SexSceneManager.connect("pose_changed", Callable(self, "_on_pose_changed"))
    AudioManager.play_music_path("ambient_main")

func _on_scene_started(participants):
    AudioManager.play_music_path("ambient_intimate")
    if bed and female and male:
        var bed_pos = bed.global_transform.origin
        female.global_transform.origin = bed_pos + Vector3(-0.3, 0, 0)
        male.global_transform.origin = bed_pos + Vector3(0.3, 0, 0)

func _on_scene_ended():
    AudioManager.play_music_path("ambient_main")

func _on_pose_changed(pose_id: String):
    if not (female and male and bed):
        return
    var bed_pos = bed.global_transform.origin
    match pose_id:
        "missionary":
            female.global_transform.origin = bed_pos + Vector3(0, 0.5, 0)
            male.global_transform.origin = bed_pos + Vector3(0, 0.5, 0.6)
        "doggy":
            female.global_transform.origin = bed_pos + Vector3(0, 0.5, 0)
            male.global_transform.origin = bed_pos + Vector3(0, 0.5, -0.6)
        "cowgirl":
            female.global_transform.origin = bed_pos + Vector3(0, 0.8, 0)
            male.global_transform.origin = bed_pos + Vector3(0, 0.5, 0)
        _:
            female.global_transform.origin = bed_pos + Vector3(-0.3, 0, 0)
            male.global_transform.origin = bed_pos + Vector3(0.3, 0, 0)