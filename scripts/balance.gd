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

var lifetime = 0.0

var is_walking_history = [false, false]
var step_timer = 0.0
var current_weights = []
var last_updated_weights = 0.0


func _process(delta: float) -> void:
	lifetime += delta
	debug.add_draw_circle(global_position, Color.WHITE_SMOKE)
	debug.add_draw_circle(trip_point.global_position, Color.RED * Color(1.0, 1.0, 1.0, 1.0 - _current_balance()))
	debug.add_draw_circle(center_of_mass.global_position, Color.SEA_GREEN)

	_handle_walk_impulse(delta)

	if abs(last_updated_weights - lifetime) > 0.1:
		last_updated_weights = lifetime
		current_weights = main.get_children_in_groups(get_parent(), true, ['weight'])
		var total_weight = 0.0
		var center_of_mass_pos = Vector3.ZERO
		for weight in current_weights:
			total_weight += weight.weight_kg
			center_of_mass_pos += weight.global_position * weight.weight_kg
		center_of_mass_pos /= total_weight
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
	var distance_to_player = global_position.distance_to(player.global_position)
	var recovery = (BASE_RECOVERY + distance_to_player * RECOVERY_PER_DIST_TO_PLAYER)

	global_position = global_position.move_toward(player.global_position, recovery * delta)

func _current_balance():
	var player_to_balance = global_position - player.global_position
	if player_to_balance != Vector3.ZERO:
		trip_point.global_position = player.global_position + player_to_balance.normalized() * IMBALANCE_BEFORE_TRIP
		var player_to_trip = trip_point.global_position - player.global_position
		var balance = (player_to_trip.length() - player_to_balance.length()) / player_to_trip.length()
		return balance
	else:
		return 1.0

func add_impulse(amount = 0.2):
	global_position += Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(randf_range(0.0,360.0))) * amount
