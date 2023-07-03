extends Area2D

class_name Powerup

signal powerup_picked_up(powerup_id : int)

@export var powerup_id : int = 1
@export var time : float = 5

func _on_body_entered(body):
	emit_signal("powerup_picked_up", powerup_id)
