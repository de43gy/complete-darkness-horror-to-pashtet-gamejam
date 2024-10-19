extends ColorRect

@export var labyrinth_width: int = 20
@export var labyrinth_height: int = 15
@export var cell_size: int = 32

@onready var labyrinth = get_parent()

#drawing a grid to make the cells visible, useful for debugging
@export var show_grid: bool = false

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
	if not labyrinth or not labyrinth.maze:
		return
	
	# drawing maze cells
	for y in range(labyrinth_height):
		for x in range(labyrinth_width):
			var rect = Rect2(Vector2(x * cell_size, y * cell_size), Vector2(cell_size, cell_size))
			var color = Color.BLACK if labyrinth.maze[y][x] == labyrinth.WALL else Color.WHITE
			draw_rect(rect, color)
	
	# drawing the entrance and exit
	if labyrinth.entrance_pos:
		draw_rect(Rect2(labyrinth.entrance_pos * cell_size, Vector2(cell_size, cell_size)), Color.GREEN)
	if labyrinth.exit_pos:
		draw_rect(Rect2(labyrinth.exit_pos * cell_size, Vector2(cell_size, cell_size)), Color.RED)
	
	#drawing the grid only if debugging is enabled
	if show_grid:
		var line_color = Color.GRAY
		line_color.a = 0.2
		for x in range(labyrinth_width + 1):
			draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, size.y), line_color)
		for y in range(labyrinth_height + 1):
			draw_line(Vector2(0, y * cell_size), Vector2(size.x, y * cell_size), line_color)
