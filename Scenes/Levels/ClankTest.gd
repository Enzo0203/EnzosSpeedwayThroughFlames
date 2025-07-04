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

func _enzoHitboxAreaEntered(area: Area2D) -> void:
	if area.is_in_group("EnemyHitbox"):
		$Enzo/Hitbox/HitboxShape.disabled = true
		$CPUParticles2D.emitting = true

func _enzoHurtboxAreaEntered(area: Area2D) -> void:
	if area.is_in_group("EnemyHitbox"):
		enzoHurt()

func _demonHitboxAreaEntered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		$Demon/Hitbox/HitboxShape.disabled = true

func _demonHurtboxAreaEntered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		# Shoot raycast from Self's Hurtbox's CollisionShape to Player's Hitbox's CollisionShape
		$Demon/Raycast.global_position = $Demon/Hurtbox/HurtboxShape.global_position
		$Demon/Raycast.target_position = ($Demon/Raycast.global_position - area.get_child(0).global_position) * -1
		$Demon/Raycast.force_raycast_update()
		if $Demon/Raycast.is_colliding() == false or $Demon/Hitbox.overlaps_area(area):
			demonHurt()

func is_player_hitbox(area: Area2D) -> bool:
	if area.is_in_group("PlayerHitbox"):
		return true
	else:
		return false
