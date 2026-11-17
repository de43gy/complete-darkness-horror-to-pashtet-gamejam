class_name LevelView
extends Control
## Draws a Level. Sizes itself to the level, so levels of any size work.
##
## A cell is shown in one of two ways:
## - seen (lit): in colour. For now this is only the debug `revealed` mode;
##   later light sources and the girl's field of view will decide it.
## - felt: black and white, taken from `memory`, dimmer the older it is.
## Everything else stays black.

## Colours of cells she can see.
const SEEN_COLORS: Dictionary[Level.Cell, Color] = {
	Level.Cell.WALL: Color(0.42, 0.38, 0.36),
	Level.Cell.FLOOR: Color(0.85, 0.8, 0.7),
	Level.Cell.ENTRANCE: Color.GREEN,
	Level.Cell.EXIT: Color.RED,
}
## Cells she only feels are drawn in one colour and told apart by shape, so
## that fading with age cannot turn one kind into another: a wall is a solid
## block, floor is an outline, stairs are an outline with a triangle.
const FELT_COLOR: Color = Color.WHITE
const DARKNESS_COLOR: Color = Color.BLACK
const GRID_COLOR: Color = Color(0.5, 0.5, 0.5, 0.2)

## Pixels per cell.
@export var cell_size: int = 16:
	set(value):
		cell_size = maxi(value, 1)
		_update_size()

## Show the whole level instead of darkness.
@export var revealed: bool = false:
	set(value):
		revealed = value
		queue_redraw()

## Thin lines between cells, handy when looking at generator output.
@export var show_grid: bool = false:
	set(value):
		show_grid = value
		queue_redraw()

var level: Level:
	set(value):
		level = value
		_update_size()

## Cells the girl remembers; drawn when the level is not revealed, the older
## the memory the dimmer the cell.
var memory: Memory:
	set(value):
		memory = value
		queue_redraw()


## Centre of a cell in this node's local coordinates.
func cell_to_position(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * cell_size


func _update_size() -> void:
	if level != null:
		custom_minimum_size = Vector2(level.width, level.height) * cell_size
	queue_redraw()


func _draw() -> void:
	if level == null:
		return
	var level_size: Vector2 = Vector2(level.width, level.height) * cell_size
	draw_rect(Rect2(Vector2.ZERO, level_size), DARKNESS_COLOR)

	if revealed:
		for y: int in range(level.height):
			for x: int in range(level.width):
				draw_rect(_cell_rect(Vector2i(x, y)), SEEN_COLORS[level.get_cell(Vector2i(x, y))])
	elif memory != null:
		for cell: Vector2i in memory.get_cells():
			_draw_felt_cell(cell, memory.get_cell(cell), memory.get_strength(cell))

	if revealed and show_grid:
		for x: int in range(level.width + 1):
			draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, level_size.y), GRID_COLOR)
		for y: int in range(level.height + 1):
			draw_line(Vector2(0, y * cell_size), Vector2(level_size.x, y * cell_size), GRID_COLOR)


func _cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(Vector2(cell) * cell_size, Vector2(cell_size, cell_size))


## Black and white picture of a cell known by touch. The triangle on stairs
## points up for the way back and down for the way deeper.
func _draw_felt_cell(cell: Vector2i, type: Level.Cell, strength: float) -> void:
	var rect: Rect2 = _cell_rect(cell)
	var color: Color = Color(FELT_COLOR, strength)
	if type == Level.Cell.WALL:
		draw_rect(rect, color)
		return
	draw_rect(rect.grow(-0.5), color, false, 1.0)
	if type == Level.Cell.FLOOR:
		return

	var center: Vector2 = rect.get_center()
	var half: float = cell_size * 0.25
	var tip: float = -half if type == Level.Cell.ENTRANCE else half
	draw_colored_polygon(
			PackedVector2Array([
				center + Vector2(0, tip),
				center + Vector2(-half, -tip),
				center + Vector2(half, -tip),
			]),
			color)
