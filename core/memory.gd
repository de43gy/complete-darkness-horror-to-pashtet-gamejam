class_name Memory
extends RefCounted
## What the girl remembers about the cells she has touched.
##
## Everything she knows survives `duration` turns and is then forgotten. A
## turn is a move or an attempt to move; feeling around does not count. With
## the default duration of 1 she takes one step and still remembers the cell
## she left and whatever she felt around it; after the next step it is gone.

const MIN_DURATION: int = 1

## How many turns a cell survives after she last felt it.
var duration: int = MIN_DURATION:
	set(value):
		duration = maxi(value, MIN_DURATION)

var _turn: int = 0
var _cells: Dictionary[Vector2i, Level.Cell] = {}
var _learned_at: Dictionary[Vector2i, int] = {}


func _init(memory_duration: int = MIN_DURATION) -> void:
	duration = memory_duration


## Stores (or refreshes) what a cell is.
func remember(cell: Vector2i, type: Level.Cell) -> void:
	_cells[cell] = type
	_learned_at[cell] = _turn


## Call once per move or attempt to move, before remembering what it revealed.
func advance_turn() -> void:
	_turn += 1
	for cell: Vector2i in _cells.keys():
		if _turn - _learned_at[cell] > duration:
			_cells.erase(cell)
			_learned_at.erase(cell)


func knows(cell: Vector2i) -> bool:
	return _cells.has(cell)


func get_cell(cell: Vector2i) -> Level.Cell:
	return _cells[cell]


func get_cells() -> Array[Vector2i]:
	return _cells.keys()


## 1.0 for something felt since the latest turn, fading as it gets old.
func get_strength(cell: Vector2i) -> float:
	if not knows(cell):
		return 0.0
	return 1.0 - float(_turn - _learned_at[cell]) / (duration + 1)


## Wall cells she has not touched but can work out: a wall sitting in the
## corner between two remembered walls that touch each other diagonally.
## Returns corner cell -> strength, the strength of the weaker of the two
## walls. Nothing is stored: the corner is gone the moment either wall is
## forgotten. A corner that is not really a wall is never returned.
func infer_corners(level: Level) -> Dictionary[Vector2i, float]:
	var corners: Dictionary[Vector2i, float] = {}
	for wall: Vector2i in _cells:
		if _cells[wall] != Level.Cell.WALL:
			continue
		# looking only to the right is enough: every diagonal pair has a left wall
		for other: Vector2i in [wall + Vector2i(1, -1), wall + Vector2i(1, 1)]:
			if _cells.get(other, Level.Cell.FLOOR) != Level.Cell.WALL:
				continue
			var strength: float = minf(get_strength(wall), get_strength(other))
			for corner: Vector2i in [Vector2i(wall.x, other.y), Vector2i(other.x, wall.y)]:
				if not knows(corner) and level.is_inside(corner) and level.get_cell(corner) == Level.Cell.WALL:
					corners[corner] = maxf(corners.get(corner, 0.0), strength)
	return corners
