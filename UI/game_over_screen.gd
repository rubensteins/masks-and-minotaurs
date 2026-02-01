extends Control

@export var game_over_text : String = "GAME OVER!"
@export var game_won_text : String = "YOU WON!"

@export var StartScene : PackedScene

@onready var game_over_label: Label = %GameOverLabel

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mask_1"):
		_on_restart_button_pressed()
	if Input.is_action_just_pressed("quit"):
		_on_quit_button_pressed()

# Called when the node enters the scene tree for the first time.
func game_over(hasWon: bool, message: String) -> void:
	get_tree().paused = true
	if hasWon:
		game_over_label.text = game_won_text if message == "" else message
	else:
		game_over_label.text = game_over_text if message == "" else message
		
	visible = true	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
