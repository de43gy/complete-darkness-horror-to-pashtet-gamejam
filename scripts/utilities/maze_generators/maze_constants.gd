extends Node
#MazeConstants

const WIDTH = 20
const HEIGHT = 15
const CELL_SIZE = 32
const TIMEOUT = 1000

const WALL = 1
const PATH = 0
const TRAP = 2
const MONSTER = 3
const TREASURE = 4

var labyrinth_container: LabyrinthContainer = null

var entrance_pos: Vector2 = Vector2(-1, -1)
var exit_pos: Vector2 = Vector2(-1, -1)

signal message_log_set(log)
var message_log: Control = null

func set_message_log(log):
	message_log = log
	emit_signal("message_log_set", log)
