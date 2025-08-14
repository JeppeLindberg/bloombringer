extends Node3D

@export var camera: Camera3D
@export var follow_node: Node3D


func _process(_delta: float) -> void:
	var areas = get_areas_at_point(follow_node.global_position)
	if areas != []:
		_sort_distance_target_pos = follow_node.global_position
		areas.sort_custom(_sort_distance)
		camera.target_node = areas[0].get_node('camera_marker')

var _sort_distance_target_pos
func _sort_distance(a, b):
	if a.global_position.distance_to(_sort_distance_target_pos) < b.global_position.distance_to(_sort_distance_target_pos):
		return true
	return false

func get_areas_at_point(point):
	var space_state = get_world_3d().direct_space_state
	var point_query = PhysicsPointQueryParameters3D.new()
	# point_query.collision_mask = beam_collision_mask
	point_query.position = point
	point_query.collide_with_areas = true
	point_query.collide_with_bodies = false
	var collisions = space_state.intersect_point(point_query)

	var result = []
	if collisions != null:
		for collision in collisions:
			if collision.has('collider'):
				result.append(collision['collider'])

	return result
