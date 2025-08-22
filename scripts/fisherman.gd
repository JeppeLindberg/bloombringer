extends StaticBody3D




var dialog_array = \
[
	{
		'text': 'Hello there!',
		'talker': self
	},
	{
		'text': 'Great day, innit?',
		'talker': self
	}
]


func _ready() -> void:
	add_to_group('interactable')


func interact(player):
	player.enter_dialog(dialog_array)


