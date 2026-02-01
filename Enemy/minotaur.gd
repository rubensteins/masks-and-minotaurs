extends Node3D

@onready var grid: Grid = $"../Grid"
@onready var sprite_3d: Sprite3D = $Sprite3D

@onready var moo_audio: AudioStreamPlayer3D = $Moo
@onready var footsteps_audio: AudioStreamPlayer3D = $Footsteps

var do_legendary : bool = false


func _ready() -> void:
	TurnHandler.mino_turn.connect(take_turn)
	position = grid.get_new_mino_position(9, 9, 0)
	TurnHandler.legendary_mino.connect(enable_legendary_action)

func enable_legendary_action() -> void:
	do_legendary = true
	if not moo_audio.playing:
		moo_audio.play()

func _process(_delta: float) -> void:
	if TurnHandler.current_mask != 0:
		sprite_3d.transparency = 1.0
	else:
		sprite_3d.transparency = 0.0

func take_turn() -> void:
	# normally, we do 2 moves, if we're legendary, we do 5!!!
	footsteps_audio.play()
	var moves = 2
	var wait_time = 0.7
	if do_legendary:
		moves = 5
		wait_time = 0.2
		do_legendary = false
		TurnHandler.legendary_count = 0
	
	for i in range(moves):	
		await get_tree().create_timer(wait_time).timeout		
		best_move()
		TurnHandler.mino_move()
		grid.mino_and_player_collide()
	
	await get_tree().create_timer(wait_time).timeout	
	footsteps_audio.stop()

func best_move() -> void:
	var mino_x = grid.mino_x
	var mino_y = grid.mino_y
	
	var canGoNorth = grid.can_player_move_in_cell(mino_x, mino_y + 1, 0)
	var canGoEast = grid.can_player_move_in_cell(mino_x + 1, mino_y, 1)
	var canGoSouth = grid.can_player_move_in_cell(mino_x, mino_y - 1, 2)
	var canGoWest = grid.can_player_move_in_cell(mino_x - 1, mino_y, 3)
	
	var shortest_distance = 1000
	var best_facing = 0
	var target_x = mino_x
	var target_y = mino_y
	
	if canGoNorth:
		var distance = Vector2(mino_x, mino_y + 1).distance_to(
			Vector2(grid.player_x, grid.player_y))
		if (distance < shortest_distance):
			shortest_distance = distance
			best_facing = 0
			target_x = mino_x
			target_y = mino_y + 1
		
	if canGoEast:
		var distance = Vector2(mino_x + 1, mino_y).distance_to(
			Vector2(grid.player_x, grid.player_y))
		if (distance < shortest_distance):
			shortest_distance = distance
			best_facing = 1
			target_x = mino_x + 1
			target_y = mino_y
	
	if canGoSouth:
		var distance = Vector2(mino_x, mino_y - 1).distance_to(
			Vector2(grid.player_x, grid.player_y))
		if (distance < shortest_distance):
			shortest_distance = distance
			best_facing = 2
			target_x = mino_x
			target_y = mino_y - 1
	
	if canGoWest:
		var distance = Vector2(mino_x - 1, mino_y).distance_to(
			Vector2(grid.player_x, grid.player_y))
		if (distance < shortest_distance):
			shortest_distance = distance
			best_facing = 3
			target_x = mino_x - 1
			target_y = mino_y
	
	global_position = grid.get_new_mino_position(target_x, target_y, best_facing)
