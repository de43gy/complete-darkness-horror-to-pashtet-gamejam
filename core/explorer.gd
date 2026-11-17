class_name Explorer
extends RefCounted
## The girl as game logic: where she stands, what she remembers and the rules
## of her actions.
##
## Every action returns an ActionResult and writes nothing anywhere, so the
## rules can be tested without a scene.

var level: Level
var cell: Vector2i
## Cells she has touched recently. She always knows the cell under her feet.
var memory: Memory


func _init(explored_level: Level, memory_duration: int = Memory.MIN_DURATION) -> void:
	level = explored_level
	cell = level.entrance_cell
	memory = Memory.new(memory_duration)
	_feel(cell)


## Walk one cell. A wall simply stops her; bumping into it still counts as
## a turn for her memory.
func step(direction: Vector2i) -> ActionResult:
	memory.advance_turn()
	var target: Vector2i = cell + direction
	if not level.is_walkable(target):
		return _result(ActionResult.Action.STEP, ActionResult.Outcome.BLOCKED, direction, target, cell)
	return _move_to(ActionResult.Action.STEP, ActionResult.Outcome.MOVED, direction, target)


## Feel the neighbouring cell without moving. Costs no memory: only moving
## or trying to move makes her forget.
func probe(direction: Vector2i) -> ActionResult:
	return _result(ActionResult.Action.PROBE, ActionResult.Outcome.SENSED, direction, cell + direction, cell)


## Stomp towards the neighbouring cell without moving. Costs no memory.
func stomp(direction: Vector2i) -> ActionResult:
	return _result(ActionResult.Action.STOMP, ActionResult.Outcome.SENSED, direction, cell + direction, cell)


## Jump over one cell. She does not know what is there: a wall right ahead
## stops the jump, a wall two cells ahead cuts it short. The cell she flies
## over is not touched, so it is not remembered.
func jump(direction: Vector2i) -> ActionResult:
	memory.advance_turn()
	var near: Vector2i = cell + direction
	var far: Vector2i = cell + direction * 2
	if not level.is_walkable(near):
		return _result(ActionResult.Action.JUMP, ActionResult.Outcome.BLOCKED, direction, near, cell)
	if not level.is_walkable(far):
		_feel(far)
		return _move_to(ActionResult.Action.JUMP, ActionResult.Outcome.CUT_SHORT, direction, near)
	return _move_to(ActionResult.Action.JUMP, ActionResult.Outcome.MOVED, direction, far)


func is_at_exit() -> bool:
	return cell == level.exit_cell


func _feel(felt: Vector2i) -> void:
	if level.is_inside(felt):
		memory.remember(felt, level.get_cell(felt))


func _move_to(
		action: ActionResult.Action,
		outcome: ActionResult.Outcome,
		direction: Vector2i,
		target: Vector2i,
) -> ActionResult:
	var from: Vector2i = cell
	cell = target
	return _result(action, outcome, direction, target, from)


## Builds the result and remembers what the action touched: the cell it is
## about and the cell she stands on now. The cell she left is not felt again,
## so it ages together with everything she felt while standing on it.
func _result(
		action: ActionResult.Action,
		outcome: ActionResult.Outcome,
		direction: Vector2i,
		about: Vector2i,
		from: Vector2i,
) -> ActionResult:
	_feel(about)
	_feel(cell)
	return ActionResult.new(action, outcome, direction, level.get_cell(about), from, cell)
