extends Node3D

@export_category("Masks")
@export var weapons : Array[Node3D]

var active_weapon : int

func _ready() -> void:
	equip(1)

func _process(_delta) -> void:
	# we're going to do mask swapping here
	#if Input.is_action_just_released("next_weapon"):
	#	equip(wrapi(active_weapon+1, 0, weapons.size()))

	#if Input.is_action_just_released("prev_weapon"):
	#	equip(wrapi(active_weapon-1, 0, weapons.size()))
	pass

func equip(new_weapon_index : int) -> void:
	# if it's actually a different weapons 
	# and we have the new weapons, do the switch
	if active_weapon != new_weapon_index and weapons[new_weapon_index] != null:
		weapons[active_weapon].visible = false
		weapons[active_weapon].set_process(false)
		weapons[new_weapon_index].visible = true
		weapons[new_weapon_index].set_process(true)
		active_weapon = new_weapon_index
#		weapons[active_weapon].ammo_handler.update_ammo_label(weapons[active_weapon].ammo_type)

func _unhandled_input(_event: InputEvent) -> void:
	
#	if event.is_action_pressed("weapon_1"):
#		equip(0)
	
#	if event.is_action_pressed("weapon_2"):
#		equip(1)
	pass	
