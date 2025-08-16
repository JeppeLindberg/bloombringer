extends Node3D

@export var player: Node3D
@export var trip_point: Node3D

@onready var debug = get_node('/root/main/ui/debug')


const BASE_RECOVERY = 2.5
const RECOVERY_PER_DIST_TO_PLAYER = 2.0
const IMBALANCE_BEFORE_TRIP = 1.0


func _process(delta: float) -> void:
	debug.add_draw_circle(global_position, Color.WHITE_SMOKE)
	var player_to_balance = global_position - player.global_position
	if player_to_balance != Vector3.ZERO:
		trip_point.global_position = player.global_position + player_to_balance.normalized() * IMBALANCE_BEFORE_TRIP
		var player_to_trip = trip_point.global_position - player.global_position
		var alpha = player_to_balance.length() / player_to_trip.length()
		debug.add_draw_circle(trip_point.global_position, Color.RED * Color(1.0, 1.0, 1.0, alpha))
	else:
		trip_point.position = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var distance_to_player = global_position.distance_to(player.global_position)
	var recovery = (BASE_RECOVERY + distance_to_player * RECOVERY_PER_DIST_TO_PLAYER)

	global_position = global_position.move_toward(player.global_position, recovery * delta)
