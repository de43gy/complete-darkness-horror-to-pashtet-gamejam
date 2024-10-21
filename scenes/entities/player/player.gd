extends CharacterBody2D

class_name PlayerScene

@onready var animated_sprite = $AnimatedSprite2D

var message_log: MessageLog

enum CellContent { WALL, EMPTY, ENTRANCE, EXIT }

func _ready():
	var game_elements = get_tree().get_nodes_in_group("game_elements")
	for elements in game_elements:
		if elements is MessageLog:
			message_log = elements
			print(message_log)

func _on_message_log_set(log):
	message_log = log

func _unhandled_input(event):
	var direction = Vector2.ZERO
	
	if event.is_action_pressed("ui_up"):
		direction = Vector2.UP
	elif event.is_action_pressed("ui_down"):
		direction = Vector2.DOWN
	elif event.is_action_pressed("ui_left"):
		direction = Vector2.LEFT
	elif event.is_action_pressed("ui_right"):
		direction = Vector2.RIGHT
	
	if direction != Vector2.ZERO:
		if Input.is_action_pressed("ui_shift"):
			probe_cell(direction)
			play_animation(direction)
		elif Input.is_action_pressed("ui_ctrl"):
			stomp_cell(direction)
			play_animation(direction)
		elif Input.is_action_pressed("ui_select"):
			jump_cell(direction)
			play_animation(direction)
		else:
			try_move(direction)
			play_animation(direction)

func try_move(direction):
	var target_pos = position + direction * MazeConstants.CELL_SIZE
	var cell_content = get_cell_content(target_pos)
	
	match cell_content:
		CellContent.WALL:
			message_log.log_message("- там стена, я не могу туда пойти.")
		CellContent.EMPTY:
			position = target_pos
			message_log.log_message("- я аккуратно шагаю " + get_direction_name(direction) + ".")
			
			play_animation(direction)
		
		CellContent.ENTRANCE:
			position = target_pos
			message_log.log_message("- это ступеньки вверх, я оттуда пришла.")
		CellContent.EXIT:
			position = target_pos
			message_log.log_message("- ступеньки под ногами, кажется это спуск вниз.")

func probe_cell(direction):
	var target_pos = position + direction * MazeConstants.CELL_SIZE
	var cell_content = get_cell_content(target_pos)

	match cell_content:
		CellContent.WALL:
			message_log.log_message("- на ощупь здесь стена.")
		CellContent.EMPTY:
			message_log.log_message("- здесь свободное пространство.")
		CellContent.ENTRANCE:
			message_log.log_message("- здесь ступеньки вверх.")
		CellContent.EXIT:
			message_log.log_message("- здесь ступеньки вниз.")

func stomp_cell(direction):
	var target_pos = position + direction * MazeConstants.CELL_SIZE
	var cell_content = get_cell_content(target_pos)

	match cell_content:
		CellContent.WALL:
			message_log.log_message("- я пнула стену. Больно!")
		CellContent.EMPTY:
			message_log.log_message("- я топнула ногой. Здесь пусто.")
		CellContent.ENTRANCE, CellContent.EXIT:
			message_log.log_message("- я топнула рядом со ступеньками.")

func jump_cell(direction):
	var target_pos = position + direction * MazeConstants.CELL_SIZE * 2
	var first_cell_content = get_cell_content(position + direction * MazeConstants.CELL_SIZE)
	var target_cell_content = get_cell_content(target_pos)

	if first_cell_content == CellContent.WALL:
		message_log.log_message("- я попробовала прыгнуть, но больно ударилась о стену.")
	elif target_cell_content == CellContent.WALL:
		position += direction * MazeConstants.CELL_SIZE
		message_log.log_message("- я прыгнула, но влетела в стену и осталась на месте.")
	else:
		if target_cell_content == CellContent.EMPTY:
			position = target_pos
			message_log.log_message("- я прыгнула " + get_direction_name(direction) + ", тут пусто.")
		else:
			message_log.log_message("- я прыгнула " + get_direction_name(direction) + " и влетела в стену")

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

func play_animation(_direction: Vector2):
	var direction = _direction
	if direction == Vector2.RIGHT:
		animated_sprite.play("walk_right")
	elif direction == Vector2.LEFT:
		animated_sprite.play("walk_left")
	elif direction == Vector2.UP:
		animated_sprite.play("walk_up")
	elif direction == Vector2.DOWN:
		animated_sprite.play("walk_down")
