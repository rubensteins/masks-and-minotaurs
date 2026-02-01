extends Control

@export var StartScene : PackedScene

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(StartScene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
