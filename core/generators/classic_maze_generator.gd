class_name ClassicMazeGenerator
extends LevelGenerator
## Classic "perfect" maze: depth-first search with backtracking.
##
## Rooms sit on cells with odd coordinates, corridors are carved between them.
## Works best with odd width and height; with an even size the last column or
## row stays solid wall. Entrance is at the bottom, exit at the top.

const STEPS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


func get_display_name() -> String:
	return "Классический лабиринт"


func generate(width: int, height: int, rng: RandomNumberGenerator) -> Level:
	var level: Level = Level.new(width, height)
	_carve_maze(level, rng)

	# an odd column always contains a room in row 1, so the shafts below
	# are guaranteed to reach the maze
	@warning_ignore("integer_division")
	var middle_x: int = mini((width / 2) | 1, width - 2)
	_carve_shaft(level, Vector2i(middle_x, height - 1), Vector2i.UP)
	_carve_shaft(level, Vector2i(middle_x, 0), Vector2i.DOWN)
	level.set_entrance(Vector2i(middle_x, height - 1))
	level.set_exit(Vector2i(middle_x, 0))
	return level


func _carve_maze(level: Level, rng: RandomNumberGenerator) -> void:
	var start: Vector2i = Vector2i(1, 1)
	var stack: Array[Vector2i] = [start]
	level.set_cell(start, Level.Cell.FLOOR)

	while not stack.is_empty():
		var current: Vector2i = stack.back()
		var unvisited: Array[Vector2i] = []
		for step: Vector2i in STEPS:
			var room: Vector2i = current + step * 2
			if _is_room(level, room) and level.get_cell(room) == Level.Cell.WALL:
				unvisited.append(room)

		if unvisited.is_empty():
			stack.pop_back()
			continue

		var next: Vector2i = unvisited[rng.randi_range(0, unvisited.size() - 1)]
		level.set_cell((current + next) / 2, Level.Cell.FLOOR)
		level.set_cell(next, Level.Cell.FLOOR)
		stack.append(next)


## Rooms never touch the outer border, so the level stays walled in.
func _is_room(level: Level, cell: Vector2i) -> bool:
	return cell.x >= 1 and cell.x <= level.width - 2 and cell.y >= 1 and cell.y <= level.height - 2


## Opens cells from the border inwards until the maze is reached.
func _carve_shaft(level: Level, from: Vector2i, direction: Vector2i) -> void:
	var cell: Vector2i = from
	while level.is_inside(cell) and level.get_cell(cell) == Level.Cell.WALL:
		level.set_cell(cell, Level.Cell.FLOOR)
		cell += direction
