# Touch Controls - virtual joystick and buttons for mobile/Android
extends Control

@export var joystick_radius: float = 80.0
@export var knob_radius: float = 30.0
@export var deadzone: float = 0.2

var joystick_center: Vector2 = Vector2.ZERO
var knob_position: Vector2 = Vector2.ZERO
var joystick_active: bool = false
var joystick_touch_index: int = -1

var look_touch_index: int = -1
var last_look_pos: Vector2 = Vector2.ZERO

var move_vector: Vector2 = Vector2.ZERO

signal move_input(vec: Vector2)
signal look_input(delta: Vector2)
signal jump_pressed
signal interact_pressed
signal inventory_pressed

func _ready():
    joystick_center = Vector2(joystick_radius + 20, size.y - joystick_radius - 20)
    knob_position = joystick_center
    _create_ui()
    # Connect to player
    call_deferred("_connect_to_player")

func _connect_to_player():
    var player = get_node_or_null("/root/Main/Player")
    if player:
        move_input.connect(func(vec): player.set_touch_move(vec))
        jump_pressed.connect(func(): player.touch_jump())
        interact_pressed.connect(func(): player.touch_interact())
        look_input.connect(func(delta): _apply_look(delta))

func _apply_look(delta: Vector2):
    var player = get_node_or_null("/root/Main/Player")
    if player and player.has_node("CameraPivot"):
        var pivot = player.get_node("CameraPivot")
        pivot.rotate_y(-delta.x * 0.005)
        var cam = pivot.get_node_or_null("Camera")
        if cam:
            cam.rotate_x(-delta.y * 0.005)
            cam.rotation.x = clamp(cam.rotation.x, -1.2, 1.2)

func _create_ui():
    # Joystick base
    var base = ColorRect.new()
    base.color = Color(1, 1, 1, 0.2)
    base.size = Vector2(joystick_radius * 2, joystick_radius * 2)
    base.position = joystick_center - Vector2(joystick_radius, joystick_radius)
    base.name = "JoystickBase"
    add_child(base)
    
    # Joystick knob
    var knob = ColorRect.new()
    knob.color = Color(1, 1, 1, 0.5)
    knob.size = Vector2(knob_radius * 2, knob_radius * 2)
    knob.position = joystick_center - Vector2(knob_radius, knob_radius)
    knob.name = "JoystickKnob"
    add_child(knob)
    
    # Jump button
    var jump_btn = Button.new()
    jump_btn.text = "JUMP"
    jump_btn.size = Vector2(80, 80)
    jump_btn.position = Vector2(size.x - 100, size.y - 100)
    jump_btn.pressed.connect(func(): jump_pressed.emit())
    add_child(jump_btn)
    
    # Interact button
    var interact_btn = Button.new()
    interact_btn.text = "E"
    interact_btn.size = Vector2(60, 60)
    interact_btn.position = Vector2(size.x - 100, size.y - 180)
    interact_btn.pressed.connect(func(): interact_pressed.emit())
    add_child(interact_btn)
    
    # Inventory button
    var inv_btn = Button.new()
    inv_btn.text = "I"
    inv_btn.size = Vector2(60, 60)
    inv_btn.position = Vector2(size.x - 180, size.y - 100)
    inv_btn.pressed.connect(func(): inventory_pressed.emit())
    add_child(inv_btn)

func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            # Left side = joystick
            if event.position.x < size.x / 2:
                if joystick_touch_index == -1:
                    joystick_touch_index = event.index
                    joystick_center = event.position
                    knob_position = joystick_center
                    joystick_active = true
            else:
                # Right side = look
                if look_touch_index == -1:
                    look_touch_index = event.index
                    last_look_pos = event.position
        else:
            if event.index == joystick_touch_index:
                joystick_touch_index = -1
                joystick_active = false
                knob_position = joystick_center
                move_vector = Vector2.ZERO
                move_input.emit(move_vector)
            if event.index == look_touch_index:
                look_touch_index = -1
    
    elif event is InputEventScreenDrag:
        if event.index == joystick_touch_index and joystick_active:
            var delta = event.position - joystick_center
            var dist = delta.length()
            if dist > joystick_radius:
                delta = delta.normalized() * joystick_radius
            knob_position = joystick_center + delta
            
            # Update knob visual
            var knob = get_node_or_null("JoystickKnob")
            if knob:
                knob.position = knob_position - Vector2(knob_radius, knob_radius)
            
            # Calculate move vector
            var normalized = delta / joystick_radius
            if normalized.length() < deadzone:
                move_vector = Vector2.ZERO
            else:
                move_vector = normalized
            move_input.emit(move_vector)
        
        elif event.index == look_touch_index:
            var delta = event.position - last_look_pos
            last_look_pos = event.position
            look_input.emit(delta)

func get_move_vector() -> Vector2:
    return move_vector