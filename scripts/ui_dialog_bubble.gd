extends Control

var follow_node: Node3D


func _process(_delta: float) -> void:
	update_pos()

func update_pos():
	global_position = get_viewport().get_camera_3d().unproject_position(follow_node.global_position)




