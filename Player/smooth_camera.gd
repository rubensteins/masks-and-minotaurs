extends Camera3D

@export var speed := 44.0
func _physics_process(delta: float) -> void:
	var weight = clamp(delta * speed, 0.0, 1.0)
	var parent = get_parent()
	global_transform = global_transform.interpolate_with(
		parent.global_transform, weight
	)
	global_position = parent.global_position
