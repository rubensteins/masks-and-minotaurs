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

func equip(new_mask_index : int) -> void:
	masks[new_mask_index].visible = true
	masks[new_mask_index].set_process(true)
	active_mask = new_mask_index
	animation_player.play("put_on_ghost_mask")
	is_mask_on = true

func unequip(mask_index) -> void:
	is_mask_on = false
	animation_player.play_backwards("put_on_ghost_mask")

func hide_the_mask() -> void:
	masks[active_mask].visible = false
	masks[active_mask].set_process(false)
