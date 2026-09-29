extends "res://Scripts/Objects/crate_wood.gd"

func _on_hurtbox_hurt(area: Area2D, _Damage: int, _Knockback: Vector2) -> void:
	if area.is_in_group("Explosion"):
		for emitter: Node in particles.get_children():
			if emitter is GPUParticles2D:
				emitter.emitting = true
		
		GlobalAudioManager.play_audio_2d("res://Sfx/MetalCrashing.ogg", global_position, 0,\
		randf_range(0.9, 1.1))
		
		await get_tree().process_frame # So it doesn't blink
		sprite.hide()
		collisionshape.disabled = true
		hurtboxshape.disabled = true
		
		await $Particles/Particle1.finished
		queue_free()
