extends Control
## Main menu: start the game, open the generator lab, quit.

const GAME_SCENE: String = "res://scenes/game/game.tscn"
const GENERATOR_LAB_SCENE: String = "res://scenes/generator_lab/generator_lab.tscn"

@onready var start_button: Button = %StartButton
@onready var generator_lab_button: Button = %GeneratorLabButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	generator_lab_button.pressed.connect(_on_generator_lab_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	start_button.grab_focus()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_generator_lab_pressed() -> void:
	get_tree().change_scene_to_file(GENERATOR_LAB_SCENE)


func _on_exit_pressed() -> void:
	get_tree().quit()
