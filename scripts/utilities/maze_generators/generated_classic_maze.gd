extends RefCounted

class_name ClassicMazeGenerator

var width: int = MazeConstants.WIDTH
var height: int = MazeConstants.HEIGHT
var maze: Array
var visited: Array
var timeout: int = MazeConstants.TIMEOUT

func generate_classic_maze() -> void:
	print("Classic maze generation started")
	var start_time = Time.get_ticks_msec()
	maze = MazeArray.initialize_maze_array()
	visited = MazeArray.visited
	
	var start_x = 1
	var start_y = 1
	var stack = [[start_x, start_y]]
	visited[start_y][start_x] = true
	maze[start_y][start_x] = MazeConstants.PATH

	while stack.size() > 0:
		if Time.get_ticks_msec() - start_time > timeout:
			print("Classic maze generation timed out. Switching to simple generation.")
			return

		var current = stack[-1]
		var x = current[0]
		var y = current[1]

		var neighbors = []
		for neighbor in [[-2, 0], [2, 0], [0, -2], [0, 2]]:
			var nx = x + neighbor[0]
			var ny = y + neighbor[1]
			if nx > 0 and nx < width - 1 and ny > 0 and ny < height - 1 and not visited[ny][nx]:
				neighbors.append([nx, ny])

		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			var nx = next[0]
			var ny = next[1]

			maze[(y + ny) / 2][(x + nx) / 2] = MazeConstants.PATH

			visited[ny][nx] = true
			maze[ny][nx] = MazeConstants.PATH

			stack.append([nx, ny])
		else:
			stack.pop_back()
	print("Classic maze generation completed in classic_maze.gd, Time = ", Time.get_ticks_msec() - start_time, " ms")
	MazeArray.set_maze_array(maze)
	MazeArray.visited = visited
