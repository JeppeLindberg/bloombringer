extends StaticBody3D



func _ready() -> void:
	add_to_group('interactable')


func interact(player):
	player.set_carrying(self)


