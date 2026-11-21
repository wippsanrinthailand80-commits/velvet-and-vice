# Bodily Fluids System - tracks and displays fluids during scenes
extends Node

# Fluid types
enum FluidType { CUM, SALIVA, SWEAT, LUBRICANT }

# Active fluids in scene: list of {type, position, amount, timestamp}
var fluids: Array = []

# Character fluid states
var character_fluids: Dictionary = {}  # actor_id -> {cum: 0-100, saliva: 0-100, sweat: 0-100}

signal fluid_added(type, position, amount)
signal fluid_cleared

func _ready():
    pass

func reset():
    fluids.clear()
    character_fluids.clear()

func add_fluid(type: int, position: Vector3, amount: float = 1.0):
    fluids.append({"type": type, "pos": position, "amount": amount, "time": OS.get_ticks_msec()})
    emit_signal("fluid_added", type, position, amount)

func add_character_fluid(actor_id: String, fluid: String, amount: int):
    if not character_fluids.has(actor_id):
        character_fluids[actor_id] = {"cum": 0, "saliva": 0, "sweat": 0}
    if character_fluids[actor_id].has(fluid):
        character_fluids[actor_id][fluid] = clamp(character_fluids[actor_id][fluid] + amount, 0, 100)

func get_character_fluid(actor_id: String, fluid: String) -> int:
    if not character_fluids.has(actor_id):
        return 0
    return character_fluids[actor_id].get(fluid, 0)

func on_climax(actor_id: String, position: Vector3):
    # Heavy fluid release on climax
    add_fluid(FluidType.CUM, position, 5.0)
    add_character_fluid(actor_id, "cum", 50)
    # Sweat from exertion
    add_character_fluid(actor_id, "sweat", 20)
    var partner = _get_partner(actor_id)
    if partner != "":
        add_character_fluid(partner, "sweat", 15)

func on_oral(actor_id: String):
    add_character_fluid(actor_id, "saliva", 15)
    var partner = _get_partner(actor_id)
    if partner != "":
        add_character_fluid(partner, "saliva", 5)

func on_kiss(actor_id: String):
    add_character_fluid(actor_id, "saliva", 8)
    var partner = _get_partner(actor_id)
    if partner != "":
        add_character_fluid(partner, "saliva", 8)

func _get_partner(actor_id: String) -> String:
    for p in SexSceneManager.participants:
        if p != actor_id:
            return p
    return ""

func clear_all():
    fluids.clear()
    character_fluids.clear()
    emit_signal("fluid_cleared")