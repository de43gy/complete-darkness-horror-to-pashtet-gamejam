extends Control
## Test stand for level generators: pick a generator, size and seed and look
## at the result with the whole level revealed.
##
## To add a generator to the list, append it to `generators`.

const MAIN_MENU_SCENE: String = "res://scenes/main_menu/main_menu.tscn"
const MAX_CELL_SIZE: int = 32
const MIN_CELL_SIZE: int = 2

var generators: Array[LevelGenerator] = [
	ClassicMazeGenerator.new(),
]

@onready var generator_option: OptionButton = %GeneratorOption
@onready var width_spin_box: SpinBox = %WidthSpinBox
@onready var height_spin_box: SpinBox = %HeightSpinBox
@onready var seed_spin_box: SpinBox = %SeedSpinBox
@onready var generate_button: Button = %GenerateButton
@onready var random_button: Button = %RandomButton
@onready var grid_check_box: CheckBox = %GridCheckBox
@onready var back_button: Button = %BackButton
@onready var info_label: Label = %InfoLabel
@onready var view_area: Control = %ViewArea
@onready var level_view: LevelView = %LevelView


func _ready() -> void:
	for generator: LevelGenerator in generators:
		generator_option.add_item(generator.get_display_name())
	width_spin_box.min_value = LevelGenerator.MIN_SIZE
	height_spin_box.min_value = LevelGenerator.MIN_SIZE

	generate_button.pressed.connect(_generate)
	random_button.pressed.connect(_generate_random)
	back_button.pressed.connect(_go_back)
	grid_check_box.toggled.connect(_on_grid_toggled)
	view_area.resized.connect(_fit_view)

	level_view.revealed = true
	_generate_random()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		_go_back()
	elif event.is_action_pressed(&"debug_new_level"):
		_generate_random()


func _generate_random() -> void:
	seed_spin_box.value = randi()
	_generate()


func _generate() -> void:
	var generator: LevelGenerator = generators[generator_option.selected]
	var started_at: int = Time.get_ticks_usec()
	var level: Level = generator.generate_from_seed(
			int(width_spin_box.value), int(height_spin_box.value), int(seed_spin_box.value))
	var elapsed_ms: float = (Time.get_ticks_usec() - started_at) / 1000.0

	level_view.level = level
	_fit_view()
	info_label.text = "%d x %d\nвремя: %.2f мс\nпуть до выхода: %s" % [
		level.width, level.height, elapsed_ms, "есть" if level.has_path() else "НЕТ",
	]


## Picks the largest cell size at which the whole level fits on screen.
func _fit_view() -> void:
	var level: Level = level_view.level
	if level == null:
		return
	var fit: float = minf(view_area.size.x / level.width, view_area.size.y / level.height)
	level_view.cell_size = clampi(floori(fit), MIN_CELL_SIZE, MAX_CELL_SIZE)


func _on_grid_toggled(enabled: bool) -> void:
	level_view.show_grid = enabled


func _go_back() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
