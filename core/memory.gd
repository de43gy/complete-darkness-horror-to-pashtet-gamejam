class_name Memory
extends RefCounted
## What the girl remembers about the cells she has touched.
##
## A cell is remembered for `duration` turns after she last felt it and then
## forgotten. A turn is a move or an attempt to move; feeling around does not
## count. With the default duration of 1 she only knows what she has learned
## since her latest move.

const MIN_DURATION: int = 1

## How many turns a cell stays in memory.
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
		if _turn - _learned_at[cell] >= duration:
			_cells.erase(cell)
			_learned_at.erase(cell)


func knows(cell: Vector2i) -> bool:
	return _cells.has(cell)


func get_cell(cell: Vector2i) -> Level.Cell:
	return _cells[cell]


func get_cells() -> Array[Vector2i]:
	return _cells.keys()


## 1.0 for something felt this turn, fading towards 0 as it gets old.
func get_strength(cell: Vector2i) -> float:
	if not knows(cell):
		return 0.0
	return 1.0 - float(_turn - _learned_at[cell]) / duration
