extends StaticBody3D


@export var player: Node3D


func _ready() -> void:
	add_to_group('interactable')


func interact():
	player.set_carrying(self)


