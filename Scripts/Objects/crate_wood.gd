extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite
@onready var particles: Node2D = $Particles
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurtboxshape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var collisionshape: CollisionShape2D = $CollisionShape2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _on_hurtbox_hurt(_area: Area2D, _Damage: int, _Knockback: Vector2) -> void:
	for emitter: Node in particles.get_children():
		if emitter is GPUParticles2D:
			emitter.emitting = true
	
	GlobalAudioManager.play_audio_2d("res://Sfx/WoodBreaking.ogg", global_position, 0,\
	randf_range(0.9, 1.1))
	
	await get_tree().process_frame # So it doesn't blink
	sprite.hide()
	collisionshape.disabled = true
	hurtboxshape.disabled = true
	
	await $Particles/Particle1.finished
	queue_free()
