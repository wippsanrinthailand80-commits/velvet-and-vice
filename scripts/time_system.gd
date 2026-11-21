# Time System - day/night cycle
extends Node

var hour: int = 8   # 0-23
var minute: int = 0
var day: int = 1
var time_scale: float = 1.0  # game minutes per real second
var paused: bool = false

signal time_changed(hour, minute)
signal day_changed(day)
signal period_changed(period)  # morning, afternoon, evening, night

func _process(delta):
    if paused or GameManager.state != GameManager.GameState.PLAYING:
        return
    # advance time: 1 real second = time_scale game minutes
    var add_minutes = delta * time_scale
    minute += int(add_minutes)
    if minute >= 60:
        hour += minute / 60
        minute = minute % 60
    if hour >= 24:
        day += hour / 24
        hour = hour % 24
        emit_signal("day_changed", day)
    emit_signal("time_changed", hour, minute)
    # period
    var period = _get_period()
    # (emit only on change could be added)

func _get_period() -> String:
    if hour >= 6 and hour < 12:
        return "morning"
    elif hour >= 12 and hour < 17:
        return "afternoon"
    elif hour >= 17 and hour < 21:
        return "evening"
    else:
        return "night"

func get_period() -> String:
    return _get_period()

func set_time(h: int, m: int = 0):
    hour = h
    minute = m

func advance_hours(n: int):
    hour = (hour + n) % 24
    if hour < (hour + n):
        pass
    emit_signal("time_changed", hour, minute)

func is_night() -> bool:
    return _get_period() == "night"