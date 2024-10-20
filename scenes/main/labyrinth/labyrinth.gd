extends Node2D

@onready var LabyrinthContainer := $LabyrinthContainer

var ClassicMazeGenerator = preload("res://scripts/utilities/maze_generators/generated_classic_maze.gd")
var MazeEntranceExit = preload("res://scripts/utilities/maze_generators/maze_entrance_exit.gd")
var PlayerScene = preload("res://scenes/entities/player/player.tscn")

var collision_objects = []
var wall_tiles: Node2D
var player: CharacterBody2D


func _ready():
	MazeConstants.labyrinth_container = LabyrinthContainer
	ClassicMazeGenerator = ClassicMazeGenerator.new()
	MazeEntranceExit = MazeEntranceExit.new()
	wall_tiles = Node2D.new()
	add_child(wall_tiles)
	generate_maze()

func generate_maze():
	randomize()
	ClassicMazeGenerator.generate_classic_maze()
	ensure_border_walls()
	MazeEntranceExit.create_entrance_and_exit()
	create_collision_walls()
	spawn_player()
	LabyrinthContainer.queue_redraw()

func ensure_border_walls():
	var maze = MazeArray.get_maze_array()
	for x in range(MazeConstants.WIDTH):
		if x != MazeConstants.entrance_pos.x:
			maze[0][x] = MazeConstants.WALL
		if x != MazeConstants.exit_pos.x:
			maze[MazeConstants.HEIGHT - 1][x] = MazeConstants.WALL

	for y in range(MazeConstants.HEIGHT):
		maze[y][0] = MazeConstants.WALL
		maze[y][MazeConstants.WIDTH - 1] = MazeConstants.WALL
	MazeArray.set_maze_array(maze)
	LabyrinthContainer.queue_redraw()

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
	if player:
		player.position = Vector2(MazeConstants.entrance_pos.x * MazeConstants.CELL_SIZE + MazeConstants.CELL_SIZE/2, MazeConstants.entrance_pos.y * MazeConstants.CELL_SIZE + MazeConstants.CELL_SIZE/2)
		return
	player = PlayerScene.instantiate()
	player.position = Vector2(MazeConstants.entrance_pos.x * MazeConstants.CELL_SIZE + MazeConstants.CELL_SIZE/2, MazeConstants.entrance_pos.y * MazeConstants.CELL_SIZE + MazeConstants.CELL_SIZE/2)
	add_child(player)

func _input(event):
	if event.is_action_pressed("ui_select"):  # space
		randomize()
		generate_maze()
