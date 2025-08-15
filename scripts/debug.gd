extends Control


var draw_lines = []
var draw_text = []

@export var debug_text: Label



func _process(_delta: float) -> void:
	queue_redraw()

	debug_text.text = ''
	for text in draw_text:
		if text is float:
			debug_text.text += str(round_to_dec(text, 1)) + '\n'
		else:
			debug_text.text += str(text) + '\n'
	draw_text = []

func _draw() -> void:
	for line in draw_lines:
		draw_line(line[0], line[1], Color.WHITE_SMOKE)
	
	draw_lines = []

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


	