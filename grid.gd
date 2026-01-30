extends CSGBox3D

@export var size_x : int = 10
@export var size_y : int = 10
@export var cell_size: int = 1 # n x n

func can_player_move_in_cell(x: int, y: int) -> bool:
	return true
