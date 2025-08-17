extends Node3D

@export var player: Node3D
@export var trip_point: Node3D
@export var center_of_mass: Node3D

@onready var debug = get_node('/root/main/ui/debug')
@onready var main = get_node('/root/main')

const BASE_RECOVERY = 2.5
const RECOVERY_PER_DIST_TO_PLAYER = 2.0
const IMBALANCE_BEFORE_TRIP = 1.0
const STEP_FREQUENCY_SECS = 0.4
const RECOVERY_SLOWDOWN_PER_KG = 1.0/60.0

var lifetime = 0.0

var is_walking_history = [false, false]
var step_timer = 0.0
var current_weights = []
var last_updated_weights = 0.0
var total_weight_kg = 0.0

var debug_draw_point = Vector3.ZERO


func _process(delta: float) -> void:
	lifetime += delta
	debug.add_draw_circle(global_position, Color.WHITE_SMOKE)
	debug.add_draw_circle(trip_point.global_position, Color.RED * Color(1.0, 1.0, 1.0, 1.0 - _current_balance()))
	debug.add_draw_circle(center_of_mass.global_position, Color.SEA_GREEN)
	if debug_draw_point != Vector3.ZERO:
		debug.add_draw_circle(debug_draw_point, Color.BLACK)

	_handle_walk_impulse(delta)
	_handle_update_center_of_mass()

func _handle_update_center_of_mass():
	if abs(last_updated_weights - lifetime) > 0.1:
		last_updated_weights = lifetime
		current_weights = main.get_children_in_groups(get_parent(), true, ['weight'])
		total_weight_kg = 0.0
		var center_of_mass_pos = Vector3.ZERO
		for weight in current_weights:
			total_weight_kg += weight.weight_kg
			center_of_mass_pos += weight.global_position * weight.weight_kg
		center_of_mass_pos /= total_weight_kg
		center_of_mass.global_position = center_of_mass_pos

func _handle_walk_impulse(delta):
	is_walking_history.append(player.is_walking())
	is_walking_history.pop_front()
	if is_walking_history[1] and not is_walking_history[0]:
		step_timer = 0.0
	if is_walking_history[1]:
		step_timer += delta
		if step_timer >= STEP_FREQUENCY_SECS:
			add_impulse()
			step_timer -= STEP_FREQUENCY_SECS

func _physics_process(delta: float) -> void:
	_update_position(delta)

func _update_position(delta):
	var distance_to_player = global_position.distance_to(_center_of_mass_by_ground())
	var recovery = Vector2.ONE * (BASE_RECOVERY + distance_to_player * RECOVERY_PER_DIST_TO_PLAYER) * max(2.0 - sqrt(total_weight_kg * RECOVERY_SLOWDOWN_PER_KG), 0.1)
	recovery *= Vector2(1.0, 0.1)
		
	var move_toward_point = _closest_pos_on_line(global_position, player.forward, _center_of_mass_by_ground())
	global_position = global_position.move_toward(move_toward_point , recovery.x * delta)
	move_toward_point = _closest_pos_on_line(global_position, player.forward.rotated(Vector3.UP, deg_to_rad(90.0)), _center_of_mass_by_ground())
	global_position = global_position.move_toward(move_toward_point , recovery.y * delta)

func _current_balance():
	var com_to_balance = global_position - _center_of_mass_by_ground()
	if com_to_balance != Vector3.ZERO:
		trip_point.global_position = _center_of_mass_by_ground() + (com_to_balance.normalized() * IMBALANCE_BEFORE_TRIP) / (total_weight_kg * RECOVERY_SLOWDOWN_PER_KG)
		var com_to_trip = trip_point.global_position - _center_of_mass_by_ground()
		var balance = (com_to_trip.length() - com_to_balance.length()) / com_to_trip.length()
		return balance
	else:
		return 1.0

func add_impulse(amount = 0.1):
	global_position += Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(randf_range(0.0,360.0))) * amount * sqrt(total_weight_kg * RECOVERY_SLOWDOWN_PER_KG)

func _center_of_mass_by_ground():
	return Vector3(center_of_mass.global_position.x, global_position.y, center_of_mass.global_position.z)

func _closest_pos_on_line(source_pos, direction, dest_pos):    
	var diff = (dest_pos - source_pos).dot(direction) / direction.dot(direction)
	var closest_pos = source_pos + diff * direction
	return closest_pos
