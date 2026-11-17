class_name Level
extends RefCounted
## One dungeon level: a grid of cells plus the entrance and the exit.
##
## Pure data, knows nothing about nodes or drawing. Cells are addressed with
## Vector2i(x, y); everything outside the grid reads as a wall.

enum Cell { WALL, FLOOR, ENTRANCE, EXIT }

const NO_CELL: Vector2i = Vector2i(-1, -1)

var width: int
var height: int
var entrance_cell: Vector2i = NO_CELL
var exit_cell: Vector2i = NO_CELL
## Seed the level was generated from (0 for hand-made levels).
var generation_seed: int = 0

var _cells: PackedByteArray


func _init(level_width: int, level_height: int) -> void:
	width = level_width
	height = level_height
	_cells = PackedByteArray()
	_cells.resize(width * height)
	_cells.fill(Cell.WALL)


## Builds a level from text rows: '#' wall, '.' floor, 'S' entrance, 'E' exit.
static func from_rows(rows: PackedStringArray) -> Level:
	var level: Level = Level.new(rows[0].length(), rows.size())
	for y: int in range(level.height):
		for x: int in range(level.width):
			var cell: Vector2i = Vector2i(x, y)
			match rows[y][x]:
				".":
					level.set_cell(cell, Cell.FLOOR)
				"S":
					level.set_entrance(cell)
				"E":
					level.set_exit(cell)
	return level


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height


func get_cell(cell: Vector2i) -> Cell:
	if not is_inside(cell):
		return Cell.WALL
	return _cells[cell.y * width + cell.x] as Cell


func set_cell(cell: Vector2i, value: Cell) -> void:
	if is_inside(cell):
		_cells[cell.y * width + cell.x] = value


func set_entrance(cell: Vector2i) -> void:
	entrance_cell = cell
	set_cell(cell, Cell.ENTRANCE)


func set_exit(cell: Vector2i) -> void:
	exit_cell = cell
	set_cell(cell, Cell.EXIT)


func is_walkable(cell: Vector2i) -> bool:
	return get_cell(cell) != Cell.WALL


## True if the exit can be reached from the entrance by walking.
func has_path() -> bool:
	if not is_walkable(entrance_cell) or not is_walkable(exit_cell):
		return false
	var visited: Dictionary[Vector2i, bool] = { entrance_cell: true }
	var queue: Array[Vector2i] = [entrance_cell]
	while not queue.is_empty():
		var current: Vector2i = queue.pop_back()
		if current == exit_cell:
			return true
		for direction: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var next: Vector2i = current + direction
			if is_walkable(next) and not visited.has(next):
				visited[next] = true
				queue.append(next)
	return false
