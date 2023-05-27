extends Node2D

const walker_enemy = preload("res://Enemies/walker_enemy.tscn")
const runner_enemy = preload("res://Enemies/runner_enemy.tscn")
const spawn_indicator = preload("res://Daydream/spawn_indicator.tscn")
const player_scene = preload("res://player.tscn")

@export var ENEMY_SPAWN_COOLDOWN = 0.7
@export var POWERUP_SPAWN_COOLDOWN = 1

@onready var player = $Player
@onready var powerup_spawn_timer = $PowerupSpawnTimer
@onready var invincible_powerup = $InvinciblePowerup
@onready var shotgun_powerup = $ShotgunPowerup
@onready var machinegun_powerup = $MachinegunPowerup
@onready var ammobox = $Ammobox

var enemy_spawn_timer : float = 0
var current_powerup

# Called when the node enters the scene tree for the first time.
func _ready():
	remove_child(invincible_powerup)
	remove_child(shotgun_powerup)
	remove_child(machinegun_powerup)
	
func start():
	player.start()
	enemy_spawn_timer = ENEMY_SPAWN_COOLDOWN
	powerup_spawn_timer.start(2)
	
func reset():
	ammobox.frame = 0
	powerup_spawn_timer.stop()
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.queue_free()
	for child in get_children():
		if child is Powerup:
			remove_child(child)
		elif child is SpawnIndicator or child is Bullet:
			child.queue_free()
	enemy_spawn_timer = ENEMY_SPAWN_COOLDOWN
	player.reset()
	
func _physics_process(delta):
	if enemy_spawn_timer <= 0 :
		spawn_enemy(Vector2(randi_range(0, 720), randi_range(0,720)))
		enemy_spawn_timer = ENEMY_SPAWN_COOLDOWN
	else :
		enemy_spawn_timer -= delta
		
func spawn_enemy(position : Vector2):
	var indicator = spawn_indicator.instantiate()
	indicator.position = position
	add_child(indicator)
	indicator.connect("timer_ended", _on_spawn_indicator_timer_ended)
	
func _on_spawn_indicator_timer_ended(position : Vector2):
	var enemy
	var random_number = randi_range(0,2)
	if random_number < 2:
		enemy = walker_enemy
	if random_number == 2:
		enemy = runner_enemy
		spawn_enemy(Vector2(randi_range(0, 720), randi_range(0,720)))
		enemy_spawn_timer = ENEMY_SPAWN_COOLDOWN
	var new_enemy = enemy.instantiate()
	new_enemy.position = position
	add_child(new_enemy)

func _on_player_powerup_timed_out():
	powerup_spawn_timer.start(2)

func _on_powerup_spawn_timer_timeout():
	ammobox.frame = 1
	var powerup_id = randi_range(1, 3)
	match powerup_id:
		1 : current_powerup = machinegun_powerup
		2 : current_powerup = shotgun_powerup
		3 : current_powerup = machinegun_powerup
	current_powerup.position = Vector2(360, 360)
	add_child(current_powerup)
	
func handle_powerup_activation(powerup_id : int):
	ammobox.frame = 0
	call_deferred("remove_child", current_powerup)
	player.activate_powerup(powerup_id)
