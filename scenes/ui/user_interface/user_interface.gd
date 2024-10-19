extends Control

signal generate_maze
signal ensure_borders
signal create_entrance_exit
signal check_create_path
signal clear_maze

func _ready():
	$VBoxContainer/GenerateButton.connect("pressed", _on_generate_pressed)
	$VBoxContainer/BordersButton.connect("pressed", _on_borders_pressed)
	$VBoxContainer/EntranceExitButton.connect("pressed", _on_entrance_exit_pressed)
	$VBoxContainer/PathButton.connect("pressed", _on_path_pressed)
	$VBoxContainer/ClearButton.connect("pressed", _on_clear_pressed)

func _on_generate_pressed():
	emit_signal("generate_maze")

func _on_borders_pressed():
	emit_signal("ensure_borders")

func _on_entrance_exit_pressed():
	emit_signal("create_entrance_exit")

func _on_path_pressed():
	emit_signal("check_create_path") 

func _on_clear_pressed():
	print("Clear button pressed")
	emit_signal("clear_maze")
