extends CharacterBody2D

class_name Bullet

const SPEED = 450.0

var damage : int = 1
var direction : Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = direction * SPEED
	move_and_collide(velocity * delta)
	
	if abs(global_position.x) > 750 or abs(global_position.y) > 750:
		queue_free()
