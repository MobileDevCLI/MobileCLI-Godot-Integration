extends CharacterBody3D

# Movement
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.5
const CROUCH_SPEED = 2.5
const ACCELERATION = 10.0
const DECELERATION = 12.0
const JUMP_FORCE = 5.5

# Mouse look
const MOUSE_SENSITIVITY = 0.15
const MAX_LOOK_ANGLE = 85.0

# Crouch
const STAND_HEIGHT = 1.8
const CROUCH_HEIGHT = 1.0
const CROUCH_TRANSITION = 8.0

# Head bob
const BOB_FREQUENCY = 2.4
const BOB_AMPLITUDE = 0.04
var bob_time = 0.0

# State
var is_sprinting = false
var is_crouching = false
var current_speed = WALK_SPEED
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Weapon sway
var sway_offset = Vector2.ZERO
const SWAY_AMOUNT = 0.002
const SWAY_SPEED = 5.0

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var collision = $CollisionShape3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		camera.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-MAX_LOOK_ANGLE), deg_to_rad(MAX_LOOK_ANGLE))
		sway_offset.x = -event.relative.x * SWAY_AMOUNT
		sway_offset.y = -event.relative.y * SWAY_AMOUNT

	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Get input direction
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	input_dir = input_dir.normalized()

	var direction = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Sprint / Crouch
	is_sprinting = Input.is_action_pressed("sprint") and is_on_floor() and not is_crouching
	is_crouching = Input.is_action_pressed("crouch")

	if is_sprinting:
		current_speed = SPRINT_SPEED
	elif is_crouching:
		current_speed = CROUCH_SPEED
	else:
		current_speed = WALK_SPEED

	# Crouch height
	var target_height = CROUCH_HEIGHT if is_crouching else STAND_HEIGHT
	var col_shape = collision.shape as CapsuleShape3D
	col_shape.height = lerp(col_shape.height, target_height, delta * CROUCH_TRANSITION)

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_FORCE

	# Horizontal movement
	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION * delta)
		velocity.z = lerp(velocity.z, 0.0, DECELERATION * delta)

	move_and_slide()

	# Head bob
	if is_on_floor() and direction:
		bob_time += delta * velocity.length()
		var bob_offset = sin(bob_time * BOB_FREQUENCY) * BOB_AMPLITUDE
		var sprint_mult = 1.5 if is_sprinting else 1.0
		camera.position.y = lerp(camera.position.y, bob_offset * sprint_mult, 10.0 * delta)
	else:
		camera.position.y = lerp(camera.position.y, 0.0, 10.0 * delta)

	# Sway decay
	sway_offset = sway_offset.lerp(Vector2.ZERO, SWAY_SPEED * delta)
