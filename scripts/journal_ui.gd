# Journal UI
extends Control

@onready var title_label = get_node_or_null("TitleLabel")
@onready var text_label = get_node_or_null("TextLabel")
@onready var list_container = get_node_or_null("EntryList")

var current_index: int = 0

func _ready():
    JournalSystem.connect("entry_added", Callable(self, "_refresh"))
    visible = false
    _refresh()

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_J:
        visible = !visible
        if visible:
            _refresh()

func _refresh(_t = null, _c = null):
    if not list_container:
        return
    for c in list_container.get_children():
        c.queue_free()
    var entries = JournalSystem.get_entries()
    for i in range(entries.size()):
        var b = Button.new()
        b.text = entries[i]["title"]
        b.connect("pressed", self, "_show_entry", [i])
        list_container.add_child(b)
    if entries.size() > 0 and current_index < entries.size():
        _show_entry(current_index)

func _show_entry(idx: int):
    current_index = idx
    var entries = JournalSystem.get_entries()
    if idx >= 0 and idx < entries.size():
        if title_label:
            title_label.text = entries[idx]["title"]
        if text_label:
            text_label.text = entries[idx]["text"]