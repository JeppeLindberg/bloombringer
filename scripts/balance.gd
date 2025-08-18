extends Node3D

@export var player: Node3D
@export var trip_point: Node3D
@export var center_of_mass: Node3D

@onready var debug = get_node('/root/main/ui/debug')
@onready var main = get_node('/root/main')

const BASE_RECOVERY = 3.5
const WORSE_RECOVERY_PER_DIST_TO_PLAYER = 1.2
const IMBALANCE_BEFORE_TRIP = 1.0
const STEP_FREQUENCY_SECS = 0.4
const RECOVERY_SLOWDOWN_PER_KG = 1.0/60.0

var balance = 1.0
var balance_x = 0.0

var lifetime = 0.0

var is_walking_history = [false, false]
var step_timer = 0.0
var current_weights = []
var total_weight_kg = 0.0

var debug_draw_point = Vector3.ZERO


func _ready() -> void:
	global_position = player.global_position
	trip_point.global_position = player.global_position

func _process(delta: float) -> void:
	lifetime += delta

	_handle_walk_impulse(delta)
	_update_trip_point_position()
	_check_trip()

	debug.add_draw_circle(global_position, Color.WHITE_SMOKE)
	debug.add_draw_circle(trip_point.global_position, Color.RED * Color(1.0, 1.0, 1.0, 1.0 - balance))
	debug.add_draw_circle(center_of_mass.global_position, Color.SEA_GREEN)
	if debug_draw_point != Vector3.ZERO:
		debug.add_draw_circle(debug_draw_point, Color.BLACK)

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

func _check_trip():
	if balance <= 0.0:
		player.trip()

func _physics_process(delta: float) -> void:
	_handle_update_center_of_mass(delta)
	_update_balance_position(delta)

func _handle_update_center_of_mass(delta):
	current_weights = main.get_children_in_groups(get_parent(), true, ['weight'])
	total_weight_kg = 0.0
	var center_of_mass_pos = Vector3.ZERO
	for weight in current_weights:
		total_weight_kg += weight.weight_kg
		center_of_mass_pos += weight.global_position * weight.weight_kg
	center_of_mass_pos /= total_weight_kg
	center_of_mass.global_position = center_of_mass.global_position.move_toward(center_of_mass_pos, delta)

func _update_balance_position(delta):
	global_position.y = player.global_position.y
	var distance_to_com = global_position.distance_to(_center_of_mass_by_ground())
	var recovery_mult_calculated = (BASE_RECOVERY - pow(distance_to_com * WORSE_RECOVERY_PER_DIST_TO_PLAYER, 2.0)) * max(2.0 - sqrt(total_weight_kg * RECOVERY_SLOWDOWN_PER_KG), 0.1)
	if not player.in_control:
		recovery_mult_calculated = max(1.0, recovery_mult_calculated)
	var recovery_vec = Vector2(1.0, 0.1) * recovery_mult_calculated	
		
	var move_toward_point = main.closest_pos_on_line(global_position, player.forward, _center_of_mass_by_ground())
	global_position = global_position.move_toward(move_toward_point , recovery_vec.x * delta)
	move_toward_point = main.closest_pos_on_line(global_position, player.forward.rotated(Vector3.UP, deg_to_rad(90.0)), _center_of_mass_by_ground())
	global_position = global_position.move_toward(move_toward_point , recovery_vec.y * delta)

func _update_trip_point_position():
	var com_to_balance = global_position - _center_of_mass_by_ground()
	if com_to_balance != Vector3.ZERO:
		var calc_imbalance_before_trip = IMBALANCE_BEFORE_TRIP / (total_weight_kg * RECOVERY_SLOWDOWN_PER_KG)
		trip_point.global_position = _center_of_mass_by_ground() + com_to_balance.normalized() * calc_imbalance_before_trip
		var com_to_trip = trip_point.global_position - _center_of_mass_by_ground()
		balance = (com_to_trip.length() - com_to_balance.length()) / com_to_trip.length()

		var com_to_x_balance = main.closest_pos_on_line(Vector3.ZERO, player.left, com_to_balance)
		balance_x = com_to_x_balance.length() * sign(com_to_x_balance.dot(player.left)) / calc_imbalance_before_trip
	else:
		balance = 1.0
		balance_x = 0.0

func add_impulse(amount = 0.1):
	global_position += Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(randf_range(0.0,360.0))) * amount * sqrt(total_weight_kg * RECOVERY_SLOWDOWN_PER_KG)

func _center_of_mass_by_ground():
	return Vector3(center_of_mass.global_position.x, global_position.y, center_of_mass.global_position.z)
