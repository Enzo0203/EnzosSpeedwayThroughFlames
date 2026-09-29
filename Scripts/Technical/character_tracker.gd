## Detects Area2Ds and returns their owner if they're a CharacterBody.
class_name CharacterTracker extends Area2D

## If this variable is assigned a raycast, it shoots it to the target
## and only actually sets it as the target if it sees it.
## If left empty, targets can be assigned without requiring line of sight.
@export var RequiresLineOfSight: RayCast2D = null

## If false, ignores any other targets that enter this area if there's already a target.
## If true, always sets the last target that entered this area as the new target.
@export var LockOnFirstTarget: bool = false


var target: CharacterBody2D

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		return
	if area.owner is CharacterBody2D:
		target = area.owner

func _on_area_exited(area: Area2D) -> void:
	if area is Hitbox:
		return
	if area.owner == target:
		target = null
