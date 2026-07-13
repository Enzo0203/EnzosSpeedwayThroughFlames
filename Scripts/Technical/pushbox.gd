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
			
			# Create a Transform2D representing the previewed movement
			var test_transform: Transform2D = get_parent().global_transform
			test_transform.origin.x += push_step
			
			# Test if moving would clip into wall
			if not get_parent().test_move(test_transform, get_parent().velocity):
				# Safe to move directly via position
				get_parent().global_position.x += push_step
			else:
				# If hitting a wall, push the other thing instead
				var opposing_transform: Transform2D = opposing_pushbox.get_parent().global_transform
				opposing_transform.origin.x -= push_step
				
				if not opposing_pushbox.get_parent().test_move(opposing_transform, get_parent().velocity):
					opposing_pushbox.get_parent().global_position.x -= push_step
