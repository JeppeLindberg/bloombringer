extends Control


var draw_lines = []
var draw_texts = []
var draw_circles = []

@export var debug_text: Label



func _process(_delta: float) -> void:
	queue_redraw()

	debug_text.text = ''
	for text in draw_texts:
		if text is float:
			debug_text.text += str(round_to_dec(text, 1)) + '\n'
		else:
			debug_text.text += str(text) + '\n'
	draw_texts = []

func _draw() -> void:
	for line in draw_lines:
		draw_line(line[0], line[1], Color.WHITE_SMOKE)	
	draw_lines = []

	for circle in draw_circles:
		draw_circle(circle['screen_pos'],circle['size'],circle['color'])
	draw_circles = []

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func add_draw_text(text):
	draw_texts.append(text)

func add_draw_circle(world_pos, color = Color.RED):
	draw_circles.append(
		{
			'screen_pos': get_viewport().get_camera_3d().unproject_position(world_pos),
			'size': 3,
			'color': color
		}
	)

	