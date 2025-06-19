extends Node2D

func _physics_process(delta: float) -> void:
	$Enzo.global_position = get_global_mouse_position()
	if Input.is_action_just_pressed("character_x"):
		enzoPunch()
	if Input.is_action_just_pressed("character_c"):
		demonPunch()

func enzoPunch() -> void:
	$Enzo/Hitbox/HitboxShape.disabled = false
	await get_tree().create_timer(0.3).timeout
	$Enzo/Hitbox/HitboxShape.disabled = true

func demonPunch() -> void:
	$Demon/Hitbox/HitboxShape.disabled = false
	await get_tree().create_timer(0.3).timeout
	$Demon/Hitbox/HitboxShape.disabled = true

func enzoHurt() -> void:
	$Enzo/Hitbox/HitboxShape.disabled = true
	$Enzo/Sprite.frame = 10
	await get_tree().create_timer(0.5).timeout
	$Enzo/Sprite.frame = 184

func demonHurt() -> void:
	$Demon/Hitbox/HitboxShape.disabled = true
	$Demon/Sprite.frame = 21
	await get_tree().create_timer(0.5).timeout
	$Demon/Sprite.frame = 18

func enzoHurtboxAreaEntered(area: Area2D) -> void:
	if area.is_in_group("EnemyHitbox"):
		enzoHurt()

func enzoHitboxAreaEntered(area: Area2D) -> void:
	pass # Replace with function body.

func demonHurtboxAreaEntered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		demonHurt()

func demonHitboxAreaEntered(area: Area2D) -> void:
	pass # Replace with function body.
