extends Area2D

func _ready() -> void:
	assert(get_parent() is CharacterBody2D, "Parent of Pushbox must be CharacterBody2D")

func _physics_process(_delta: float) -> void:
	if not get_parent().is_on_wall():
		if has_overlapping_areas():
			if get_overlapping_areas().filter(is_pushbox).all(is_to_the_left):
				get_parent().global_position.x += 2
			elif get_overlapping_areas().filter(is_pushbox).all(is_to_the_right):
				get_parent().global_position.x -= 2
			if get_overlapping_areas().filter(is_pushbox).any(is_in_same_spot):
				get_parent().global_position.x += [-2, 2].pick_random()

func is_pushbox(area: Area2D) -> bool:
	if area.is_in_group("Pushbox"):
		return true
	else:
		return false

func is_to_the_left(pushbox: Area2D) -> bool:
	if pushbox.global_position.x < global_position.x:
		return true
	else:
		return false

func is_to_the_right(pushbox: Area2D) -> bool:
	if pushbox.global_position.x < global_position.x:
		return true
	else:
		return false

func is_in_same_spot(pushbox: Area2D) -> bool:
	if pushbox.global_position.x == global_position.x:
		return true
	else:
		return false
