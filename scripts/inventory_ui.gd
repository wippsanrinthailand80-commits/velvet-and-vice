# Inventory UI
extends Control

@onready var list_label = get_node_or_null("ListLabel")

func _ready():
    Inventory.connect("inventory_changed", Callable(self, "_refresh"))
    visible = false
    _refresh()

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_I:
        visible = !visible
        if visible:
            _refresh()

func _refresh():
    if not list_label:
        return
    var counts = {}
    for it in Inventory.items:
        counts[it] = counts.get(it, 0) + 1
    var txt = "Inventory:\n"
    for k in counts.keys():
        txt += k + " x" + str(counts[k]) + "\n"
    if counts.is_empty():
        txt += "(empty)"
    list_label.text = txt