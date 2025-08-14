extends CharacterBody3D

@export var camera: Camera3D

@export var visuals: Node3D
@export var animation_player: AnimationPlayer


const SPEED = 3.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := ((camera.basis * Vector3(input_dir.x, 0, input_dir.y)) * Vector3(1.0, 0.0, 1.0)) .normalized()
	if direction:
		if animation_player.current_animation != 'walking':
			animation_player.play('walking')

		visuals.look_at(global_position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation != 'idle':
			animation_player.play('idle')

		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
