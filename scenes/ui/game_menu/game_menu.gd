extends Control

@export var game_scene: PackedScene

func _ready():
	$StartButton.pressed.connect(self._on_start_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_packed(game_scene)
