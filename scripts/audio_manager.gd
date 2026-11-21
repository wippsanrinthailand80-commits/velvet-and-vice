# AudioManager - procedural audio (Godot 4.7)
extends Node

var music_player: AudioStreamPlayer = null
var sfx_players: Array = []
const MAX_SFX = 8

var _click_stream: AudioStreamWAV = null
var _pickup_stream: AudioStreamWAV = null
var _door_stream: AudioStreamWAV = null
var _footstep_stream: AudioStreamWAV = null
var _ambient_main_stream: AudioStreamWAV = null
var _ambient_intimate_stream: AudioStreamWAV = null

var current_music: String = ""
var music_playing: bool = false

func _ready():
    music_player = AudioStreamPlayer.new()
    add_child(music_player)
    for i in range(MAX_SFX):
        var p = AudioStreamPlayer.new()
        add_child(p)
        sfx_players.append(p)
    _generate_all()

func _generate_all():
    _click_stream = _tone(880.0, 0.05, 0.3)
    _pickup_stream = _tone(660.0, 0.15, 0.4)
    _door_stream = _noise(0.3, 0.2)
    _footstep_stream = _noise(0.08, 0.15)
    _ambient_main_stream = _ambient_pad([220.0, 330.0, 440.0], 0.15)
    _ambient_intimate_stream = _ambient_pad([110.0, 165.0, 220.0], 0.12)

func _tone(freq: float, dur: float, vol: float) -> AudioStreamWAV:
    var sr = 22050
    var n = int(sr * dur)
    var data = PackedByteArray()
    data.resize(n * 2)
    for i in range(n):
        var t = float(i) / sr
        var env = 1.0 - (float(i) / n)
        env = env * env
        var v = sin(t * freq * TAU) * vol * env
        var s = int(clamp(v * 32767.0, -32768, 32767))
        data[i*2] = s & 0xFF
        data[i*2+1] = (s >> 8) & 0xFF
    var stream = AudioStreamWAV.new()
    stream.data = data
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sr
    stream.stereo = false
    return stream

func _noise(dur: float, vol: float) -> AudioStreamWAV:
    var sr = 22050
    var n = int(sr * dur)
    var data = PackedByteArray()
    data.resize(n * 2)
    for i in range(n):
        var env = 1.0 - (float(i) / n)
        var v = (randf() * 2.0 - 1.0) * vol * env
        var s = int(clamp(v * 32767.0, -32768, 32767))
        data[i*2] = s & 0xFF
        data[i*2+1] = (s >> 8) & 0xFF
    var stream = AudioStreamWAV.new()
    stream.data = data
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sr
    stream.stereo = false
    return stream

func _ambient_pad(freqs: Array, vol: float) -> AudioStreamWAV:
    var sr = 22050
    var dur = 4.0
    var n = int(sr * dur)
    var data = PackedByteArray()
    data.resize(n * 2)
    for i in range(n):
        var t = float(i) / sr
        var v = 0.0
        for f in freqs:
            v += sin(t * f * TAU) * vol / freqs.size()
        v *= 0.7 + 0.3 * sin(t * 0.5 * TAU)
        var env = 1.0
        if i < sr * 0.5:
            env = float(i) / (sr * 0.5)
        elif i > n - sr * 0.5:
            env = float(n - i) / (sr * 0.5)
        v *= env
        var s = int(clamp(v * 32767.0, -32768, 32767))
        data[i*2] = s & 0xFF
        data[i*2+1] = (s >> 8) & 0xFF
    var stream = AudioStreamWAV.new()
    stream.data = data
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sr
    stream.stereo = false
    stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
    stream.loop_begin = int(sr * 0.5)
    stream.loop_end = n - int(sr * 0.5)
    return stream

func play_music(stream: AudioStreamWAV):
    if music_player.stream == stream and music_player.playing:
        return
    music_player.stream = stream
    music_player.play()

func play_music_path(path: String):
    if path == "ambient_main":
        play_music(_ambient_main_stream)
    elif path == "ambient_intimate":
        play_music(_ambient_intimate_stream)

func stop_music():
    music_player.stop()

func play_sfx(stream: AudioStreamWAV, volume_db: float = 0.0):
    for p in sfx_players:
        if not p.playing:
            p.stream = stream
            p.volume_db = volume_db
            p.play()
            return
    sfx_players[0].stream = stream
    sfx_players[0].volume_db = volume_db
    sfx_players[0].play()

func play_footstep():
    play_sfx(_footstep_stream, -15.0)

func play_click():
    play_sfx(_click_stream, -8.0)

func play_pickup():
    play_sfx(_pickup_stream, -6.0)

func play_door():
    play_sfx(_door_stream, -10.0)