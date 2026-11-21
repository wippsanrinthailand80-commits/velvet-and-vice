# Prop - interactable pickup/usable prop
extends Spatial

export var prop_id: String = ""
export var pickupable: bool = true
export var usable: bool = true

var held: bool = false
var body: StaticBody = null

func _ready():
    add_to_group("props")
    _add_collision()

func _add_collision():
    body = StaticBody.new()
    body.name = "Body"
    add_child(body)
    var col = CollisionShape.new()
    var shape = SphereShape.new()
    shape.radius = 0.15
    col.shape = shape
    body.add_child(col)
    # move body to center height
    body.transform.origin = Vector3(0, 0.15, 0)

func interact(player):
    if pickupable:
        AudioManager.play_pickup()
        if Inventory:
            Inventory.add_item(prop_id)
        if GameManager:
            GameManager.add_item(prop_id)
        print("Picked up: ", prop_id)
        queue_free()
    elif usable:
        use(player)

func use(player):
    print("Used prop: ", prop_id)

func get_prompt() -> String:
    if pickupable:
        return "Pick up " + prop_id
    return "Use " + prop_id