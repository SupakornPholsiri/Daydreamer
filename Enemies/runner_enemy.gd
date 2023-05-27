extends CharacterBody2D

signal enemy_died

const SPEED = 130

@onready var target = get_node("../Player")
@onready var soft_collision_area = $SoftCollisionArea
@onready var hitbox = $Hitbox

@export var POINT = 50
@export var MAX_HEALTH : int = 1 : set = set_max_health

var health : int

func _ready():
	health = MAX_HEALTH

func _physics_process(delta):
	# Follow the player
	velocity = Vector2.ZERO
	var direction = (target.global_position - global_position).normalized()
	if global_position.distance_to(target.global_position) > SPEED * delta:
		velocity = direction * SPEED
	else :
		velocity = direction * global_position.distance_to(target.global_position) / delta
		
	move_and_collide(velocity * delta)

	var push_vector = soft_collision_area.get_push_vector()
	if push_vector != Vector2.ZERO:
		velocity = push_vector * delta * 1200

		move_and_collide(velocity * delta)
	
func set_health(value : int):
	health = max(0, value)
	if health <= 0:
		die()
	
func set_max_health(value : int):
	MAX_HEALTH = max(1, value)

func _on_hitbox_body_entered(body):
	if body is Bullet:
		body.queue_free()
		set_health(health - body.damage)
		
func die():
	hitbox.disconnect("body_entered", _on_hitbox_body_entered)
	emit_signal("enemy_died", POINT)
	queue_free()
