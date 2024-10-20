extends ColorRect

class_name LabyrinthContainer

@export var labyrinth_width: int = MazeConstants.WIDTH
@export var labyrinth_height: int = MazeConstants.HEIGHT
@export var cell_size: int = MazeConstants.CELL_SIZE

#drawing a grid to make the cells visible, useful for debugging
@export var show_grid: bool = true

func _ready():
	update_size()

func update_size(width: int = -1, height: int = -1, new_cell_size: int = -1):
	if width > 0:
		labyrinth_width = width
	if height > 0:
		labyrinth_height = height
	if new_cell_size > 0:
		cell_size = new_cell_size
	
	custom_minimum_size = Vector2(labyrinth_width * cell_size, labyrinth_height * cell_size)
	size = custom_minimum_size
	queue_redraw()

func _draw():
	var maze = MazeArray.get_maze_array()
	# drawing maze cells
	for y in range(labyrinth_height):
		for x in range(labyrinth_width):
			var rect = Rect2(Vector2(x * cell_size, y * cell_size), Vector2(cell_size, cell_size))
			var color = Color.BLACK if maze[y][x] == MazeConstants.WALL else Color.WHITE
			draw_rect(rect, color)
	
	# drawing the entrance and exit
	if MazeConstants.entrance_pos:
		draw_rect(Rect2(MazeConstants.entrance_pos * cell_size, Vector2(cell_size, cell_size)), Color.GREEN)
	if MazeConstants.exit_pos:
		draw_rect(Rect2(MazeConstants.exit_pos * cell_size, Vector2(cell_size, cell_size)), Color.RED)
	
	#drawing the grid only if debugging is enabled
	if show_grid:
		var line_color = Color.GRAY
		line_color.a = 0.2
		for x in range(labyrinth_width + 1):
			draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, size.y), line_color)
		for y in range(labyrinth_height + 1):
			draw_line(Vector2(0, y * cell_size), Vector2(size.x, y * cell_size), line_color)
