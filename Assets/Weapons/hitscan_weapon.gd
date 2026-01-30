extends Node3D

@export_category("Managers")
@export var ammo_handler : AmmoHandler

@export_category("Weapon Properties")
@export var fire_rate := 14.0 # per second
@export var recoil_amount := 0.05 # in meters
@export var recoil_speed_back := 10.0
@export var weapon_range := 100.0
@export var weapon_base_dmg := 20.0
@export var is_automatic : bool = true
@export var ammo_type: AmmoHandler.ammo_type

@export_category("Weapon Visuals")
@export var muzzle_flash: GPUParticles3D
@export var sparks: PackedScene
@export var weapon_mesh := Node3D

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var original_weapon_position : Vector3 = weapon_mesh.position
@onready var ray_cast: RayCast3D = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ray_cast.target_position.z = -(weapon_range)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var canFire : bool = false
	
	if cooldown_timer.is_stopped() and ammo_handler.has_ammo(ammo_type):
		if Input.is_action_pressed("Fire") and is_automatic:
			canFire = true
		elif Input.is_action_just_pressed(("Fire")):
			canFire = true
		
	if canFire:
		fire()	
	# if we're recoiled, start moving back
	weapon_mesh.position = weapon_mesh.position.lerp(original_weapon_position, delta * recoil_speed_back)
		
func fire() -> void:
	ammo_handler.use_ammo(ammo_type)
	
	if muzzle_flash != null:
		muzzle_flash.restart()
	
	var target = ray_cast.get_collider()
	#if target is Enemy:
	#	target.take_damage(weapon_base_dmg)
	
	cooldown_timer.start(1.0/fire_rate)
	
	#initiate recoil
	weapon_mesh.position.z += recoil_amount
	
	#sparks where we hit
	var spark = sparks.instantiate()
	add_child(spark)
	spark.global_position = ray_cast.get_collision_point()
