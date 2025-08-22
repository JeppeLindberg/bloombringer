extends CharacterBody3D

@export var camera: Camera3D
@export var turn_pivot: Node3D
@export var visual: Node3D
@export var animation_player: AnimationPlayer
@export var interact_area: Node3D
@export var carrying: Node3D
@export var stop_carrying_raycast: RayCast3D
@export var balance: Node3D

@onready var entities = get_node('/root/main/world/entities')
@onready var debug = get_node('/root/main/ui/debug')
@onready var main = get_node('/root/main')
@onready var dialog = get_node('/root/main/ui/dialog')

var input_dir = Vector3.ZERO
var forward = Vector3.FORWARD
var left = Vector3.LEFT
var in_control = true

const SPEED = 3.0
const JUMP_VELOCITY = 4.5


func _process(_delta: float) -> void:
	debug.add_text(interact_area.current_interactable)

	_update_tilt()
	_handle_interact()

func _handle_interact():
	if Input.is_action_just_pressed('interact'):
		var interactable = interact_area.current_interactable
		if interactable != null:
			interactable.interact(self)
	if Input.is_action_just_released('interact') and _is_carrying():
		stop_carrying()

func _update_tilt():
	visual.rotation_degrees.z = balance.balance_x * 45.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY
		
	_handle_movement()

	move_and_slide()

func _handle_movement():
	var calculated_speed = SPEED
	if _is_carrying():
		calculated_speed *= 0.5

	if in_control:
		input_dir = Input.get_vector("left", "right", "up", "down")
	else:
		input_dir = Vector3.ZERO

	var direction := ((camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)) * Vector3(1.0, 0.0, 1.0)) .normalized()
	if direction:
		if in_control and (animation_player.current_animation != 'walking'):
			animation_player.play('walking')

		turn_pivot.look_at(global_position + direction)
		forward = direction
		left = direction.rotated(Vector3.UP, deg_to_rad(90.0))
		velocity.x = direction.x * calculated_speed
		velocity.z = direction.z * calculated_speed
	else:
		if in_control and (animation_player.current_animation != 'idle'):
			animation_player.play('idle')

		velocity.x = move_toward(velocity.x, 0, calculated_speed)
		velocity.z = move_toward(velocity.z, 0, calculated_speed)

func _is_carrying():
	return len(carrying.get_children()) > 0

func is_walking():
	return (velocity * Vector3(1.0, 0.0, 1.0)) != Vector3.ZERO

func set_carrying(node):
	set_collision_disabled(node, true)
	node.reparent(carrying)
	node.position = Vector3.ZERO

func stop_carrying():
	for child in carrying.get_children():
		var put_down_point = stop_carrying_raycast.get_collision_point()
		child.reparent(entities)
		child.global_position = put_down_point
		set_collision_disabled(child, false)


func set_collision_disabled(node, disabled):
	for child in node.get_children():
		if child is CollisionShape3D:
			child.disabled = disabled

func trip():
	if animation_player.current_animation != 'get_up':
		in_control = false
		stop_carrying()
		animation_player.play('get_up')

func _on_animation_player_animation_finished(anim_name:StringName) -> void:
	if anim_name == 'get_up':
		in_control = true


func enter_dialog(dialog_array):
	dialog.enter_dialog(dialog_array)
