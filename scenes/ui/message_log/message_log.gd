extends RichTextLabel

class_name MessageLog

var new_font = preload("res://resources/fonts/Zelda DXTT (BRK) RUS by SubRaiN Regular.ttf")
const MAX_LINES = 6
const BASE_OPACITY = 1.0
const OPACITY_STEP = 0.2
const LINE_SPACING = 2
const FONT_SIZE = 2
var message_queue = []

func _ready():
	clear()
	bbcode_enabled = true
	
	var font_settings = FontVariation.new()
	font_settings.set_base_font(new_font)
	font_settings.set_spacing(TextServer.SPACING_TOP, LINE_SPACING)
	font_settings.set_spacing(TextServer.SPACING_BOTTOM, LINE_SPACING)
	add_theme_font_override("normal_font", font_settings)
	add_theme_font_size_override("normal_font_size", FONT_SIZE)
	
	font_settings = get_theme_default_font_size()
	add_theme_font_size_override("normal_font_size", font_settings + FONT_SIZE)
	
	add_theme_constant_override("line_separation", LINE_SPACING)

func log_message(message: String):
	message_queue.push_front(message.to_upper())
	if message_queue.size() > MAX_LINES:
		message_queue.resize(MAX_LINES)
	
	update_display()

func update_display():
	clear()
	for i in range(message_queue.size()):
		var opacity = BASE_OPACITY - (OPACITY_STEP * i)
		opacity = max(opacity, 0)
		var color = Color(1, 1, 1, opacity)
		
		var bbcode = "[center][color=#%s]%s[/color][/center]" % [color.to_html(true), message_queue[i]]
		append_text(bbcode)
		
		if i < message_queue.size() - 1:
			newline()
