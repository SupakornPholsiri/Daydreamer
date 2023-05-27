extends Sprite2D

class_name SpawnIndicator

signal timer_ended

var spawn_time : float = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if spawn_time <= 0:
		emit_signal("timer_ended", position)
		queue_free()
	else:
		spawn_time -= delta
