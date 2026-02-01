extends CSGBox3D
class_name Grid

@export_category("Grid Setup")
@export var grid_size : int = 10 # always square
@export var tiles : Array[PackedScene]

@export_category("Player")
@export var starting_x : int = 0
@export var starting_y : int = 0
@export var player_height : float = 3.0

@export_category("Minotaur")
@export var mino_starting_x : int = 9
@export var mino_starting_y : int = 9
@export var mino_height : float = 2.0

@export_category("Props")
@export var phylactery : PackedScene
@export var trap : PackedScene

signal player_enemy_collission
signal player_in_trap
signal reached_end

var cell_size : float
var cell_array : Array[Array]
var traps_array : Array[Array]

func _ready() -> void:
	cell_size = size.x * 1.0 / grid_size
	cell_array = [
		[10,6,6,6,6,6,6,6,6,8],
		[4,6,6,6,8,10,6,6,8,9],
		[9,14,6,8,9,4,6,12,9,9],
		[4,6,8,9,9,9,14,3,5,9],
		[9,13,11,9,11,9,13,11,13,9],
		[9,4,6,1,3,5,4,6,1,2],
		[9,7,6,8,7,8,9,14,8,9],
		[4,6,8,7,8,9,9,13,7,2],
		[9,15,4,6,5,9,7,1,12,9],
		[7,6,1,6,6,1,6,6,6,5],
	]
	traps_array = [
		[0,0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,5,0,0],
		[0,0,0,1,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,1,0,0,0],
		[0,0,0,0,0,0,0,0,0,0],
		[0,1,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,1,0,0,0],
	] # 1=pit, 2=secret_door, 5=prize

	for y in 10:
		for x in 10:
			place_tile(x, y, cell_array[y][x])
	
func place_tile(x: int, y: int, type: int) -> void:
	# find coordinates of cell
	# place packedscene at location
	if type < 0 or type > (tiles.size() - 1):
		type = 0

	var scene = tiles[type].instantiate()
	add_child(scene)
	if scene is CellMesh:
		var loc = get_center_point_for_cell(x,y)
		if traps_array[y][x] == 5:
			# place phylactery here
			var phyl = phylactery.instantiate()
			add_child(phyl)
			phyl.global_position = get_center_point_for_cell(x,y)
		
		if traps_array[y][x] == 1:
			var t = trap.instantiate()
			add_child(t)
			t.global_position = get_center_point_for_cell(x,y)
		
		scene.place_at(loc)
		# printt("Place: ", x,y,type, loc)	
	
var player_x : int :
	get: 
		return player_x 
	set(value):
		player_x = value
		
var player_y : int :
	get: 
		return player_y 
	set(value):
		player_y = value

var mino_x : int :
	get: 
		return mino_x 
	set(value):
		mino_x = value
		
var mino_y : int :
	get: 
		return mino_y 
	set(value):
		mino_y = value

func can_player_move_in_cell(x: int, y: int, facing: int) -> bool:
	var in_bounds = x >= 0 and y >= 0 and x < grid_size and y < grid_size
	if in_bounds:
		var ct = cell_array[y][x]
		match ct:
			0:
				return true
			1:
				return facing != 2
			2: 
				return facing != 3
			3: 
				return facing != 0
			4: 
				return facing != 1
			5: 
				return facing != 2 and facing != 3
			6: 
				return facing != 2 and facing != 0
			7: 
				return facing != 1 and facing != 2
			8: 
				return facing != 3 and facing != 0
			9: 
				return facing != 1 and facing != 3
			10: 
				return facing != 0 and facing != 1
			11:
				return facing == 0
			12:
				return facing == 1
			13: 
				return facing == 2
			14: 
				return facing == 3
			15:
				return false
			_:
				return true
	else:
		return false

func get_new_player_position(x: int, y: int, facing: int) -> Vector3:
	if can_player_move_in_cell(x,y,facing):
		player_x = x
		player_y = y
		return get_center_point_for_cell(x,y)
	else:
		return get_center_point_for_cell(player_x, player_y)
		
func get_new_mino_position(x: int, y: int, facing: int) -> Vector3:
	if can_player_move_in_cell(x,y,facing):
		mino_x = x
		mino_y = y
		return get_center_point_for_cell(x,y)
	else:
		return get_center_point_for_cell(mino_x, mino_y)

func special_things_in_tile(x: int, y: int) -> int:
	return traps_array[y][x]

func get_center_point_for_cell(x: int, y: int) -> Vector3:
	var min_x = -(size.x / 2.0)
	var min_y = (size.z / 2.0)
	var x_to_add = x * cell_size + 0.5 * cell_size
	var y_to_add = y * cell_size + 0.5 * cell_size
	var total_x = min_x + x_to_add
	var total_y = min_y - y_to_add
	return Vector3(total_x, player_height, total_y)

func get_corner_point_for_cell(x: int, y: int) -> Vector3:
	var min_x = -(size.x / 2.0)
	var min_y = (size.z / 2.0)
	var x_to_add = x * cell_size * cell_size
	var y_to_add = y * cell_size * cell_size
	var total_x = min_x + x_to_add
	var total_y = min_y - y_to_add
	return Vector3(total_x, player_height, total_y)

func mino_and_player_collide():
	if mino_x == player_x and mino_y == player_y:
		player_enemy_collission.emit()
