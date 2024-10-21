extends Node2D

@onready var labyrinth = $Labyrinth
@onready var ui = $UserInterface
@onready var message_log = $MessageLog

func _ready():
	MazeConstants.set_message_log(message_log)
	labyrinth.spawn_player()
	
