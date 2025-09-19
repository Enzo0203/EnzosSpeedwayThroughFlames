extends RigidBody2D

@onready var label: Label = $Label
@onready var hurtboxshape: CollisionShape2D = $Crate/CrateHurtbox/HurtboxShape
@onready var hurtbox: Area2D = $Crate/CrateHurtbox
@onready var crate: Sprite2D = $Crate
@onready var crate_collision: CollisionShape2D = $CollisionShape2D
@onready var animation: AnimationPlayer = $Crate/CrateAnimationPlayer
@onready var explosionsprite: Sprite2D = $Explosion
@onready var sfx_explode: AudioStreamPlayer2D = $Explosion/ExplosionSfx
@onready var marker: Marker2D = $Marker2D
@onready var explosion_animation: AnimationPlayer = $Explosion/AnimationPlayer
@onready var explosion: Sprite2D = $Explosion

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	animation.play("idle")
	explosion.hide()

func _physics_process(_delta: float) -> void:
	label.text = str(sfx_explode.pitch_scale)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		explode()
	if area.is_in_group("EnvironmentalHitbox"):
		await get_tree().create_timer(0.3).timeout
		explode()
	if area.is_in_group("CloseExplosion"):
		explode()
	if area.is_in_group("EnemyHitbox"):
		explode()

func _on_area_2d_area_exited(_area: Area2D) -> void:
	pass

func explode() -> void:
	var exploded: bool = false
	if exploded == false:
		randomizeAudioPitch(sfx_explode)
		explosion.show()
		explosion.global_position = marker.global_position
		explosion.scale = Vector2(0.6, 0.6)
		animation.play('exploded')
		explosion_animation.play("Orange Instant")
		if get_tree():
			await get_tree().create_timer(1.1).timeout
		destroy()
		exploded = true

func destroy() -> void:
	hide()
	set_process(false)

func randomizeAudioPitch(audio: AudioStreamPlayer2D) -> void:
	audio.pitch_scale = randf_range(0.6, 1.4)
