extends CharacterBody3D
class_name Player

@export_category("Gameplay Options")
@export var speed : float = 5.0
@export var mouse_sensitivity : float = 0.001
@export var max_hp : int = 100

@export_category("Game Feel")
@export var rotate_speed : float = 0.8

@onready var game_over_screen: Control = $GameOverScreen
@onready var camera_pivot: Node3D = $CameraPivot
@onready var animation_player: AnimationPlayer = $DamageTexture/AnimationPlayer
@onready var turn_label: Label = $HUD/TurnLabel
@onready var mask_label: Label = %MaskLabel
@onready var exit_message: Label = $HUD/ExitMessage

@onready var smooth_camera: Camera3D = %SmoothCamera
@onready var weapon_camera: Camera3D = %MaskCamera
@onready var grid: Grid = $"../Grid"

@onready var hunter_picto: TextureRect = $HUD/VBoxContainer/HBoxContainer/HunterPicto
@onready var ghost_picto: TextureRect = $HUD/VBoxContainer/HBoxContainer/GhostPicto
@onready var oracle_picto: TextureRect = $HUD/VBoxContainer/HBoxContainer/OraclePicto

@onready var mask_handler: Node3D = %MaskHandler

# facing is an int between 0 and 3: 0 is north, 1 east, 2 south, 3 west

var mouse_motion : Vector2 = Vector2.ZERO
var is_mouse_captured = false
var hp : int = max_hp
var smooth_camera_fov : float
var weapon_camera_fov : float
var is_aiming : bool  = false
var player_is_facing : int
var is_animating : bool
var in_player_turn = true :
	set(value):
		in_player_turn = value
		update_turn_label()
	get:
		return in_player_turn

func _ready() -> void:
	player_is_facing = 0
	smooth_camera_fov = smooth_camera.fov
	weapon_camera_fov = weapon_camera.fov
	# let's move to our starting position
	position = grid.get_new_player_position(grid.player_x, grid.player_y,0)
	TurnHandler.turn_tracker = 0
	update_turn_label()
	TurnHandler.player_turn.connect(func(): in_player_turn = true)
	TurnHandler.mino_turn.connect(func(): in_player_turn = false)
	grid.player_enemy_collission.connect(die.bind("Minotaur got you"))
	# grid.player_in_trap.connect(die.bind("Fell into a trap"))
	grid.reached_end.connect(won)
	mask_handler.equip(0)
	update_mask_label(0)

func update_turn_label() -> void:
	var turn_tracker = TurnHandler.turn_tracker
	var tt_text = ""
	if turn_tracker < 2:
		tt_text += "Player"
		if TurnHandler.player_can_move():
			tt_text += " move "
		if TurnHandler.player_has_action_left():
			tt_text += " action "
	else:
		tt_text += "Minotaur is moving..."
	
	turn_label.text = tt_text

func update_mask_label(mask_id: int) -> void:
	var mask_display_text = "Maskless Hero"
	match mask_id:
		0: 
			mask_display_text = "Mask of the Hunder"	
			hunter_picto.modulate.a = 1.0
			oracle_picto.modulate.a = 0.3
			ghost_picto.modulate.a = 0.3		
		1: 
			mask_display_text = "Mask of the Ghostshroud"
			hunter_picto.modulate.a = 0.3
			oracle_picto.modulate.a = 0.3
			ghost_picto.modulate.a = 1.0		
		2: 
			mask_display_text = "Mask of the Oracle"
			hunter_picto.modulate.a = 0.3
			oracle_picto.modulate.a = 1.0
			ghost_picto.modulate.a = 0.3		
	mask_label.text = mask_display_text

func _process(_delta: float) -> void:
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
		
	if Input.is_action_just_pressed("mask_1"):
		if mask_handler.active_mask != 0 and TurnHandler.player_has_action_left():
			mask_handler.equip(0)
			TurnHandler.player_take_action()
			update_turn_label()
			update_mask_label(0)
			
	if Input.is_action_just_pressed("mask_2"):
		if mask_handler.active_mask != 1 and TurnHandler.player_has_action_left():
			mask_handler.equip(1)
			TurnHandler.player_take_action()
			update_turn_label()
			update_mask_label(1)
		
	if Input.is_action_just_pressed("mask_3"):
		if mask_handler.active_mask != 2 and TurnHandler.player_has_action_left():
			mask_handler.equip(2)
			TurnHandler.player_take_action()
			update_turn_label()
			update_mask_label(2)
	
	if in_player_turn and Input.is_action_just_pressed("move_forward") and not is_animating:
		if TurnHandler.player_can_move():
			TurnHandler.player_take_move()
			move_player_in_direction()
			var anything_special = grid.special_things_in_tile(grid.player_x, grid.player_y)
			if anything_special != 0:
				# oops
				if anything_special == 1 and mask_handler.active_mask != 1:
					die("You fell in to a trap")
				
				if anything_special == 5:
					won("You found the phylactory!")
					
			
			update_turn_label()
		
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
	
	grid.mino_and_player_collide()
		
func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel") or event.is_action("quit"):
		get_tree().quit()
		
func take_damage(damage : int) -> void:
	hp -= damage

func won(message: String) -> void:
	game_over_screen.game_over(true, message)

func die(message: String) -> void:
	game_over_screen.game_over(false, message)
