extends RefCounted

class_name MazeEntranceExit

func create_entrance_and_exit() -> void:
	var maze = MazeArray.get_maze_array()
	var width = MazeConstants.WIDTH
	var height = MazeConstants.HEIGHT
	var entrance_pos: Vector2
	var exit_pos: Vector2
	var middle_x = width / 2

	entrance_pos.x = middle_x
	entrance_pos.y = height - 1
	maze[entrance_pos.y][entrance_pos.x] = MazeConstants.PATH
	maze[entrance_pos.y - 1][entrance_pos.x] = MazeConstants.PATH

	exit_pos.x = middle_x
	exit_pos.y = 0
	maze[exit_pos.y][exit_pos.x] = MazeConstants.PATH
	maze[exit_pos.y + 1][exit_pos.x] = MazeConstants.PATH

	MazeArray.set_maze_array(maze)
	MazeConstants.entrance_pos = entrance_pos
	print("entrance_pos = " ,entrance_pos)
	MazeConstants.exit_pos = exit_pos
	print("exit_pos = ", exit_pos)
	MazeConstants.labyrinth_container.queue_redraw()
	
