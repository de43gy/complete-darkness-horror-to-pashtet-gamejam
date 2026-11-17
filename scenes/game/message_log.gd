class_name MessageLog
extends RichTextLabel
## The text log: newest message on top, older ones fade out.
##
## Font, size and spacing are set in message_log.tscn.

const MAX_LINES: int = 6
const OPACITY_STEP: float = 0.2

var _messages: Array[String] = []


func log_message(message: String) -> void:
	if message.is_empty():
		return
	_messages.push_front(message.to_upper())
	if _messages.size() > MAX_LINES:
		_messages.resize(MAX_LINES)
	_update_display()


func clear_messages() -> void:
	_messages.clear()
	_update_display()


func get_messages() -> Array[String]:
	return _messages.duplicate()


func _update_display() -> void:
	clear()
	for i: int in range(_messages.size()):
		var color: Color = Color(1, 1, 1, maxf(1.0 - OPACITY_STEP * i, 0.0))
		push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		push_color(color)
		add_text(_messages[i])
		pop()
		pop()
