extends CSGBox3D
class_name Grid

@export var grid_size : int = 10 # always square
@export var starting_x : int = 0
@export var starting_y : int = 0
var cell_size : float

func _ready() -> void:
	cell_size = size.x * 1.0 / grid_size

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

func can_player_move_in_cell(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < grid_size and y < grid_size

func get_new_player_position(x: int, y: int) -> Vector3:
	if can_player_move_in_cell(x,y):
		player_x = x
		player_y = y
		return get_center_point_for_cell(x,y)
	return Vector3.ZERO

func get_center_point_for_cell(x: int, y: int) -> Vector3:
	var min_x = -(size.x / 2.0)
	var min_y = (size.z / 2.0)
	var x_to_add = x * cell_size + 0.5 * cell_size
	var y_to_add = y * cell_size + 0.5 * cell_size
	var total_x = min_x + x_to_add
	var total_y = min_y - y_to_add
	return Vector3(total_x, 0, total_y)
	
