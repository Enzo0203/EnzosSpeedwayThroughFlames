extends StaticBody2D

@export var path_follow: PathFollow2D

var pathFollowVelocity: float = 0
var currentDirection: float

var exploded: bool = false
func _physics_process(delta: float) -> void:
	currentDirection = deg_to_rad(path_follow.rotation)
	
	if not exploded:
		path_follow.progress += pathFollowVelocity * delta
		pathFollowVelocity = move_toward(pathFollowVelocity, 0, 200 * delta)
	
	if path_follow.progress_ratio == 0 and abs(pathFollowVelocity) > 0:
		pathFollowVelocity = 0
	
	$Sprite.frame = 0 if pathFollowVelocity == 0 else 1 
	$Sprite.flip_h = false if pathFollowVelocity >= 0 else true
	
	if path_follow.progress_ratio == 1 and not exploded:
		explode()
		exploded = true

func _on_hurtbox_hurt(_area: Area2D, _Damage: int, Knockback: Vector2) -> void:
	if not exploded:
		if currentDirection == 0:
			pathFollowVelocity += Knockback.x

@onready var explosion: PackedScene = preload("res://Scenes/Miscellaneous/explosion.tscn")
func explode() -> void:
	var explosion_instance: Node = explosion.instantiate()
	explosion_instance.spawnPosition = global_position
	explosion_instance.explosionSize = 0.7
	explosion_instance.explosionDamage = 7
	explosion_instance.cantHurtEnzo = false
	get_parent().add_child(explosion_instance)
	$"../../Track/AnimationPlayer".play("disappear")
	queue_free()
