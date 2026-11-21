# Player controller - KinematicBody (Godot 3.6)
extends KinematicBody

export var move_speed: float = 5.0
export var jump_force: float = 6.0
export var gravity: float = 9.8

var velocity: Vector3 = Vector3.ZERO
var footstep_timer: float = 0.0
var camera_pivot: Spatial = null
var camera: Camera = null

# Interaction
var interact_target: Node = null
var interact_range: float = 2.0

# State
var is_in_sex_scene: bool = false

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
    if event is InputEventKey and event.pressed and event.scancode == KEY_F5:
        SaveSystem.save_game()
    if event is InputEventKey and event.pressed and event.scancode == KEY_F9:
        SaveSystem.load_game()
    if event is InputEventKey and event.pressed and event.scancode == KEY_ESCAPE:
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
    if GameManager.state != GameManager.GameState.PLAYING:
        return
    # Gravity
    if not is_on_floor():
        velocity.y -= gravity * delta
    # Movement input
    var input_vec = Vector3.ZERO
    if Input.is_action_pressed("move_forward"):
        input_vec -= transform.basis.z
    if Input.is_action_pressed("move_back"):
        input_vec += transform.basis.z
    if Input.is_action_pressed("move_left"):
        input_vec -= transform.basis.x
    if Input.is_action_pressed("move_right"):
        input_vec += transform.basis.x
    input_vec = input_vec.normalized()
    velocity.x = input_vec.x * move_speed
    velocity.z = input_vec.z * move_speed
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_force
    velocity = move_and_slide(velocity, Vector3.UP)
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
    var space = get_world().direct_space_state
    var from = camera.global_transform.origin
    var to = from - camera.global_transform.basis.z * interact_range
    var result = space.intersect_ray(from, to, [self])
    if result and result.collider:
        interact_target = _find_interactable(result.collider)
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

func get_interact_prompt() -> String:
    if interact_target and interact_target.has_method("get_prompt"):
        return interact_target.get_prompt()
    return ""