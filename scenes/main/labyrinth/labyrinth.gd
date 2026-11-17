extends Node2D

class_name Labyrinth

@onready var labyrinth_container: LabyrinthContainer = $LabyrinthContainer

var maze_generator: ClassicMazeGenerator
var entrance_exit: MazeEntranceExit
var player_scene: PackedScene = preload("res://scenes/entities/player/player.tscn")

var collision_objects = []
var wall_tiles: Node2D
var player: CharacterBody2D


func _ready():
	MazeConstants.labyrinth_container = labyrinth_container
	maze_generator = ClassicMazeGenerator.new()
	entrance_exit = MazeEntranceExit.new()
	wall_tiles = Node2D.new()
	add_child(wall_tiles)
	generate_maze()

func generate_maze():
	randomize()
	maze_generator.generate_classic_maze()
	ensure_border_walls()
	entrance_exit.create_entrance_and_exit()
	create_collision_walls()
	spawn_player()
	labyrinth_container.queue_redraw()

func ensure_border_walls():
	var maze = MazeArray.get_maze_array()
	# the entrance and exit are carved afterwards by MazeEntranceExit
	for x in range(MazeConstants.WIDTH):
		maze[0][x] = MazeConstants.WALL
		maze[MazeConstants.HEIGHT - 1][x] = MazeConstants.WALL

	for y in range(MazeConstants.HEIGHT):
		maze[y][0] = MazeConstants.WALL
		maze[y][MazeConstants.WIDTH - 1] = MazeConstants.WALL
	MazeArray.set_maze_array(maze)
	labyrinth_container.queue_redraw()

func create_collision_walls():
	var maze = MazeArray.get_maze_array()
	if collision_objects.size() != MazeConstants.WIDTH * MazeConstants.HEIGHT:
		for wall in collision_objects:
			wall.queue_free()
		collision_objects.clear()

		for y in range(MazeConstants.HEIGHT):
			for x in range(MazeConstants.WIDTH):
				var wall = create_collision_object(x, y)
				wall_tiles.add_child(wall)
				collision_objects.append(wall)

	var index = 0
	for y in range(MazeConstants.HEIGHT):
		for x in range(MazeConstants.WIDTH):
			var wall = collision_objects[index]
			if maze[y][x] == MazeConstants.WALL:
				wall.position = Vector2(x * MazeConstants.CELL_SIZE + MazeConstants.CELL_SIZE / 2, y * MazeConstants.CELL_SIZE + MazeConstants.CELL_SIZE / 2)
				wall.show()
			else:
				wall.hide()
			index += 1
	MazeArray.set_maze_array(maze)

func create_collision_object(x: int, y: int) -> StaticBody2D:
	var wall = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(MazeConstants.CELL_SIZE, MazeConstants.CELL_SIZE)
	collision.shape = shape
	wall.add_child(collision)
	wall.position = Vector2(x * MazeConstants.CELL_SIZE + MazeConstants.CELL_SIZE / 2, y * MazeConstants.CELL_SIZE + MazeConstants.CELL_SIZE / 2)
	return wall

func spawn_player():
	# the player is created once and only moved back to the entrance on regeneration
	if player == null:
		player = player_scene.instantiate()
		add_child(player)

	player.position = Vector2(MazeConstants.entrance_pos.x * MazeConstants.CELL_SIZE + MazeConstants.CELL_SIZE/2, MazeConstants.entrance_pos.y * MazeConstants.CELL_SIZE + MazeConstants.CELL_SIZE/2)

func _input(event):
	if event.is_action_pressed("ui_new_key"):
		randomize()
		generate_maze()
