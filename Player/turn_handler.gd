extends Node
class_name TurnHandler

@export var turn_label: Label

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
	else:
		turn_tracker = turn_tracker + 1

	if turn_tracker == 2:
	# mino is up
		take_mino_turn()
	
	#printt(movesLeft["player_move"],movesLeft["player_action"],movesLeft["mino_move"],movesLeft["mino_action"])
	
	update_turn_tracker()

func update_turn_tracker() -> void:
	var tt_text = ""
	if turn_tracker < 2:
		tt_text += "Player"
		if movesLeft["player_move"]:
			tt_text += " move "
		if movesLeft["player_action"]:
			tt_text += " action "
	else:
		tt_text += "Minotaur is moving..." 
	
	turn_label.text = tt_text

func player_can_move() -> bool: 
	return turn_tracker < 2

func player_has_action_left() -> bool:
	return turn_tracker < 2 and movesLeft["player_action"]
	
func player_take_move() -> void:

	if !movesLeft["player_move"] and movesLeft["player_action"]:
		print("Player moves as action")
		movesLeft["player_action"] = false
	else:
		print("Player moves")
		movesLeft["player_move"] = false
	next()
	
func player_take_action() -> void:
	next()
	movesLeft["player_action"] = false
	
func mino_move() -> void:
	if !movesLeft["mino_move"] and movesLeft["mino_action"]:
		print("Mino moves as action")
		movesLeft["mino_action"] = false
	else:
		print("Mino moves")
		movesLeft["mino_move"] = false
	next()

func mino_action() -> void:
	pass

func mino_legedary() -> void:
	pass
	
func take_mino_turn() -> void:
	await get_tree().create_timer(1.0).timeout
	mino_move()
	await get_tree().create_timer(1.0).timeout
	mino_move()
