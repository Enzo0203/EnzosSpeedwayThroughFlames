extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var spawnPosition

func _ready():
	if spawnPosition:
		global_position = spawnPosition

func _physics_process(delta: float):
	move_and_slide()
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	$Spritesheet/AnimationPlayer.play("idle")

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHurtbox"):
		queue_free()
