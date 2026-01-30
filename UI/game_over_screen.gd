extends Control

# Called when the node enters the scene tree for the first time.
func game_over() -> void:
	get_tree().paused = true
	visible = true	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
