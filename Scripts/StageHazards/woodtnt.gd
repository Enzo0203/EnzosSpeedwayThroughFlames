extends RigidBody2D

@onready var label: Label = $Label

@onready var animation: AnimationPlayer = $Crate/CrateAnimationPlayer
@onready var marker: Marker2D = $Marker2D

@onready var explosion: PackedScene = preload("res://Scenes/Miscellaneous/explosion.tscn")

@onready var hurtbox: Area2D = $Crate/CrateHurtbox
@onready var hurtboxshape: CollisionShape2D = $Crate/CrateHurtbox/HurtboxShape

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	animation.play("idle")

func explode() -> void:
	var explosion_instance: Node = explosion.instantiate()
	explosion_instance.spawnPosition = marker.global_position
	explosion_instance.explosionSize = 0.6
	explosion_instance.cantHurtEnzo = false
	get_parent().add_child(explosion_instance)
	destroy()

func destroy() -> void:
	queue_free()

func randomizeAudioPitch(audio: AudioStreamPlayer2D) -> void:
	audio.pitch_scale = randf_range(0.6, 1.4)

func _on_crate_hurtbox_hurt(area: Area2D, _Damage: int, _Knockback: Vector2, _DeathType: String) -> void:
	if area.is_in_group("Explosion"):
		await get_tree().create_timer(0.3).timeout
		explode()
	else:
		explode()
