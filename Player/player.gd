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
@onready var grid: Grid = $"../Grid"

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

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("turn_left"):
		rotate_y(deg_to_rad(90))
	
	if Input.is_action_just_pressed("turn_right"):
		rotate_y(deg_to_rad(-90))
	
	
	
func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		is_mouse_captured = false
		
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
