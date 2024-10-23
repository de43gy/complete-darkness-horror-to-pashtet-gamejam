extends Control

var start_game_scene: PackedScene = preload("res://scenes/main/game_scene/game_scene.tscn")

func _ready():
	$VBoxContainer/CenterContainer/VBoxContainer/ButtonStartGame.pressed.connect(self.start_button_pressed)
	$VBoxContainer/CenterContainer/VBoxContainer/ButtonExitGame.pressed.connect(self.exit_game_pressed)

func start_button_pressed():
	get_tree().change_scene_to_packed(start_game_scene)

func exit_game_pressed():
	get_tree().quit()
