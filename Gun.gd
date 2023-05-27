extends Node2D

const bullet_scene = preload("res://bullet.tscn")

@onready var handgun = $Handgun
@onready var shotgun = $Shotgun
@onready var machinegun = $Machinegun

const HANDGUN_COOLDOWN : float = 0.2
const SHOTGUN_COOLDOWN : float = 0.2
const MACHINEGUN_COOLDOWN : float = 0.1

enum WEAPON_TYPE {
	HANDGUN,
	MACHINEGUN,
	SHOTGUN,
	RPG
}

var current_weapon = WEAPON_TYPE.HANDGUN
var cooldown_timer : float = 0

func _ready():
	change_weapon(0)

func _process(delta):
	if -PI/2 <= rotation and rotation <= PI/2:
		handgun.flip_v = false
		handgun.offset.y = 2
		shotgun.flip_v = false
		shotgun.offset.y = 1
		machinegun.flip_v = false
		machinegun.offset.y = 0.5
	else:
		handgun.flip_v = true
		handgun.offset.y = -2
		shotgun.flip_v = true
		shotgun.offset.y = -1
		machinegun.flip_v = true
		machinegun.offset.y = -0.5

func _physics_process(delta):
	if cooldown_timer > 0:
		cooldown_timer -= delta
		
func change_weapon(weapon_id : int):
	current_weapon = weapon_id
	cooldown_timer = 0
	match weapon_id:
		WEAPON_TYPE.HANDGUN : 
			handgun.visible = true
			shotgun.visible = false
			machinegun.visible = false
		WEAPON_TYPE.SHOTGUN : 
			handgun.visible = false
			shotgun.visible = true
			machinegun.visible = false
		WEAPON_TYPE.MACHINEGUN :
			handgun.visible = false
			shotgun.visible = false
			machinegun.visible = true
			
func handle_shoot(target_position : Vector2):
	match current_weapon:
		WEAPON_TYPE.HANDGUN : handgun_shoot(target_position)
		WEAPON_TYPE.SHOTGUN : shotgun_shoot(target_position)
		WEAPON_TYPE.MACHINEGUN : machinegun_shoot(target_position)
		
func reset_cooldown_timer():
	match current_weapon:
		WEAPON_TYPE.HANDGUN : cooldown_timer = HANDGUN_COOLDOWN
		WEAPON_TYPE.SHOTGUN : cooldown_timer = SHOTGUN_COOLDOWN
		WEAPON_TYPE.MACHINEGUN : cooldown_timer = MACHINEGUN_COOLDOWN
			
func handgun_shoot(target_position : Vector2):
	if cooldown_timer <= 0:
		var b = bullet_scene.instantiate()
		b.global_position = handgun.global_position
		b.global_rotation = global_rotation
		b.direction = (target_position - global_position).normalized()
		b.damage = 1
		b.set_collision_layer_value(4, true)
		get_node("../..").add_child(b)
		SoundPlayer.play_gun_sound(1)
		reset_cooldown_timer()
		
func shotgun_shoot(target_position : Vector2):
	if cooldown_timer <= 0:
		var b1 = bullet_scene.instantiate()
		var b2 = bullet_scene.instantiate()
		var b3 = bullet_scene.instantiate()
		b1.global_position = shotgun.global_position
		b2.global_position = shotgun.global_position
		b3.global_position = shotgun.global_position
		b1.global_rotation = global_rotation
		b2.global_rotation = global_rotation - PI / 12
		b3.global_rotation = global_rotation + PI / 12
		b1.direction = (target_position - global_position).normalized()
		b2.direction = (target_position - global_position).normalized().rotated(- PI / 12)
		b3.direction = (target_position - global_position).normalized().rotated( PI / 12)
		b1.damage = 1
		b2.damage = 1
		b3.damage = 1
		b1.set_collision_layer_value(4, true)
		b2.set_collision_layer_value(4, true)
		b3.set_collision_layer_value(4, true)
		get_node("../..").add_child(b1)
		get_node("../..").add_child(b2)
		get_node("../..").add_child(b3)
		SoundPlayer.play_gun_sound(3)
		reset_cooldown_timer()

func machinegun_shoot(target_position : Vector2):
	if cooldown_timer <= 0:
		var b = bullet_scene.instantiate()
		b.global_position = machinegun.global_position
		b.global_rotation = global_rotation
		b.direction = (target_position - global_position).normalized()
		b.damage = 1
		b.set_collision_layer_value(4, true)
		get_node("../..").add_child(b)
		SoundPlayer.play_gun_sound(1)
		reset_cooldown_timer()
