# Event System - random events (Godot 4.7)
extends Node

var events: Array = []
var event_timer: float = 0.0

signal event_triggered(event_id, event_data)

func _ready():
    _load_events()

func _load_events():
    var dir = DirAccess.open("res://events/")
    if dir == null:
        DirAccess.make_dir_recursive_absolute("res://events/")
        _create_default_events()
        return
    dir.list_dir_begin()
    var fn = dir.get_next()
    while fn != "":
        if fn.ends_with(".json"):
            var f = FileAccess.open("res://events/" + fn, FileAccess.READ)
            if f:
                var json = JSON.new()
                if json.parse(f.get_as_text()) == OK:
                    events.append(json.data)
                f.close()
        fn = dir.get_next()
    dir.list_dir_end()
    if events.is_empty():
        _create_default_events()

func _create_default_events():
    DirAccess.make_dir_recursive_absolute("res://events/")
    var default_events = [
        {"id": "power_outage", "title": "Power Outage", "text": "The lights flicker and go out. Someone is moving in the dark...", "condition": {"period": "night", "corruption_min": 0}, "effect": {"mood_all": -5}},
        {"id": "love_letter", "title": "Love Letter", "text": "You find a love letter slipped under your door. No signature.", "condition": {"period": "morning", "corruption_min": 0}, "effect": {"item": "perfume"}},
        {"id": "strange_noise", "title": "Strange Noise", "text": "A strange noise comes from the basement. The Pleasure Club?", "condition": {"period": "night", "corruption_min": 20}, "effect": {"corruption": 2}},
        {"id": "gift_delivery", "title": "Gift Delivery", "text": "A package arrives at your door. Inside: a silk scarf and a note saying 'For later.'", "condition": {"period": "afternoon", "corruption_min": 10}, "effect": {"item": "silk"}},
        {"id": "midnight_visitor", "title": "Midnight Visitor", "text": "Someone knocks on your door at midnight. When you open it, no one is there. But there's a rose on the floor.", "condition": {"period": "night", "corruption_min": 30}, "effect": {"item": "candle"}},
    ]
    for e in default_events:
        var f = FileAccess.open("res://events/" + e["id"] + ".json", FileAccess.WRITE)
        if f:
            f.store_string(JSON.stringify(e))
            f.close()
        events.append(e)

func _process(delta):
    if GameManager.state != GameManager.GameState.PLAYING:
        return
    event_timer += delta
    if event_timer >= 300.0:
        event_timer = 0.0
        _try_trigger_event()

func _try_trigger_event():
    if events.is_empty():
        return
    var period = TimeSystem.get_period()
    var available = []
    for e in events:
        var cond = e.get("condition", {})
        if cond.has("period") and cond["period"] != period:
            continue
        if cond.has("corruption_min") and CorruptionSystem.corruption < cond["corruption_min"]:
            continue
        available.append(e)
    if available.is_empty():
        return
    var event = available[randi() % available.size()]
    _trigger_event(event)

func _trigger_event(event: Dictionary):
    event_triggered.emit(event["id"], event)
    var effect = event.get("effect", {})
    if effect.has("item"):
        Inventory.add_item(effect["item"])
    if effect.has("corruption"):
        CorruptionSystem.add(effect["corruption"])
    if effect.has("mood_all"):
        for npc in ["maya", "riko", "kenji", "aoi", "yuki", "sister", "mother"]:
            MoodSystem.add_mood(npc, effect["mood_all"])
    JournalSystem.add_entry(event["title"], event["text"], "Story")