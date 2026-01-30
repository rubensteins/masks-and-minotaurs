extends Node
class_name AmmoHandler

@export var ammo_label: Label

enum ammo_type {
	SMALL_BULLET,
	MED_BULLET,
	LARGE_BULLET,
	ROCKET
}

var ammo_supply := {
	ammo_type.SMALL_BULLET: 50,
	ammo_type.MED_BULLET: 10,
	ammo_type.LARGE_BULLET: 0,
	ammo_type.ROCKET: 0
}

func has_ammo(type: ammo_type) -> bool:
	return ammo_supply[type] > 0
	
func use_ammo(type: ammo_type) -> bool:
	if has_ammo(type):
		ammo_supply[type] -= 1
		update_ammo_label(type)
		return true
	return false

func add_ammo(type: ammo_type, amount: int) -> void:
	printt(type, amount)
	ammo_supply[type] += amount
		
func update_ammo_label(type: ammo_type) -> void:
	ammo_label.text = str(ammo_supply[type])
