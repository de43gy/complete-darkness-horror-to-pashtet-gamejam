class_name Game
extends Control
## The game scene: turns input into actions, actions into log text and
## sprite movement. Owns the current level.

const MAIN_MENU_SCENE: String = "res://scenes/main_menu/main_menu.tscn"

const DIRECTION_ACTIONS: Dictionary[StringName, Vector2i] = {
	&"move_up": Vector2i.UP,
	&"move_down": Vector2i.DOWN,
	&"move_left": Vector2i.LEFT,
	&"move_right": Vector2i.RIGHT,
}

@export var level_width: int = 21
@export var level_height: int = 13
## How many turns the girl remembers a cell she has touched.
@export_range(1, 50) var memory_duration: int = 1
## Start with the whole level visible (debug). Toggled in game with F1.
@export var reveal_level: bool = false

var generator: LevelGenerator = ClassicMazeGenerator.new()
var level: Level
var explorer: Explorer

@onready var level_view: LevelView = %LevelView
@onready var girl: Girl = %Girl
@onready var message_log: MessageLog = %MessageLog


func _ready() -> void:
	level_view.revealed = reveal_level
	start_level()


## Generates a new level and puts the girl at its entrance.
func start_level(level_seed: int = randi()) -> void:
	level = generator.generate_from_seed(level_width, level_height, level_seed)
	explorer = Explorer.new(level, memory_duration)
	level_view.level = level
	level_view.memory = explorer.memory
	girl.position = level_view.cell_to_position(explorer.cell)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	elif event.is_action_pressed(&"debug_new_level"):
		start_level()
	elif event.is_action_pressed(&"debug_reveal_level"):
		level_view.revealed = not level_view.revealed
	else:
		for action: StringName in DIRECTION_ACTIONS:
			if event.is_action_pressed(action):
				_act(DIRECTION_ACTIONS[action])
				return


func _act(direction: Vector2i) -> void:
	var result: ActionResult
	if Input.is_action_pressed(&"action_probe"):
		result = explorer.probe(direction)
	elif Input.is_action_pressed(&"action_stomp"):
		result = explorer.stomp(direction)
	elif Input.is_action_pressed(&"action_jump"):
		result = explorer.jump(direction)
	else:
		result = explorer.step(direction)

	girl.face(direction)
	girl.position = level_view.cell_to_position(explorer.cell)
	level_view.queue_redraw()
	message_log.log_message(Messages.describe(result))
