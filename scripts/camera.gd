extends Camera3D


var target_node: Node3D


func _process(delta: float) -> void:
	global_position = lerp(global_position, target_node.global_position, delta)
