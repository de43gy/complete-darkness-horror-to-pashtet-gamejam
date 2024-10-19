extends Control

@onready var rich_text_label = $RichTextLabel

func log_message(message: String):
	rich_text_label.add_text(message + "\n")
