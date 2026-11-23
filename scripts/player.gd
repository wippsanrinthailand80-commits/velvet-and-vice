# Player controller - CharacterBody3D (Godot 4.7)
extends CharacterBody3D

@export var move_speed: float = 5.0
@export var jump_force: float = 6.0
@export var gravity: float = 9.8

var camera_pivot: Node3D = null
var camera: Camera3D = null

# Interaction
var interact_target: Node = null
var interact_range: float = 2.0

# State
var is_in_sex_scene: bool = false
var footstep_timer: float = 0.0
var touch_move: Vector2 = Vector2.ZERO

func _ready():
    GameManager.player = self
    camera_pivot = get_node_or_null("CameraPivot")
    camera = get_node_or_null("CameraPivot/Camera")
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        if camera_pivot:
            camera_pivot.rotate_y(-event.relative.x * GameManager.mouse_sensitivity)
            var cam = camera_pivot.get_node_or_null("Camera")
            if cam:
                cam.rotate_x(-event.relative.y * GameManager.mouse_sensitivity)
                cam.rotation.x = clamp(cam.rotation.x, -1.2, 1.2)
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
                Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
            else:
                Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        elif event.keycode == KEY_F5:
            SaveSystem.save_game()
        elif event.keycode == KEY_F9:
            SaveSystem.load_game()

func _physics_process(delta):
    if GameManager.state != GameManager.GameState.PLAYING:
        return
    # Gravity
    if not is_on_floor():
        velocity.y -= gravity * delta
    # Movement input (keyboard + touch)
    var input_vec = Vector3.ZERO
    if Input.is_action_pressed("move_forward"):
        input_vec -= transform.basis.z
    if Input.is_action_pressed("move_back"):
        input_vec += transform.basis.z
    if Input.is_action_pressed("move_left"):
        input_vec -= transform.basis.x
    if Input.is_action_pressed("move_right"):
        input_vec += transform.basis.x
    # Touch input
    if touch_move.length() > 0.1:
        input_vec -= transform.basis.z * touch_move.y
        input_vec += transform.basis.x * touch_move.x
    input_vec = input_vec.normalized()
    velocity.x = input_vec.x * move_speed
    velocity.z = input_vec.z * move_speed
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_force
    move_and_slide()
    # Footsteps
    if is_on_floor() and Vector2(velocity.x, velocity.z).length() > 0.5:
        footstep_timer -= delta
        if footstep_timer <= 0:
            AudioManager.play_footstep()
            footstep_timer = 0.4
    else:
        footstep_timer = 0.0
    # Interact
    _check_interact()
    if Input.is_action_just_pressed("interact"):
        _do_interact()

func _check_interact():
    if camera == null:
        return
    var space = get_world_3d().direct_space_state
    var from = camera.global_position
    var to = from - camera.global_transform.basis.z * interact_range
    var params = PhysicsRayQueryParameters3D.create(from, to)
    params.exclude = [self]
    var result = space.intersect_ray(params)
    if result and result.has("collider"):
        interact_target = _find_interactable(result["collider"])
    else:
        interact_target = null

func _find_interactable(node: Node) -> Node:
    var cur = node
    while cur != null:
        if cur.has_method("interact") and cur.has_method("get_prompt"):
            return cur
        cur = cur.get_parent()
    return null

func _do_interact():
    if interact_target and interact_target.has_method("interact"):
        interact_target.interact(self)

func set_touch_move(vec: Vector2):
    touch_move = vec

func touch_jump():
    if is_on_floor():
        velocity.y = jump_force

func touch_interact():
    _do_interact()

func get_interact_prompt() -> String:
    if interact_target and interact_target.has_method("get_prompt"):
        return interact_target.get_prompt()
    return ""