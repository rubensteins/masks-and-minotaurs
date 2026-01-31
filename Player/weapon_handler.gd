extends Node3D

@export_category("Masks")
@export var masks : Array[Node3D]
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var active_mask : int
var is_mask_on : bool = false

func _process(_delta) -> void:
	# we're going to do mask swapping here
	if Input.is_action_just_pressed("mask_1") and not animation_player.is_playing():
		if not is_mask_on:
			equip(0)
		else: 
			unequip(0)
			
	if Input.is_action_just_pressed("mask_2") and not animation_player.is_playing():
		if not is_mask_on:
			equip(1)
		else: 
			unequip(1)

	if Input.is_action_just_pressed("mask_3") and not animation_player.is_playing():
		if not is_mask_on:
			equip(2)
		else: 
			unequip(2)

func equip(new_mask_index : int) -> void:
	masks[new_mask_index].visible = true
	masks[new_mask_index].set_process(true)
	active_mask = new_mask_index
	if new_mask_index == 0:
		animation_player.play("mask_2")
	if new_mask_index == 1:
		animation_player.play("mask_3")
	if new_mask_index == 2:
		animation_player.play("mask_4")
	is_mask_on = true

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
