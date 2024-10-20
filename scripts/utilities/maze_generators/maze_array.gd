extends RefCounted

class_name MazeArray

static var maze: Array
static var visited: Array
static var width: int
static var height: int
static var is_initialized: bool = false

static func initialize_maze_array() -> Array:
	width = MazeConstants.WIDTH
	height = MazeConstants.HEIGHT
	maze = []
	visited = []

	for y in range(height):
		var maze_row = []
		var visited_row = []
		for x in range(width):
			maze_row.append(MazeConstants.WALL)
			visited_row.append(false)
		maze.append(maze_row)
		visited.append(visited_row)
	is_initialized = false
	return maze

static func set_maze_array(new_maze: Array) -> void:
	maze = new_maze

static func get_maze_array() -> Array:
	return maze
