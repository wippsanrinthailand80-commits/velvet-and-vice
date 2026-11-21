# Crafting System - combine items to create new ones
extends Node

# recipe: {inputs: [item_ids], output: item_id, name: str}
var recipes: Array = [
    {"inputs": ["lube", "condom"], "output": "safe_kit", "name": "Safe Kit"},
    {"inputs": ["candle", "perfume"], "output": "romantic_kit", "name": "Romantic Kit"},
    {"inputs": ["rope", "handcuffs"], "output": "bondage_kit", "name": "Bondage Kit"},
    {"inputs": ["massage_oil", "silk"], "output": "sensual_kit", "name": "Sensual Kit"},
    {"inputs": ["wine", "cookie"], "output": "date_kit", "name": "Date Kit"},
    {"inputs": ["dildo", "lube"], "output": "toy_kit", "name": "Toy Kit"},
]

signal crafted(output_id)

func _ready():
    pass

func can_craft(recipe_index: int) -> bool:
    if recipe_index < 0 or recipe_index >= recipes.size():
        return false
    var recipe = recipes[recipe_index]
    for inp in recipe["inputs"]:
        if not Inventory.has_item(inp):
            return false
    return true

func craft(recipe_index: int) -> bool:
    if not can_craft(recipe_index):
        return false
    var recipe = recipes[recipe_index]
    for inp in recipe["inputs"]:
        Inventory.remove_item(inp)
    Inventory.add_item(recipe["output"])
    emit_signal("crafted", recipe["output"])
    return true

func get_available_recipes() -> Array:
    var out = []
    for i in range(recipes.size()):
        if can_craft(i):
            out.append(i)
    return out