extends "res://Scripts/Objects/crate_wood.gd"

@onready var health_manager: HealthManager = $HealthManager
@onready var atlasTexture: AtlasTexture = $Sprite.texture

func _physics_process(_delta: float) -> void:
	if health_manager.health > 3:
		atlasTexture.region = Rect2(0, 60, 30, 30)
	else:
		atlasTexture.region = Rect2(0, 90, 30, 30)

func _on_hurtbox_hurt(_area: Area2D, Damage: int, _Knockback: Vector2) -> void:
	health_manager.deal_damage(Damage)

func _on_health_manager_dead() -> void:
	for emitter: Node in particles.get_children():
		if emitter is GPUParticles2D:
			emitter.emitting = true
	
	GlobalAudioManager.play_audio_2d("res://Sfx/BrickBreaking.ogg", global_position, 0,\
	randf_range(0.9, 1.1))
	
	await get_tree().process_frame # So it doesn't blink
	sprite.hide()
	collisionshape.disabled = true
	hurtboxshape.disabled = true
	
	await $Particles/Particle1.finished
	queue_free()
