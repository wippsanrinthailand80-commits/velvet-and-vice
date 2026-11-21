# Inventory system
extends Node

# item_id -> {name, description, icon, type, effect}
var item_db: Dictionary = {
    "dildo": {"name": "Dildo", "desc": "Realistic silicone dildo", "type": "toy", "effect": "arousal+20"},
    "vibrator": {"name": "Vibrator Wand", "desc": "Powerful wand vibrator", "type": "toy", "effect": "arousal+30"},
    "handcuffs": {"name": "Handcuffs", "desc": "Metal handcuffs", "type": "restraint", "effect": "restraint"},
    "blindfold": {"name": "Blindfold", "desc": "Silk blindfold", "type": "restraint", "effect": "blind"},
    "rope": {"name": "Rope", "desc": "Bondage rope", "type": "restraint", "effect": "restraint"},
    "lube": {"name": "Lubricant", "desc": "Water-based lube bottle", "type": "consumable", "effect": "comfort+10"},
    "condom": {"name": "Condom", "desc": "Protection", "type": "consumable", "effect": "safe"},
    "key": {"name": "Key", "desc": "A small key", "type": "key", "effect": ""},
    "cookie": {"name": "Cookie", "desc": "Homemade cookie", "type": "food", "effect": "health+5"},
    "tea": {"name": "Tea", "desc": "Warm tea", "type": "food", "effect": "comfort+5"},
    "wine": {"name": "Wine", "desc": "Red wine bottle", "type": "drink", "effect": "arousal+5"},
    "perfume": {"name": "Perfume", "desc": "Seductive fragrance", "type": "accessory", "effect": "affinity+3"},
    "candle": {"name": "Candle", "desc": "Scented candle", "type": "decor", "effect": "mood+5"},
    "silk": {"name": "Silk Scarf", "desc": "Soft silk scarf", "type": "accessory", "effect": "comfort+5"},
    "collar": {"name": "Collar", "desc": "Leather collar", "type": "restraint", "effect": "submissive"},
    "whip": {"name": "Whip", "desc": "Leather whip", "type": "toy", "effect": "arousal+15"},
    "massage_oil": {"name": "Massage Oil", "desc": "Scented massage oil", "type": "consumable", "effect": "comfort+10"},
    "safe_kit": {"name": "Safe Kit", "desc": "Protection essentials", "type": "kit", "effect": "safe"},
    "romantic_kit": {"name": "Romantic Kit", "desc": "Candlelight and perfume", "type": "kit", "effect": "affinity+10"},
    "bondage_kit": {"name": "Bondage Kit", "desc": "Rope and cuffs", "type": "kit", "effect": "corruption+5"},
    "sensual_kit": {"name": "Sensual Kit", "desc": "Oil and silk", "type": "kit", "effect": "comfort+20"},
    "date_kit": {"name": "Date Kit", "desc": "Wine and cookies", "type": "kit", "effect": "affinity+15"},
    "toy_kit": {"name": "Toy Kit", "desc": "Dildo and lubricant", "type": "kit", "effect": "arousal+25"},
}

var items: Array = []  # array of item_id strings

signal inventory_changed

func add_item(item_id: String, count: int = 1):
    if not item_db.has(item_id):
        push_warning("Unknown item: " + item_id)
        return
    for i in range(count):
        items.append(item_id)
    emit_signal("inventory_changed")

func remove_item(item_id: String) -> bool:
    var idx = items.find(item_id)
    if idx >= 0:
        items.remove_at(idx)
        emit_signal("inventory_changed")
        return true
    return false

func has_item(item_id: String) -> bool:
    return item_id in items

func count_item(item_id: String) -> int:
    var c = 0
    for it in items:
        if it == item_id:
            c += 1
    return c

func get_item_info(item_id: String) -> Dictionary:
    return item_db.get(item_id, {})