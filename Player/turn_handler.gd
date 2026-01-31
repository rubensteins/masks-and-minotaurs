extends Node

signal player_turn
signal mino_turn
signal legendary_mino

var legendary_count : int = 0

var turn_tracker : int :
	get:
		return turn_tracker
	set(value):
		turn_tracker = value

var movesLeft = {
	"player_move" : true,
	"player_action" : true,
	"mino_move" : true,
	"mino_action" : true	
}

func next() -> void:
	if turn_tracker == 3:
		movesLeft["player_move"] = true
		movesLeft["player_action"] = true
		movesLeft["mino_move"] = true
		movesLeft["mino_action"] = true
		turn_tracker = 0
		player_turn.emit()
	else:
		turn_tracker = turn_tracker + 1

	if turn_tracker == 2:
		# mino is up
		mino_turn.emit()
		legendary_count += 1

	if legendary_count == 5:
		legendary_mino.emit()
	
func player_can_move() -> bool: 
	return turn_tracker < 2

func player_has_action_left() -> bool:
	return turn_tracker < 2 and movesLeft["player_action"]
	
func player_take_move() -> void:

	if !movesLeft["player_move"] and movesLeft["player_action"]:
		movesLeft["player_action"] = false
	else:
		movesLeft["player_move"] = false
	next()
	
func player_take_action() -> void:
	next()
	movesLeft["player_action"] = false
	
func mino_move() -> void:
	if !movesLeft["mino_move"] and movesLeft["mino_action"]:
		movesLeft["mino_action"] = false
	else:
		movesLeft["mino_move"] = false
	next()

func mino_action() -> void:
	pass

func mino_legedary() -> void:
	pass
	
