extends CSGBox3D
class_name Grid

@export var grid_size : int = 10 # always square
@export var starting_x : int = 0
@export var starting_y : int = 0
@export var tiles : Array[PackedScene]

var cell_size : float
var cell_array : Array[Array]

func _ready() -> void:
	cell_size = size.x * 1.0 / grid_size
	cell_array = [
		[10,3,3,3,3,3,3,3,3,8],
		[4,15,0,0,0,0,0,0,0,2],
		[4,0,0,0,0,0,0,0,0,2],
		[4,0,0,0,0,0,0,0,0,2],
		[4,0,0,0,0,0,0,0,0,2],
		[4,0,0,0,0,0,0,0,0,2],
		[4,0,0,0,0,0,0,0,0,2],
		[4,0,0,0,0,0,0,0,0,2],
		[4,0,0,0,0,0,0,0,0,2],
		[7,1,1,1,1,1,1,1,1,5],
	]
	place_tile(0,0,0)
	
func place_tile(x: int, y: int, type: int) -> void:
	# find coordinates of cell
	# place packedscene at location
	if type == 0:
		var scene = tiles[1]	.instantiate()
		add_child(scene)
		scene.place_at(Vector3(5,0,5))
		#scene.global_position = 	
		

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
				return facing != 3 and facing != 2
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

func get_center_point_for_cell(x: int, y: int) -> Vector3:
	var min_x = -(size.x / 2.0)
	var min_y = (size.z / 2.0)
	var x_to_add = x * cell_size + 0.5 * cell_size
	var y_to_add = y * cell_size + 0.5 * cell_size
	var total_x = min_x + x_to_add
	var total_y = min_y - y_to_add
	return Vector3(total_x, 0, total_y)
	
