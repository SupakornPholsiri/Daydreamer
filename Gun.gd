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
		
# Create a bullet and set all the neccessary attributes
func create_bullet(start_pos : Vector2, bullet_rotation : float, direction : Vector2, damage : int, collision_layer_value : int):
	# Create a bullet
	var b = bullet_scene.instantiate()
	# Use the gun's global position for the bullet's starting position
	b.global_position = start_pos
	# Set the attributes according to the arguments.
	b.global_rotation = bullet_rotation
	b.direction = direction
	b.damage = damage
	b.set_collision_layer_value(collision_layer_value, true)
	# Return the bullet.
	return b
			
# Shoot handgun
func handgun_shoot(target_position : Vector2):
	# If cooldown timer reached zero
	if cooldown_timer <= 0:
		# Create a bullet.
		var b = create_bullet(handgun.global_position, global_rotation, (target_position - global_position).normalized(), 1, 4)
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
		# Create three bullets in a spread out pattern.
		var b1 = create_bullet(shotgun.global_position, global_rotation, (target_position - global_position).normalized(), 1, 4)
		var b2 = create_bullet(shotgun.global_position, global_rotation - PI / 12, (target_position - global_position).normalized().rotated(- PI / 12), 1, 4)
		var b3 = create_bullet(shotgun.global_position, global_rotation + PI / 12, (target_position - global_position).normalized().rotated(PI / 12), 1, 4)
		# Add the bullets to the scene in the same tree-level as the player.
		get_node("../..").add_child(b1)
		get_node("../..").add_child(b2)
		get_node("../..").add_child(b3)
		# Play the gunshot sound three times.
		SoundPlayer.play_gun_sound(3)
		# Reset the gun's cooldown timer.
		reset_cooldown_timer()

func machinegun_shoot(target_position : Vector2):
	# If cooldown timer reached zero
	if cooldown_timer <= 0:
		# Create a bullet.
		var b = create_bullet(machinegun.global_position, global_rotation, (target_position - global_position).normalized(), 1, 4)
		# Add the bullet to the scene in the same tree-level as the player.
		get_node("../..").add_child(b)
		# Play the gunshot sound once.
		SoundPlayer.play_gun_sound(1)
		# Reset the weapon's cooldown timer.
		reset_cooldown_timer()
