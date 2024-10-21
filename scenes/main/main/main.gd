extends Node2D

@onready var labyrinth = $Labyrinth
@onready var ui = $UserInterface
@onready var message_log = $MessageLog

func _ready():
	MazeConstants.set_message_log(message_log)
	labyrinth.spawn_player()

	#ui.connect("generate_maze", labyrinth.generate_maze)
	#ui.connect("ensure_borders", labyrinth.ensure_border_walls)
	#ui.connect("create_entrance_exit", labyrinth.create_entrance_and_exit)
	#ui.connect("check_create_path", labyrinth.ensure_connectivity)
	#ui.clear_maze.connect(labyrinth.clear_maze)
	#
	#labyrinth.connect("maze_generated", message_log.log_message.bind("New maze generated"))
	#labyrinth.connect("borders_ensured", message_log.log_message.bind("Borders ensured"))
	#labyrinth.connect("entrance_exit_created", message_log.log_message.bind("Entrance and exit created"))
	#labyrinth.connect("path_checked", message_log.log_message)
	##labyrinth.maze_cleared.connect(func(): message_log.log_message("Maze cleared"))
	#
	#print("Signals connected in Main")
