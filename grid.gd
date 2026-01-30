extends CSGBox3D
class_name Grid

@export var size_x : int = 10
@export var size_y : int = 10
@export var cell_size: int = 1 # n x n

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
	return (x > 0 and y > 0) or (x < size_x and y < size_y)

func move_player_to(x: int, y: int) -> void:
	if can_player_move_in_cell(x,y):
		player_x = x
		player_y = y
		
