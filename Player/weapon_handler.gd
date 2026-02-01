extends Node3D
class_name MaskHandler

@export_category("Masks")
@export var masks : Array[Node3D]
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_first_mask_ever = true

var active_mask : int :
	get:
		return active_mask
		
var is_mask_on : bool = false
	
func equip(new_mask_index : int) -> void:
	if new_mask_index != active_mask or is_first_mask_ever:
		masks[active_mask].visible = false
		masks[new_mask_index].visible = true
		masks[new_mask_index].set_process(true)
		active_mask = new_mask_index
		if new_mask_index == 0:
			animation_player.play("mask_2")
		if new_mask_index == 1:
			animation_player.play("mask_3")
		if new_mask_index == 2:
			animation_player.play("mask_4")
		TurnHandler.current_mask = new_mask_index
		is_mask_on = true
		is_first_mask_ever = false

func unequip(mask_index) -> void:
	is_mask_on = false
	if mask_index == 0:
		animation_player.play_backwards("mask_2")
	if mask_index == 1:
		animation_player.play_backwards("mask_3")
	if mask_index == 2:
		animation_player.play_backwards("mask_4")

func hide_the_mask() -> void:
	masks[active_mask].visible = false
	masks[active_mask].set_process(false)
