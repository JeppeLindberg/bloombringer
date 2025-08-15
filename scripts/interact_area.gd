extends Area3D

@export var shape: CollisionShape3D

var current_interactable = null


func _process(_delta: float) -> void:
	current_interactable = null
	var nodes = get_nodes_in_shape(shape)

	_sort_distance_target_pos = shape.global_position
	nodes.sort_custom(_sort_distance)
	for node in nodes:
		if node.is_in_group('interactable'):
			current_interactable = node
			break;

var _sort_distance_target_pos
func _sort_distance(a, b):
	if a.global_position.distance_to(_sort_distance_target_pos) < b.global_position.distance_to(_sort_distance_target_pos):
		return true
	return false

func get_nodes_in_shape(shape):
	var shape_query = PhysicsShapeQueryParameters3D.new()
	shape_query.shape = shape.shape
	shape_query.transform = shape.global_transform
	shape_query.collide_with_areas = true
	var collisions = get_world_3d().direct_space_state.intersect_shape(shape_query)

	var nodes = []
	if collisions != null:
		for collision in collisions:
			var node = collision['collider'];
			nodes.append(node)

	return nodes
