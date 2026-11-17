extends Node
## Tests for the game logic in core/ and content/.
##
## Run from the project folder:
##   godot --headless res://tests/run_tests.tscn
## Exit code is 0 when everything passed, 1 otherwise.

var _checks: int = 0
var _failures: int = 0


func _ready() -> void:
	_test_level()
	_test_generator()
	_test_explorer()
	_test_memory()
	_test_messages()
	print("%d checks, %d failed" % [_checks, _failures])
	get_tree().quit(1 if _failures > 0 else 0)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("FAILED: " + description)


func _test_level() -> void:
	var level: Level = Level.from_rows([
		"#####",
		"#S.E#",
		"#####",
	])
	_check(level.width == 5 and level.height == 3, "from_rows sets the size")
	_check(level.entrance_cell == Vector2i(1, 1), "from_rows finds the entrance")
	_check(level.exit_cell == Vector2i(3, 1), "from_rows finds the exit")
	_check(level.get_cell(Vector2i(2, 1)) == Level.Cell.FLOOR, "floor cell is read back")
	_check(level.get_cell(Vector2i(-1, 0)) == Level.Cell.WALL, "outside the grid is a wall (negative)")
	_check(level.get_cell(Vector2i(5, 1)) == Level.Cell.WALL, "outside the grid is a wall (positive)")
	_check(level.has_path(), "connected level has a path")

	var blocked: Level = Level.from_rows(["#####", "#S#E#", "#####"])
	_check(not blocked.has_path(), "level split by a wall has no path")


func _test_generator() -> void:
	var generator: LevelGenerator = ClassicMazeGenerator.new()
	var sizes: Array[Vector2i] = [
		Vector2i(21, 15), Vector2i(5, 5), Vector2i(51, 7), Vector2i(7, 41),
		Vector2i(20, 15), Vector2i(21, 14), Vector2i(1, 1),
	]
	for size: Vector2i in sizes:
		for level_seed: int in range(20):
			var level: Level = generator.generate_from_seed(size.x, size.y, level_seed)
			var label: String = "%dx%d seed %d: " % [size.x, size.y, level_seed]
			_check(level.has_path(), label + "exit is reachable")
			_check(level.entrance_cell.y == level.height - 1, label + "entrance is on the bottom edge")
			_check(level.exit_cell.y == 0, label + "exit is on the top edge")
			_check(_border_is_closed(level), label + "border is walled except entrance and exit")
			_check(_is_tree(level), label + "maze has no loops and no unreachable rooms")

	var first: Level = generator.generate_from_seed(21, 15, 12345)
	var second: Level = generator.generate_from_seed(21, 15, 12345)
	var other: Level = generator.generate_from_seed(21, 15, 54321)
	_check(_same_cells(first, second), "same seed gives the same level")
	_check(not _same_cells(first, other), "different seeds give different levels")
	_check(first.generation_seed == 12345, "level remembers its seed")


func _test_explorer() -> void:
	# x: 0123456
	var level: Level = Level.from_rows([
		"###E###",
		"#.....#",
		"#.#...#",
		"###S###",
	])
	var explorer: Explorer = Explorer.new(level)
	_check(explorer.cell == Vector2i(3, 3), "explorer starts at the entrance")

	var result: ActionResult = explorer.step(Vector2i.LEFT)
	_check(result.outcome == ActionResult.Outcome.BLOCKED and not result.has_moved(), "step into a wall is blocked")

	result = explorer.step(Vector2i.DOWN)
	_check(result.outcome == ActionResult.Outcome.BLOCKED, "step out of the level is blocked")

	result = explorer.probe(Vector2i.UP)
	_check(result.cell == Level.Cell.FLOOR and not result.has_moved(), "probe senses floor without moving")

	result = explorer.stomp(Vector2i.LEFT)
	_check(result.cell == Level.Cell.WALL and not result.has_moved(), "stomp senses a wall without moving")

	result = explorer.jump(Vector2i.LEFT)
	_check(result.outcome == ActionResult.Outcome.BLOCKED and not result.has_moved(), "jump with a wall ahead is blocked")

	result = explorer.jump(Vector2i.UP)
	_check(result.outcome == ActionResult.Outcome.MOVED and explorer.cell == Vector2i(3, 1), "jump moves two cells")

	result = explorer.jump(Vector2i.UP)
	_check(result.outcome == ActionResult.Outcome.CUT_SHORT and explorer.cell == Vector2i(3, 0), "jump into the border lands one cell ahead")
	_check(explorer.is_at_exit(), "explorer knows she is at the exit")

	result = explorer.step(Vector2i.UP)
	_check(result.outcome == ActionResult.Outcome.BLOCKED and explorer.cell == Vector2i(3, 0), "cannot walk out through the exit")

	explorer.cell = Vector2i(3, 2)
	result = explorer.jump(Vector2i.UP)
	_check(result.cell == Level.Cell.EXIT and explorer.is_at_exit(), "jump can land on the exit")

	explorer.cell = Vector2i(1, 1)
	result = explorer.jump(Vector2i.DOWN)
	_check(result.outcome == ActionResult.Outcome.CUT_SHORT and explorer.cell == Vector2i(1, 2), "jump into a wall is cut short")

	result = explorer.step(Vector2i.UP)
	_check(result.outcome == ActionResult.Outcome.MOVED and result.to_cell == Vector2i(1, 1), "step moves one cell")


func _test_memory() -> void:
	# x: 01234567
	var level: Level = Level.from_rows([
		"###E####",
		"#......#",
		"###S####",
	])
	var explorer: Explorer = Explorer.new(level)
	var memory: Memory = explorer.memory
	var start: Vector2i = Vector2i(3, 2)
	_check(memory.knows(start) and memory.get_cells().size() == 1, "at first she knows only the cell under her")

	explorer.probe(Vector2i.LEFT)
	_check(memory.knows(Vector2i(2, 2)) and memory.get_cell(Vector2i(2, 2)) == Level.Cell.WALL, "probed wall is remembered")
	explorer.probe(Vector2i.RIGHT)
	explorer.stomp(Vector2i.RIGHT)
	_check(memory.knows(Vector2i(2, 2)) and memory.knows(Vector2i(4, 2)), "probing and stomping do not make her forget")
	explorer.probe(Vector2i.DOWN)
	_check(not memory.knows(Vector2i(3, 3)), "cells outside the level are not remembered")

	explorer.step(Vector2i.UP)
	_check(not memory.knows(Vector2i(2, 2)), "with duration 1 probed cells are forgotten after a move")
	_check(memory.knows(start) and memory.knows(Vector2i(3, 1)), "after a step she knows the cell she left and the new one")
	_check(memory.get_cells().size() == 2, "and nothing else")

	explorer.probe(Vector2i.LEFT)
	_check(memory.knows(start) and memory.knows(Vector2i(2, 1)), "probing after a step keeps the cell she came from")

	explorer.step(Vector2i.RIGHT)
	_check(not memory.knows(start), "the cell left two moves ago is forgotten")
	_check(memory.knows(Vector2i(3, 1)), "the cell just left is remembered")

	explorer.step(Vector2i.UP)
	_check(explorer.cell == Vector2i(4, 1) and memory.knows(Vector2i(4, 0)), "bumping into a wall remembers the wall")
	_check(not memory.knows(Vector2i(3, 1)), "bumping into a wall counts as a turn: the previous cell is forgotten")

	explorer.jump(Vector2i.RIGHT)
	_check(explorer.cell == Vector2i(6, 1), "jump moved her two cells")
	_check(not memory.knows(Vector2i(5, 1)), "the cell she jumped over is not remembered")
	_check(memory.knows(Vector2i(4, 1)) and memory.knows(Vector2i(6, 1)), "jump remembers take-off and landing cells")

	explorer.cell = Vector2i(5, 1)
	explorer.jump(Vector2i.RIGHT)
	_check(explorer.cell == Vector2i(6, 1) and memory.knows(Vector2i(7, 1)), "a cut short jump remembers the wall she hit")

	var long_memory: Explorer = Explorer.new(level, 3)
	var probed: Vector2i = Vector2i(2, 2)
	long_memory.probe(Vector2i.LEFT)
	_check(is_equal_approx(long_memory.memory.get_strength(probed), 1.0), "fresh memory has full strength")
	long_memory.step(Vector2i.UP)
	long_memory.step(Vector2i.RIGHT)
	long_memory.probe(Vector2i.UP)
	_check(long_memory.memory.knows(probed), "duration 3 keeps a cell for two more moves")
	_check(is_equal_approx(long_memory.memory.get_strength(probed), 1.0 / 3.0), "old memory is weaker")
	long_memory.step(Vector2i.RIGHT)
	_check(not long_memory.memory.knows(probed), "and then it is forgotten")
	_check(Memory.new(0).duration == 1, "duration cannot go below 1")


func _test_messages() -> void:
	var here: Vector2i = Vector2i.ZERO
	for action: ActionResult.Action in ActionResult.Action.values():
		for outcome: ActionResult.Outcome in ActionResult.Outcome.values():
			for cell: Level.Cell in Level.Cell.values():
				if not _is_possible(action, outcome, cell):
					continue
				var result: ActionResult = ActionResult.new(action, outcome, Vector2i.UP, cell, here, here)
				_check(Messages.TEXTS.has(Messages.key_for(result)), "there is a text for '%s'" % Messages.key_for(result))

	var step: ActionResult = ActionResult.new(
			ActionResult.Action.STEP, ActionResult.Outcome.MOVED, Vector2i.LEFT, Level.Cell.FLOOR, here, here)
	_check(Messages.describe(step).contains("влево"), "direction name is put into the text")


func _is_possible(action: ActionResult.Action, outcome: ActionResult.Outcome, cell: Level.Cell) -> bool:
	var senses: bool = action == ActionResult.Action.PROBE or action == ActionResult.Action.STOMP
	match outcome:
		ActionResult.Outcome.SENSED:
			return senses
		ActionResult.Outcome.BLOCKED:
			return not senses and cell == Level.Cell.WALL
		ActionResult.Outcome.CUT_SHORT:
			return action == ActionResult.Action.JUMP and cell != Level.Cell.WALL
	return not senses and cell != Level.Cell.WALL


func _border_is_closed(level: Level) -> bool:
	for y: int in range(level.height):
		for x: int in range(level.width):
			var on_border: bool = x == 0 or y == 0 or x == level.width - 1 or y == level.height - 1
			var cell: Vector2i = Vector2i(x, y)
			if on_border and level.is_walkable(cell) and cell != level.entrance_cell and cell != level.exit_cell:
				return false
	return true


## A perfect maze is a tree: all open cells connected, edges = cells - 1.
func _is_tree(level: Level) -> bool:
	var open_cells: int = 0
	var edges: int = 0
	for y: int in range(level.height):
		for x: int in range(level.width):
			var cell: Vector2i = Vector2i(x, y)
			if not level.is_walkable(cell):
				continue
			open_cells += 1
			if level.is_walkable(cell + Vector2i.RIGHT):
				edges += 1
			if level.is_walkable(cell + Vector2i.DOWN):
				edges += 1
	return edges == open_cells - 1 and level.has_path()


func _same_cells(a: Level, b: Level) -> bool:
	if a.width != b.width or a.height != b.height:
		return false
	for y: int in range(a.height):
		for x: int in range(a.width):
			if a.get_cell(Vector2i(x, y)) != b.get_cell(Vector2i(x, y)):
				return false
	return true
