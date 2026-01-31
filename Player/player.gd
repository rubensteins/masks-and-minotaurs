extends CharacterBody3D
class_name Player

@export_category("Gameplay Options")
@export var speed : float = 5.0
@export var jump_height : float = 1.0
@export var mouse_sensitivity : float = 0.001
@export var gravity : float = 9.81
@export var fall_multiplier : float = 2.0
@export var max_hp : int = 100

@export_category("Game Feel")
@export var rotate_speed : float = 0.8

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

# facing is an int between 0 and 3: 0 is north, 1 east, 2 south, 3 west

var mouse_motion : Vector2 = Vector2.ZERO
var is_mouse_captured = false
var hp : int = max_hp
var smooth_camera_fov : float
var weapon_camera_fov : float
var is_aiming : bool  = false
var player_is_facing : int
var is_animating : bool

func _ready() -> void:
	player_is_facing = 0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #capture mouse outside of window
	is_mouse_captured = true
	smooth_camera_fov = smooth_camera.fov
	weapon_camera_fov = weapon_camera.fov
	# let's move to our starting position
	position = grid.get_new_player_position(grid.player_x, grid.player_y,0)

func _physics_process(delta: float) -> void:
	var target_y_angle = 90
	
	if Input.is_action_just_pressed("turn_left") and not is_animating:
		var tween = create_tween()
		var target = rotation_degrees.y + 90
		is_animating = true
		# Rotate camera to 90 degrees around Y over 1 second
		tween.finished.connect(func(): is_animating = false)
		tween.tween_property(self, "rotation_degrees:y", target, rotate_speed)\
			 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		player_is_facing = wrapi(player_is_facing - 1, 0, 4)
	
	if Input.is_action_just_pressed("turn_right") and not is_animating:
		var tween = create_tween()
		var target = rotation_degrees.y - 90
		is_animating = true
		# Rotate camera to 90 degrees around Y over 1 second
		tween.finished.connect(func(): is_animating = false)
		tween.tween_property(self, "rotation_degrees:y", target, rotate_speed)\
			 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		player_is_facing = wrapi(player_is_facing + 1, 0, 4)
		
	if Input.is_action_just_pressed("move_forward") and not is_animating:
		move_player_in_direction()
		
	if Input.is_action_just_pressed("move_backward"):
		pass
		
func move_player_in_direction() -> void:
	var target : Vector3
	var target_x : int
	var target_y : int
	match player_is_facing:
		0:
			target_x = grid.player_x
			target_y = grid.player_y + 1
		1: 
			target_x = grid.player_x + 1
			target_y = grid.player_y
		2:
			target_x = grid.player_x
			target_y = grid.player_y - 1
		3: 	
			target_x = grid.player_x - 1
			target_y = grid.player_y
	
	if grid.can_player_move_in_cell(target_x, target_y, player_is_facing):
		target = grid.get_new_player_position(target_x, target_y,player_is_facing)
		var tween = create_tween()	
		is_animating = true	
		#Rotate camera to 90 degrees around Y over 1 second
		tween.finished.connect(func(): is_animating = false)
		tween.tween_property(self, "global_position", target, rotate_speed)\
		 	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)			
		
func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		is_mouse_captured = false
		
func take_damage(damage : int) -> void:
	hp -= damage

func die() -> void:
	game_over_screen.game_over()

func pickup_ammo(type: AmmoHandler.ammo_type, amount: int) -> void:
	ammo_handler.add_ammo(type, amount)
