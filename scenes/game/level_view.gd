class_name LevelView
extends Control
## Draws a Level. Sizes itself to the level, so levels of any size work.
##
## A cell is shown in one of two ways:
## - seen (lit): the colour tile. For now this is only the debug `revealed`
##   mode; later light sources and the girl's field of view will decide it.
## - felt: the white contour tile, taken from `memory`, dimmer the older it is.
##   A wall in the corner between two felt walls is drawn too, see
##   Memory.infer_corners(). When light is added the same rule applies to it:
##   the corner is lit only if both walls are lit, otherwise it is felt.
## Everything else stays black.
##
## Both atlases have the same layout, so a cell uses the same tile in each.

## Size of one tile in the atlases, in pixels.
const TILE_SIZE: int = 16
const SEEN_TILES: Texture2D = preload("res://assets/tiles/tiles_seen.png")
const FELT_TILES: Texture2D = preload("res://assets/tiles/tiles_felt.png")
## Atlas columns for each cell type; several columns are variants of one tile.
const TILE_COLUMNS: Dictionary[Level.Cell, Array] = {
	Level.Cell.WALL: [0, 1],
	Level.Cell.FLOOR: [2, 3, 4],
	Level.Cell.ENTRANCE: [5],
	Level.Cell.EXIT: [6],
}
const DARKNESS_COLOR: Color = Color.BLACK
const GRID_COLOR: Color = Color(0.5, 0.5, 0.5, 0.2)

## Pixels per cell.
@export var cell_size: int = 32:
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
				var cell: Vector2i = Vector2i(x, y)
				draw_texture_rect_region(SEEN_TILES, _cell_rect(cell), _tile_region(cell, level.get_cell(cell)))
	elif memory != null:
		for cell: Vector2i in memory.get_cells():
			draw_texture_rect_region(
					FELT_TILES, _cell_rect(cell), _tile_region(cell, memory.get_cell(cell)),
					Color(1, 1, 1, memory.get_strength(cell)))
		var corners: Dictionary[Vector2i, float] = memory.infer_corners(level)
		for cell: Vector2i in corners:
			draw_texture_rect_region(
					FELT_TILES, _cell_rect(cell), _tile_region(cell, Level.Cell.WALL),
					Color(1, 1, 1, corners[cell]))

	if revealed and show_grid:
		for x: int in range(level.width + 1):
			draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, level_size.y), GRID_COLOR)
		for y: int in range(level.height + 1):
			draw_line(Vector2(0, y * cell_size), Vector2(level_size.x, y * cell_size), GRID_COLOR)


func _cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(Vector2(cell) * cell_size, Vector2(cell_size, cell_size))


## Part of the atlas holding the tile for a cell. The variant depends only on
## the cell position, so a cell always looks the same.
func _tile_region(cell: Vector2i, type: Level.Cell) -> Rect2:
	var columns: Array = TILE_COLUMNS[type]
	var variant: int = absi(cell.x * 73856093 ^ cell.y * 19349663) % columns.size()
	var column: int = columns[variant]
	return Rect2(column * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE)
