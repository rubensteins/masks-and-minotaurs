extends CharacterBody3D
class_name Player

@export_category("Gameplay Options")
@export var speed : float = 5.0
@export var jump_height : float = 1.0
@export var mouse_sensitivity : float = 0.001
@export var gravity : float = 9.81
@export var fall_multiplier : float = 2.0
@export var max_hp : int = 100

@export_category("Aim Options")
@export var zoom_factor : float = 0.6
@export var zoom_in_speed : float = 20.0
@export var zoom_out_speed : float = 40.0

@onready var game_over_screen: Control = $GameOverScreen
@onready var camera_pivot: Node3D = $CameraPivot
@onready var animation_player: AnimationPlayer = $DamageTexture/AnimationPlayer
@onready var ammo_handler: AmmoHandler = %AmmoHandler

@onready var smooth_camera: Camera3D = %SmoothCamera
@onready var weapon_camera: Camera3D = %WeaponCamera

var mouse_motion : Vector2 = Vector2.ZERO
var is_mouse_captured = false
var hp : int = max_hp
var smooth_camera_fov : float
var weapon_camera_fov : float
var is_aiming : bool  = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #capture mouse outside of window
	is_mouse_captured = true
	smooth_camera_fov = smooth_camera.fov
	weapon_camera_fov = weapon_camera.fov

func _process(delta: float) -> void:
	if Input.is_action_pressed("aim"):
		smooth_camera.fov = lerp(smooth_camera.fov,
			smooth_camera_fov * zoom_factor,
			delta * zoom_in_speed)
		weapon_camera.fov = lerp(weapon_camera.fov,
			weapon_camera_fov * zoom_factor,
			delta * zoom_in_speed)
		is_aiming = true
	else:
		smooth_camera.fov = lerp(smooth_camera.fov,
			smooth_camera_fov,
			delta * zoom_out_speed)
		weapon_camera.fov = lerp(weapon_camera.fov,
			weapon_camera_fov,
			delta * zoom_out_speed)
		is_aiming = false

func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y -= gravity * delta
		else:
			velocity.y -= gravity * delta * fall_multiplier
		
	# Are we running or aiming?
	var run_multiplier = 2.0 if Input.is_key_pressed(Key.KEY_SHIFT) else 1.0
	var aim_multiplier = zoom_factor if is_aiming else 1.0

	if Input.is_action_just_pressed("exit_game"):
		get_tree().quit()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# Hm = Vˆ2 / 2g => v = sqrt(2 * h * g)
		velocity.y = sqrt(2.0 * jump_height * gravity)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed * run_multiplier * aim_multiplier
		velocity.z = direction.z * speed * run_multiplier * aim_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * run_multiplier * aim_multiplier)
		velocity.z = move_toward(velocity.z, 0, speed * run_multiplier * aim_multiplier)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_mouse_captured:
		mouse_motion = -event.relative * mouse_sensitivity \
			* (zoom_factor if is_aiming else 1.0)
		
	if event.is_action("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		is_mouse_captured = false
		
func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x, -90.0, 90.0)
		
	mouse_motion = Vector2.ZERO		

func take_damage(damage : int) -> void:
	hp -= damage

	if(hp <= 0):
		die()
	else:
		# show that we took damage
		animation_player.stop()
		animation_player.play("TakeDamage")

func die() -> void:
	game_over_screen.game_over()

func pickup_ammo(type: AmmoHandler.ammo_type, amount: int) -> void:
	ammo_handler.add_ammo(type, amount)
