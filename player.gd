extends CharacterBody2D

class_name PlayerScene

@onready var animated_sprite = $AnimatedSprite2D

var message_log: Control = null

enum CellContent { WALL, EMPTY, ENTRANCE, EXIT }

func _ready():
	MazeConstants.connect("message_log_set", Callable(self, "_on_message_log_set"))
	if MazeConstants.message_log:
		_on_message_log_set(MazeConstants.message_log)

func _on_message_log_set(log):
	message_log = log
	print("message_log in player = ", message_log)

func _unhandled_input(event):
	
	var direction = Vector2.ZERO
	
	if event.is_action_pressed("ui_up"):
		animated_sprite.play("walk_up")
		direction = Vector2.UP
	elif event.is_action_pressed("ui_down"):
		animated_sprite.play("walk_down")
		direction = Vector2.DOWN
	elif event.is_action_pressed("ui_left"):
		animated_sprite.play("walk_left")
		direction = Vector2.LEFT
	elif event.is_action_pressed("ui_right"):
		animated_sprite.play("walk_right")
		direction = Vector2.RIGHT
	
	if direction != Vector2.ZERO:
		try_move(direction)

func try_move(direction):
	var target_pos = position + direction * MazeConstants.CELL_SIZE
	var cell_content = get_cell_content(target_pos)
	print("message_log in player = " ,message_log)
	
	match cell_content:
		CellContent.WALL:
			message_log.log_message("Там стена, я не могу туда пойти.")
		CellContent.EMPTY:
			position = target_pos
			message_log.log_message("Я аккуратно шагаю " + get_direction_name(direction) + ".")
		CellContent.ENTRANCE:
			position = target_pos
			message_log.log_message("Это ступеньки вверх,  я оттуда пришла.")
		CellContent.EXIT:
			position = target_pos
			message_log.log_message("Ступеньки под ногами, кажется это спуск вниз.")

func get_cell_content(pos):
	var cell_x = int(pos.x / MazeConstants.CELL_SIZE)
	var cell_y = int(pos.y / MazeConstants.CELL_SIZE)
	var maze = MazeArray.get_maze_array()
	
	if cell_x < 0 or cell_x >= MazeConstants.WIDTH or cell_y < 0 or cell_y >= MazeConstants.HEIGHT:
		return CellContent.WALL
	
	if maze[cell_y][cell_x] == MazeConstants.WALL:
		return CellContent.WALL
	elif Vector2(cell_x, cell_y) == MazeConstants.entrance_pos:
		return CellContent.ENTRANCE
	elif Vector2(cell_x, cell_y) == MazeConstants.exit_pos:
		return CellContent.EXIT
	else:
		return CellContent.EMPTY

func get_direction_name(direction):
	match direction:
		Vector2.UP:
			return "вперед"
		Vector2.DOWN:
			return "назад"
		Vector2.LEFT:
			return "влево"
		Vector2.RIGHT:
			return "вправо"
	return ""
