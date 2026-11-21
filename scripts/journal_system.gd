# Journal System - tracks discoveries, notes, and story progress
extends Node

var entries: Array = []  # {title, text, category, timestamp}
var categories = ["Story", "Character", "Location", "Item", "Secret"]

signal entry_added(title, category)

func _ready():
    pass

func add_entry(title: String, text: String, category: String = "Story"):
    # Avoid duplicates
    for e in entries:
        if e["title"] == title:
            return
    entries.append({
        "title": title,
        "text": text,
        "category": category,
        "timestamp": Time.get_datetime_dict_from_system()
    })
    emit_signal("entry_added", title, category)

func get_entries(category: String = "") -> Array:
    if category == "":
        return entries
    var out = []
    for e in entries:
        if e["category"] == category:
            out.append(e)
    return out

func has_entry(title: String) -> bool:
    for e in entries:
        if e["title"] == title:
            return true
    return false