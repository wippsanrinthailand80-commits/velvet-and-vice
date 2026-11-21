# Main Menu
extends Control

func _ready():
    $VBox/NewGame.connect("pressed", Callable(self, "_on_NewGame_pressed"))
    $VBox/LoadGame.connect("pressed", Callable(self, "_on_LoadGame_pressed"))
    $VBox/Quit.connect("pressed", Callable(self, "_on_Quit_pressed"))
    AudioManager.play_music_path("ambient_main")

func _on_NewGame_pressed():
    GameManager.change_scene("res://scenes/main.tscn")

func _on_LoadGame_pressed():
    if SaveSystem.load_game():
        GameManager.change_scene("res://scenes/main.tscn")
    else:
        $StatusLabel.text = "No save found"

func _on_Quit_pressed():
    get_tree().quit()