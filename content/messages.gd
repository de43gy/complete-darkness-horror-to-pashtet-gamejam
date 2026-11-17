class_name Messages
extends RefCounted
## All log texts of the game, in the girl's own voice.
##
## Each event has a list of variants; one is picked at random, so adding a
## new phrasing is just adding a line. "{dir}" is replaced with the direction.

const DIRECTION_NAMES: Dictionary[Vector2i, String] = {
	Vector2i.UP: "вперед",
	Vector2i.DOWN: "назад",
	Vector2i.LEFT: "влево",
	Vector2i.RIGHT: "вправо",
}

const TEXTS: Dictionary[String, Array] = {
	"step.blocked": ["- там стена, я не могу туда пойти."],
	"step.floor": ["- я аккуратно шагаю {dir}."],
	"step.entrance": ["- это ступеньки вверх, я оттуда пришла."],
	"step.exit": ["- ступеньки под ногами, кажется это спуск вниз."],

	"probe.wall": ["- на ощупь здесь стена."],
	"probe.floor": ["- здесь свободное пространство."],
	"probe.entrance": ["- здесь ступеньки вверх."],
	"probe.exit": ["- здесь ступеньки вниз."],

	"stomp.wall": ["- я пнула стену. Больно!"],
	"stomp.floor": ["- я топнула ногой. Здесь пусто."],
	"stomp.entrance": ["- я топнула рядом со ступеньками."],
	"stomp.exit": ["- я топнула рядом со ступеньками."],

	"jump.blocked": ["- я попробовала прыгнуть, но больно ударилась о стену."],
	"jump.cut_short": ["- я прыгнула, но влетела в стену и упала прямо перед ней."],
	"jump.floor": ["- я прыгнула {dir}, тут пусто."],
	"jump.entrance": ["- я прыгнула {dir} и приземлилась на ступеньки вверх."],
	"jump.exit": ["- я прыгнула {dir} и приземлилась на ступеньки вниз."],
}

const ACTION_KEYS: Dictionary[ActionResult.Action, String] = {
	ActionResult.Action.STEP: "step",
	ActionResult.Action.PROBE: "probe",
	ActionResult.Action.STOMP: "stomp",
	ActionResult.Action.JUMP: "jump",
}

const CELL_KEYS: Dictionary[Level.Cell, String] = {
	Level.Cell.WALL: "wall",
	Level.Cell.FLOOR: "floor",
	Level.Cell.ENTRANCE: "entrance",
	Level.Cell.EXIT: "exit",
}


static func describe(result: ActionResult) -> String:
	var variants: Array = TEXTS.get(key_for(result), [])
	if variants.is_empty():
		push_warning("No text for event '%s'" % key_for(result))
		return ""
	var text: String = variants.pick_random()
	return text.replace("{dir}", DIRECTION_NAMES.get(result.direction, ""))


static func key_for(result: ActionResult) -> String:
	var action_key: String = ACTION_KEYS[result.action]
	match result.outcome:
		ActionResult.Outcome.BLOCKED:
			return action_key + ".blocked"
		ActionResult.Outcome.CUT_SHORT:
			return action_key + ".cut_short"
	return action_key + "." + CELL_KEYS[result.cell]
