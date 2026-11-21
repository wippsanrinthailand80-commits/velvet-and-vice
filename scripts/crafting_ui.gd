# Crafting UI
extends Control

@onready var recipe_list = get_node_or_null("RecipeList")
@onready var craft_btn = get_node_or_null("CraftButton")
@onready var status_label = get_node_or_null("StatusLabel")

var selected_recipe: int = -1

func _ready():
    visible = false
    if craft_btn:
        craft_btn.connect("pressed", Callable(self, "_on_craft_pressed"))
    _refresh()

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_C:
        visible = !visible
        if visible:
            _refresh()

func _refresh():
    if not recipe_list:
        return
    for c in recipe_list.get_children():
        c.queue_free()
    for i in range(CraftingSystem.recipes.size()):
        var recipe = CraftingSystem.recipes[i]
        var btn = Button.new()
        var can = CraftingSystem.can_craft(i)
        btn.text = recipe["name"] + (" ✓" if can else " ✗")
        btn.disabled = not can
        btn.connect("pressed", self, "_select_recipe", [i])
        recipe_list.add_child(btn)

func _select_recipe(idx: int):
    selected_recipe = idx
    if status_label:
        var recipe = CraftingSystem.recipes[idx]
        status_label.text = "Inputs: " + ", ".join(recipe["inputs"]) + " → " + recipe["output"]

func _on_craft_pressed():
    if selected_recipe >= 0:
        if CraftingSystem.craft(selected_recipe):
            if status_label:
                status_label.text = "Crafted: " + CraftingSystem.recipes[selected_recipe]["output"]
            _refresh()
        else:
            if status_label:
                status_label.text = "Cannot craft"