extends CharacterBody2D

signal player_health_changed(health : int)
signal player_died
signal powerup_timed_out

@onready var gun = $Gun
@onready var invincibility_timer = $InvincibilityTimer
@onready var hitbox = $Hitbox
@onready var white_flicker_animation_player = $WhiteFlickerAnimationPlayer
@onready var powerup_timer = $PowerupTimer
@onready var invincibility_bubble = $InvincibilityBubble

@export var SPEED = 150.0
@export var MAX_HEALTH : int = 3 : set = set_max_health
@export var KEYBOARD_ONLY : bool = false : set = change_control_scheme

# General aiming
var target_position : Vector2
# Keyboard only aiming
var last_target_direction : Vector2 = Vector2.LEFT

# Powerups
enum POWERUP {
	NONE,
	INVINCIBILITY,
	SUBMACHINEGUN,
	SHOTGUN,
	RPG
}

var starting_position : Vector2

# In-game player status
var health : int
var active_powerup : int = 0
var invincible : bool = false

# The events
var click_event
var aim_up_event
var aim_down_event
var aim_left_event
var aim_right_event

func _ready():
	# Setting up events for the control scheme change feature
	click_event = InputEventMouseButton.new()
	click_event.button_index = MOUSE_BUTTON_LEFT
	aim_up_event = InputEventKey.new()
	aim_up_event.keycode = KEY_I
	aim_down_event = InputEventKey.new()
	aim_down_event.keycode = KEY_K
	aim_left_event = InputEventKey.new()
	aim_left_event.keycode = KEY_J
	aim_right_event = InputEventKey.new()
	aim_right_event.keycode = KEY_L
	
	# Initializing the player
	starting_position = position
	health = MAX_HEALTH
	emit_signal("player_health_changed", health)

func _physics_process(delta):
	# Get the movement direction.
	var direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	if KEYBOARD_ONLY:
		# Get the aim direction and use it to calculate the target position
		var target_direction = Vector2(Input.get_axis("aim_left", "aim_right"), Input.get_axis("aim_up", "aim_down")).normalized()
		if target_direction:
			target_position = global_position + target_direction * 50
			last_target_direction = target_direction
		# Use the last aim direction if there is no aim input
		else:
			target_position = global_position + last_target_direction * 50
	else:
		# Get the mouse location.
		target_position = get_global_mouse_position()
	# Handle gun movement
	gun.global_rotation = global_position.angle_to_point(target_position)
		
	# Handle the movement/deceleration.
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()
	
	position.x = clamp(position.x, 16, 704)
	position.y = clamp(position.y, 16, 704)
	
	# Always shoot if using keyboard only control, only shoot when clicked otherwise.
	if KEYBOARD_ONLY or Input.is_action_pressed("shoot"):
		shoot(target_position)
		
# Change the control scheme
func change_control_scheme(is_keyboard_only):
	KEYBOARD_ONLY = is_keyboard_only
	if KEYBOARD_ONLY:
		InputMap.action_erase_event("shoot", click_event)
		InputMap.action_add_event("aim_up", aim_up_event)
		InputMap.action_add_event("aim_down", aim_down_event)
		InputMap.action_add_event("aim_left", aim_left_event)
		InputMap.action_add_event("aim_right", aim_right_event)
	else :
		InputMap.action_add_event("shoot", click_event)
		InputMap.action_erase_event("aim_up", aim_up_event)
		InputMap.action_erase_event("aim_down", aim_down_event)
		InputMap.action_erase_event("aim_left", aim_left_event)
		InputMap.action_erase_event("aim_right", aim_right_event)

# Change the weapon according to the weapon ID.
func _on_changed_weapon(weapon_id):
	gun.change_weapon(weapon_id)
	
# Shoot at the position(pos) inputted.
func shoot(pos : Vector2):
	gun.handle_shoot(pos)

# Remove the temporary invincibility granted from getting damaged.
func _on_invincibility_timer_timeout():
	invincible = false
	hitbox.get_node("CollisionShape2D").disabled = false
	SPEED = 150
	white_flicker_animation_player.play("stop_invincibility")

# Maybe I'll use it for bullet collision.
func _on_hitbox_body_entered(body):
	if body is Bullet and not invincible:
		invincible = true
		hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
		SPEED = 200
		invincibility_timer.start(1)
		white_flicker_animation_player.play("start_invincibility")
		set_health(health - body.damage)

func _on_hitbox_area_entered(area):
	# Deduct health if the player isn't invincible.
	if not invincible:
		set_health(health - area.damage)
		emit_signal("player_health_changed", health)
		# Player die when health reach zero.
		if health <= 0:
			die()
		# Grant temporary invincibility.
		else :
			invincible = true
			hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
			SPEED = 200
			invincibility_timer.start(1)
			white_flicker_animation_player.play("start_invincibility")

# Set the player's health.
func set_health(value : int):
	health = max(0, value)
	
# Set the player's maximum health.
func set_max_health(value : int):
	MAX_HEALTH = max(1, value)

# Activate the powerup effect according the powerup's ID for an amount of time in seconds.
func activate_powerup(powerup_id : int, time : float):
	active_powerup = powerup_id
	match powerup_id:
		POWERUP.INVINCIBILITY : activate_invincibility(time)
		POWERUP.SHOTGUN : activate_shotgun(time)
		POWERUP.SUBMACHINEGUN : activate_submachinegun(time)
		POWERUP.RPG : activate_rpg(time)

# Activate the invincibility effect for an amount of time in seconds.
func activate_invincibility(time : float):
	invincibility_timer.stop()
	white_flicker_animation_player.play("stop_invincibility")
	invincible = true
	hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
	invincibility_bubble.visible = true
	powerup_timer.start(time)

# Activate the shotgun effect for an amount of time in seconds.
func activate_shotgun(time : float):
	_on_changed_weapon(2)
	powerup_timer.start(time)

# Activate the machine gun effect for an amount of time in seconds.
func activate_submachinegun(time : float):
	_on_changed_weapon(1)
	powerup_timer.start(time)

# Activate the rpg effect for an amount of time in seconds.
func activate_rpg(time : float):
	_on_changed_weapon(3)
	powerup_timer.start(time)
	
# Make the player ignore further collision and signal that the player has died.
func die():
	invincible = true
	hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
	emit_signal("player_died")
	
# Reset the player
func reset():
	# Prevent signal race condition.
	hitbox.disconnect("area_entered", _on_hitbox_area_entered)
	# Reset player's health.
	set_health(MAX_HEALTH)
	emit_signal("player_health_changed", health)
	# Reset the timers.
	invincibility_timer.stop()
	powerup_timer.stop()
	# Stop the invincibility animation
	white_flicker_animation_player.play("stop_invincibility")
	white_flicker_animation_player.stop()
	# Remove the invincibility bubble.
	invincibility_bubble.visible = false
	invincible = false
	# Remove the powerup.
	active_powerup = POWERUP.NONE
	# Change weapon back to handgun.
	_on_changed_weapon(0)
	# Move the player to the starting position.
	position = starting_position
	# Enable the player's collision.
	hitbox.get_node("CollisionShape2D").set_deferred("disabled", false)
	
# Do this every time the game start.
func start():
	hitbox.connect("area_entered", _on_hitbox_area_entered)

# Remove the powerup's effect.
func _on_powerup_timer_timeout():
	match active_powerup:
		POWERUP.INVINCIBILITY : 
			invincible = false
			hitbox.get_node("CollisionShape2D").disabled = false
			invincibility_bubble.visible = false
		POWERUP.SHOTGUN : _on_changed_weapon(0)
		POWERUP.SUBMACHINEGUN : _on_changed_weapon(0)
		POWERUP.RPG : _on_changed_weapon(0)
	emit_signal("powerup_timed_out")
