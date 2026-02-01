extends Control

@export var StartScene : PackedScene

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(StartScene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mask_1"):
		_on_restart_button_pressed()
	if Input.is_action_just_pressed("quit"):
		_on_quit_button_pressed()
