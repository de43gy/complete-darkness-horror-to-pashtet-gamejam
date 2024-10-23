extends Control

class_name GameScene

@onready var labyrinth: Labyrinth
@onready var ui: UserInterface
@onready var message_log: MessageLog
	
func _ready():
	var game_elements = get_tree().get_nodes_in_group("game_elements")
	for element in game_elements:
		if element is Labyrinth:
			labyrinth = element
		elif element is MessageLog:
			message_log = element
		elif element is UserInterface:
			ui = element
