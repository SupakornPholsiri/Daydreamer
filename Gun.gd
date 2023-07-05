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
	# Change weapon to handgun.
	change_weapon(0)

func _process(delta):
	# Decide whether to flip the gun sprite and offset or not.
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
	# Deduct the cooldown timer until it reaches zero.
	if cooldown_timer > 0:
		cooldown_timer -= delta
		
# Change the weapon according the the weapon ID.
func change_weapon(weapon_id : int):
	# Save the current weapon and reset the cooldown timer.
	current_weapon = weapon_id
	cooldown_timer = 0
	# Show the current weapon's sprite and hide the others'.
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
			
# Handle how to shoot according to the current weapon.
func handle_shoot(target_position : Vector2):
	match current_weapon:
		WEAPON_TYPE.HANDGUN : handgun_shoot(target_position)
		WEAPON_TYPE.SHOTGUN : shotgun_shoot(target_position)
		WEAPON_TYPE.MACHINEGUN : machinegun_shoot(target_position)
		
# Reset the cooldown timer to the original value for the current weapon.
func reset_cooldown_timer():
	match current_weapon:
		WEAPON_TYPE.HANDGUN : cooldown_timer = HANDGUN_COOLDOWN
		WEAPON_TYPE.SHOTGUN : cooldown_timer = SHOTGUN_COOLDOWN
		WEAPON_TYPE.MACHINEGUN : cooldown_timer = MACHINEGUN_COOLDOWN
			
# Shoot handgun
func handgun_shoot(target_position : Vector2):
	# If cooldown timer reached zero
	if cooldown_timer <= 0:
		# Create a bullet
		var b = bullet_scene.instantiate()
		# Use the gun's global position and rotation for the bullet.
		b.global_position = handgun.global_position
		b.global_rotation = global_rotation
		# Set the bullet's direction, damage and collision layer.
		b.direction = (target_position - global_position).normalized()
		b.damage = 1
		b.set_collision_layer_value(4, true)
		# Add the bullet to the scene in the same tree-level as the player.
		get_node("../..").add_child(b)
		# Play the gunshot sound once.
		SoundPlayer.play_gun_sound(1)
		# Reset the weapon's cooldown timer.
		reset_cooldown_timer()

# Shoot shotgun
func shotgun_shoot(target_position : Vector2):
	# If cooldown timer reached zero
	if cooldown_timer <= 0:
		# Create three bullets.
		var b1 = bullet_scene.instantiate()
		var b2 = bullet_scene.instantiate()
		var b3 = bullet_scene.instantiate()
		# Use the gun's global position for the bullets.
		b1.global_position = shotgun.global_position
		b2.global_position = shotgun.global_position
		b3.global_position = shotgun.global_position
		# Set the rotation and direction of each bullets, make the second and third bullets spread out.
		b1.global_rotation = global_rotation
		b2.global_rotation = global_rotation - PI / 12
		b3.global_rotation = global_rotation + PI / 12
		b1.direction = (target_position - global_position).normalized()
		b2.direction = (target_position - global_position).normalized().rotated(- PI / 12)
		b3.direction = (target_position - global_position).normalized().rotated( PI / 12)
		# Set the damage and collision layer of the bullets.
		b1.damage = 1
		b2.damage = 1
		b3.damage = 1
		b1.set_collision_layer_value(4, true)
		b2.set_collision_layer_value(4, true)
		b3.set_collision_layer_value(4, true)
		# Add the bullets to the scene in the same tree-level as the player.
		get_node("../..").add_child(b1)
		get_node("../..").add_child(b2)
		get_node("../..").add_child(b3)
		# Play the gunshot sound three times.
		SoundPlayer.play_gun_sound(3)
		# Reset the gun's cooldown timer.
		reset_cooldown_timer()

func machinegun_shoot(target_position : Vector2):
	# Pretty much the same as handgun shooting function.
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
