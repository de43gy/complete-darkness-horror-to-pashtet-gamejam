class_name ActionResult
extends RefCounted
## What happened when the girl tried to do something.
##
## Produced by Explorer, turned into text by Messages and into movement and
## animation by the game scene.

enum Action { STEP, PROBE, STOMP, JUMP }

enum Outcome {
	BLOCKED,    ## a wall right ahead, nothing happened
	MOVED,      ## she is now standing on `cell`
	CUT_SHORT,  ## jump stopped by a wall: she landed one cell ahead instead of two
	SENSED,     ## she did not move but learned what `cell` is
}

var action: Action
var outcome: Outcome
var direction: Vector2i
## The cell type this result is about: the one she landed on or felt.
var cell: Level.Cell
var from_cell: Vector2i
var to_cell: Vector2i


func _init(
		result_action: Action,
		result_outcome: Outcome,
		result_direction: Vector2i,
		result_cell: Level.Cell,
		position_before: Vector2i,
		position_after: Vector2i,
) -> void:
	action = result_action
	outcome = result_outcome
	direction = result_direction
	cell = result_cell
	from_cell = position_before
	to_cell = position_after


func has_moved() -> bool:
	return from_cell != to_cell
