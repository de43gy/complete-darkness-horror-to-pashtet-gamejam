extends CharacterBody2D

class_name PlayerScene

enum CellContent { WALL, EMPTY, ENTRANCE, EXIT }

#var maze_generator

func _ready():
	#maze_generator = get_parent()
	pass

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
		try_move(direction)

func try_move(direction):
	var target_pos = position + direction * MazeConstants.CELL_SIZE
	var cell_content = get_cell_content(target_pos)
	
	match cell_content:
		CellContent.WALL:
			print("Там стена, я не могу туда пойти.")
		CellContent.EMPTY:
			position = target_pos
			print("Кажется там пусто, я аккуратно шагаю " + get_direction_name(direction) + ".")
		CellContent.ENTRANCE:
			position = target_pos
			print("Я чувствую начало ступенек вниз под ногами, кажется это спуск вниз.")
		CellContent.EXIT:
			position = target_pos
			print("Это ступеньки вверх, я от туда пришла. Я заблудилась?")

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
