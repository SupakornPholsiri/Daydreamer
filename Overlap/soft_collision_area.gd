extends Area2D

func is_colliding():
	var areas = get_overlapping_areas()
	if areas.is_empty():
		return null
	return {"is_colliding" : true, "areas" : areas}
	
func get_push_vector():
	var push_vector = Vector2.ZERO
	var collision = is_colliding()
	if collision:
		for area in collision.areas:
			push_vector += area.global_position.direction_to(global_position)
	return push_vector.normalized()
