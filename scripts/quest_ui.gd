# Quest UI tracker
extends Control

@onready var label = get_node_or_null("QuestLabel")

func _ready():
    QuestSystem.connect("quest_started", Callable(self, "_refresh"))
    QuestSystem.connect("quest_completed", Callable(self, "_refresh"))
    QuestSystem.connect("quest_updated", Callable(self, "_refresh"))
    visible = true
    _refresh()

func _refresh(_id = null):
    if not label:
        return
    var txt = "Quests:\n"
    for qid in QuestSystem.active_quests:
        var q = QuestSystem.get_quest(qid)
        txt += "- " + q.get("title", qid) + "\n"
        for o in q.get("objectives", []):
            var mark = "[x]" if o.get("done", false) else "[ ]"
            txt += "   " + mark + " " + o.get("text", "") + "\n"
    if QuestSystem.active_quests.is_empty():
        txt += "(none)"
    label.text = txt