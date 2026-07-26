extends Area2D
class_name Pushbox

@export var push_speed: float = 10.0

func _physics_process(delta: float) -> void:
	for area: Area2D in get_overlapping_areas():
		if area is Pushbox and area != self:
			var opposing_pushbox: Pushbox = area
			
			var distance: float = get_parent().global_position.x - opposing_pushbox.get_parent().global_position.x
			var direction: float = sign(distance)
			if direction == 0: 
				direction = 1 
			
			# Calculate exactly how many pixels to move this frame
			var push_step: float = direction * push_speed * delta
			
			# Create a motion Vector2 representing ONLY the horizontal push
			var push_vector: Vector2 = Vector2(push_step, 0)
			
			# Test if this specific push vector collides with a wall
			# The second parameter must match the intended movement step
			if not get_parent().test_move(get_parent().global_transform, push_vector):
				# Safe to move directly via position
				get_parent().global_position.x += push_step
			else:
				# If hitting a wall, push the other thing instead
				var opposing_push_vector: Vector2 = Vector2(-push_step, 0)
				
				# Test the opposing fighter's pushbox with its corresponding vector
				if not opposing_pushbox.get_parent().test_move(opposing_pushbox.get_parent().global_transform, opposing_push_vector):
					opposing_pushbox.get_parent().global_position.x -= push_step
