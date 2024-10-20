extends Node2D

const WIDTH = 20
const HEIGHT = 15
const CELL_SIZE = 32
const WALL = 1
const PATH = 0

enum MazeType { CLASSIC, FRACTAL, CAVE, ROOMS }
var current_maze_type = MazeType.CLASSIC

@onready var container = $LabyrinthContainer

var maze = []
var visited = []
var collision_objects = []
var wall_tiles: Node2D
var player: CharacterBody2D
var player_scene = preload("res://scenes/entities/player/player.tscn")
var entrance_pos: Vector2
var exit_pos: Vector2
var timeout = 1000 #time limit for generating a complex dungeon, after which a simple one is created

func _ready():
	randomize()
	wall_tiles = Node2D.new()
	add_child(wall_tiles)
	initialize_maze()
	generate_maze()
	create_collision_walls()
	spawn_player()

func initialize_maze():
	if WIDTH != container.labyrinth_width or HEIGHT != container.labyrinth_height or CELL_SIZE != container.cell_size:
		container.update_size(WIDTH, HEIGHT, CELL_SIZE)
	
	initialize_maze_arrays()

func generate_maze():
	initialize_maze_arrays()
	
	match current_maze_type:
		MazeType.CLASSIC:
			generate_classic_maze()
		MazeType.FRACTAL:
			generate_fractal_maze()
		MazeType.CAVE:
			generate_cave_maze()
		MazeType.ROOMS:
			generate_rooms_maze()
	
	create_entrance_and_exit()
	ensure_path()
	ensure_border_walls()
	container.queue_redraw()
	
	emit_signal("maze_generated")

#logic for checking and creating a path
func ensure_path():
	var start = entrance_pos
	var end = exit_pos
	var path = find_path(start, end)
	
	if path.size() == 0:
		print("No path found, creating one")
		#create_bidirectional_path(start, end)
	else:
		print("Path found, length: ", path.size())

func initialize_maze_arrays():
	maze = []
	visited = []

	for y in range(HEIGHT):
		var maze_row = []
		var visited_row = []
		for x in range(WIDTH):
			maze_row.append(WALL)
			visited_row.append(false)
		maze.append(maze_row)
		visited.append(visited_row)


func find_path(start: Vector2, end: Vector2) -> Array:
	var queue = [start]
	var came_from = {}
	
	while queue:
		var current = queue.pop_front()
		if current == end:
			return reconstruct_path(came_from, end)
		
		for dir in [[0,1], [1,0], [0,-1], [-1,0]]:
			var next = Vector2(current.x + dir[0], current.y + dir[1])
			if is_valid_position(next.x, next.y) and maze[next.y][next.x] == PATH and not came_from.has(next):
				queue.append(next)
				came_from[next] = current
	
	return []

func reconstruct_path(came_from: Dictionary, end: Vector2) -> Array:
	var path = [end]
	var current = end
	while came_from.has(current):
		current = came_from[current]
		path.push_front(current)
	return path

func create_bidirectional_path(start: Vector2, end: Vector2):
	var current_start = start
	var current_end = end

	var stack_start = [current_start]
	var stack_end = [current_end]

	var visited_start = {}
	var visited_end = {}

	maze[current_start.y][current_start.x] = PATH
	maze[current_end.y][current_end.x] = PATH
	visited_start[current_start] = true
	visited_end[current_end] = true

	while stack_start.size() > 0 or stack_end.size() > 0:
		if stack_start.size() > 0:
			current_start = stack_start.pop_back()
			var directions = [[0, -1], [0, 1], [-1, 0], [1, 0]]
			directions.shuffle()

			for direction in directions:
				var next_pos = current_start + Vector2(direction[0], direction[1])

				if is_valid_position(next_pos.x, next_pos.y) and not visited_start.has(next_pos):
					if maze[next_pos.y][next_pos.x] == WALL:
						maze[next_pos.y][next_pos.x] = PATH

					stack_start.append(next_pos)
					visited_start[next_pos] = true

					if visited_end.has(next_pos):
						return

		if stack_end.size() > 0:
			current_end = stack_end.pop_back()
			var directions = [[0, -1], [0, 1], [-1, 0], [1, 0]]
			directions.shuffle()

			for direction in directions:
				var next_pos = current_end + Vector2(direction[0], direction[1])

				if is_valid_position(next_pos.x, next_pos.y) and not visited_end.has(next_pos):
					if maze[next_pos.y][next_pos.x] == WALL:
						maze[next_pos.y][next_pos.x] = PATH

					stack_end.append(next_pos)
					visited_end[next_pos] = true

					if visited_start.has(next_pos):
						return

func ensure_border_walls():
	for x in range(WIDTH):
		if x != entrance_pos.x:
			maze[0][x] = WALL
		if x != exit_pos.x:
			maze[HEIGHT - 1][x] = WALL

	for y in range(HEIGHT):
		maze[y][0] = WALL
		maze[y][WIDTH - 1] = WALL

func create_entrance_and_exit():
	var middle_x = WIDTH / 2

	entrance_pos = Vector2(middle_x, HEIGHT - 1)
	maze[entrance_pos.y][entrance_pos.x] = PATH
	maze[entrance_pos.y - 1][entrance_pos.x] = PATH

	exit_pos = Vector2(middle_x, 0)
	maze[exit_pos.y][exit_pos.x] = PATH
	maze[exit_pos.y + 1][exit_pos.x] = PATH

	emit_signal("entrance_exit_created")
	container.queue_redraw()

func is_path_exists(start: Vector2, end: Vector2) -> bool:
	var queue = [start]
	var visited = {}
	
	while queue:
		var current = queue.pop_front()
		if current == end:
			return true
		
		for dir in [[0,1], [1,0], [0,-1], [-1,0]]:
			var next = Vector2(current.x + dir[0], current.y + dir[1])
			if is_valid_position(next.x, next.y) and maze[next.y][next.x] == PATH and not visited.has(next):
				queue.append(next)
				visited[next] = true
	
	return false

func generate_classic_maze():
	print("Classic maze generation started")
	var start_time = Time.get_ticks_msec()
	
	for y in range(HEIGHT):
		for x in range(WIDTH):
			maze[y][x] = WALL
			visited[y][x] = false

	var start_x = 1
	var start_y = 1
	var stack = [[start_x, start_y]]
	visited[start_y][start_x] = true
	maze[start_y][start_x] = PATH

	while stack.size() > 0:
		if Time.get_ticks_msec() - start_time > timeout:
			print("Classic maze generation timed out. Switching to simple generation.")
			generate_simple_maze()
			return

		var current = stack[-1]
		var x = current[0]
		var y = current[1]

		var neighbors = []
		for neighbor in [[-2, 0], [2, 0], [0, -2], [0, 2]]:
			var nx = x + neighbor[0]
			var ny = y + neighbor[1]
			if nx > 0 and nx < WIDTH - 1 and ny > 0 and ny < HEIGHT - 1 and not visited[ny][nx]:
				neighbors.append([nx, ny])

		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			var nx = next[0]
			var ny = next[1]

			maze[(y + ny) / 2][(x + nx) / 2] = PATH

			visited[ny][nx] = true
			maze[ny][nx] = PATH

			stack.append([nx, ny])
		else:
			stack.pop_back()

	print("Classic maze generation completed in ", Time.get_ticks_msec() - start_time, " ms")

func ensure_path_exists():
	var start = entrance_pos
	var end = exit_pos
	var path = find_path(start, end)

	if path.size() == 0:
		print("No path found, creating one")
		create_bidirectional_path(start, end)
	else:
		print("Path found, length: ", path.size())


func generate_simple_maze() -> void:
	print("Generating simple maze")
	for y in range(HEIGHT):
		for x in range(WIDTH):
			maze[y][x] = PATH if randf() > 0.3 else WALL
	ensure_path()
	print("Simple maze generation completed")

func carve_path(x, y):
	maze[y][x] = PATH
	
	var directions = [[1,0], [0,1], [-1,0], [0,-1]]
	directions.shuffle()
	
	for dir in directions:
		var next_x = x + dir[0] * 2
		var next_y = y + dir[1] * 2
		
		if is_valid_position(next_x, next_y) and maze[next_y][next_x] == WALL:
			maze[y + dir[1]][x + dir[0]] = PATH
			carve_path(next_x, next_y)

func generate_cave_maze():
	for y in range(HEIGHT):
		for x in range(WIDTH):
			maze[y][x] = WALL if randf() < 0.45 else PATH
	
	for i in range(4):
		smooth_cave()
	
	ensure_path()

func smooth_cave():
	var new_maze = maze.duplicate(true)
	for y in range(1, HEIGHT - 1):
		for x in range(1, WIDTH - 1):
			var walls_count = count_neighbor_walls(x, y)
			if walls_count > 4:
				new_maze[y][x] = WALL
			elif walls_count < 4:
				new_maze[y][x] = PATH
	maze = new_maze

func count_neighbor_walls(x, y):
	var count = 0
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			if maze[y + dy][x + dx] == WALL:
				count += 1
	return count

func generate_rooms_maze():
	var rooms = []
	var max_room_size = 7
	var min_room_size = 3
	var attempts = 0
	var max_attempts = 100

	while rooms.size() < 15 and attempts < max_attempts:
		var room_width = randi() % (max_room_size - min_room_size + 1) + min_room_size
		var room_height = randi() % (max_room_size - min_room_size + 1) + min_room_size
		var room_x = randi() % (WIDTH - room_width - 2) + 1
		var room_y = randi() % (HEIGHT - room_height - 2) + 1
		
		var room = Rect2(room_x, room_y, room_width, room_height)
		
		if not rooms.any(func(existing_room): return room.intersects(existing_room)):
			rooms.append(room)
			for y in range(room_y, room_y + room_height):
				for x in range(room_x, room_x + room_width):
					maze[y][x] = PATH
		
		attempts += 1

	for i in range(rooms.size() - 1):
		connect_rooms(rooms[i], rooms[i + 1])

	add_random_corridors(5)

func connect_rooms(room1: Rect2, room2: Rect2):
	var start = Vector2(
		randi() % int(room1.size.x) + room1.position.x,
		randi() % int(room1.size.y) + room1.position.y
	)
	var end = Vector2(
		randi() % int(room2.size.x) + room2.position.x,
		randi() % int(room2.size.y) + room2.position.y
	)
	
	var current = start
	while current != end:
		maze[current.y][current.x] = PATH
		if randf() > 0.5:
			current.x += sign(end.x - current.x)
		else:
			current.y += sign(end.y - current.y)

func add_random_corridors(count):
	for i in range(count):
		var start = Vector2(randi() % WIDTH, randi() % HEIGHT)
		var end = Vector2(randi() % WIDTH, randi() % HEIGHT)
		var current = start
		while current != end:
			maze[current.y][current.x] = PATH
			if randf() > 0.5:
				current.x += sign(end.x - current.x)
			else:
				current.y += sign(end.y - current.y)

func add_random_passages():
	var passages_count = WIDTH * HEIGHT / 20
	var attempts = 0
	var max_attempts = passages_count * 2

	while passages_count > 0 and attempts < max_attempts:
		var x = randi() % (WIDTH - 2) + 1
		var y = randi() % (HEIGHT - 2) + 1
		if maze[y][x] == WALL:
			maze[y][x] = PATH
			passages_count -= 1
		attempts += 1

func generate_fractal_maze():
	fractal_divide(0, 0, WIDTH, HEIGHT, 5)

func fractal_divide(x, y, w, h, depth):
	if depth == 0 or w < 3 or h < 3:
		return
	
	var divide_horizontally = randf() > 0.5 if w > h else false
	
	if divide_horizontally:
		var divide_y = y + randi() % (h - 2) + 1
		for i in range(x, x + w):
			maze[divide_y][i] = WALL
		var passage = x + randi() % w
		maze[divide_y][passage] = PATH
		fractal_divide(x, y, w, divide_y - y, depth - 1)
		fractal_divide(x, divide_y + 1, w, h - (divide_y - y + 1), depth - 1)
	else:
		var divide_x = x + randi() % (w - 2) + 1
		for i in range(y, y + h):
			maze[i][divide_x] = WALL
		var passage = y + randi() % h
		maze[passage][divide_x] = PATH
		fractal_divide(x, y, divide_x - x, h, depth - 1)
		fractal_divide(divide_x + 1, y, w - (divide_x - x + 1), h, depth - 1)

func is_valid_position(x: int, y: int) -> bool:
	return x > 0 and x < WIDTH - 1 and y > 0 and y < HEIGHT - 1

func ensure_entrance_exit_accessibility():
	if maze[entrance_pos.y - 1][entrance_pos.x - 1] == WALL and maze[entrance_pos.y - 1][entrance_pos.x + 1] == WALL:
		maze[entrance_pos.y - 1][randi() % 2 * 2 - 1 + entrance_pos.x] = PATH
	
	if maze[exit_pos.y + 1][exit_pos.x - 1] == WALL and maze[exit_pos.y + 1][exit_pos.x + 1] == WALL:
		maze[exit_pos.y + 1][randi() % 2 * 2 - 1 + exit_pos.x] = PATH

func create_collision_walls():
	if collision_objects.size() != WIDTH * HEIGHT:
		for wall in collision_objects:
			wall.queue_free()
		collision_objects.clear()

		for y in range(HEIGHT):
			for x in range(WIDTH):
				var wall = create_collision_object(x, y)
				wall_tiles.add_child(wall)
				collision_objects.append(wall)

	var index = 0
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var wall = collision_objects[index]
			if maze[y][x] == WALL:
				wall.position = Vector2(x * CELL_SIZE + CELL_SIZE / 2, y * CELL_SIZE + CELL_SIZE / 2)
				wall.show()
			else:
				wall.hide()
			index += 1

func create_collision_object(x: int, y: int) -> StaticBody2D:
	var wall = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(CELL_SIZE, CELL_SIZE)
	collision.shape = shape
	wall.add_child(collision)
	wall.position = Vector2(x * CELL_SIZE + CELL_SIZE / 2, y * CELL_SIZE + CELL_SIZE / 2)
	return wall

func spawn_player():
	if player:
		player.position = Vector2(entrance_pos.x * CELL_SIZE + CELL_SIZE/2, entrance_pos.y * CELL_SIZE + CELL_SIZE/2)
		return
	player = player_scene.instantiate()
	player.position = Vector2(entrance_pos.x * CELL_SIZE + CELL_SIZE/2, entrance_pos.y * CELL_SIZE + CELL_SIZE/2)
	add_child(player)

func _input(event):
	if event.is_action_pressed("ui_select"):  # space
		current_maze_type = (current_maze_type + 1) % MazeType.size()
		print("Switching to maze type: " + MazeType.keys()[current_maze_type])
		generate_maze()
		create_collision_walls()
		spawn_player()
		container.queue_redraw()
