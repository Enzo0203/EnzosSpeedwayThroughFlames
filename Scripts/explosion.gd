extends Sprite2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sfx_explode: AudioStreamPlayer2D = $ExplosionSfx
@onready var hitbox: Area2D = $Hitbox


var spawnPosition: Vector2
var explosionSize: float
var cantHurtEnzo: bool

func _ready() -> void:
	global_position = spawnPosition
	scale = Vector2(explosionSize, explosionSize)
	if cantHurtEnzo == true:
		hitbox.remove_from_group("EnvironmentalHitbox")
		hitbox.add_to_group("PlayerHitbox")
	randomizeAudioPitch()
	animation.play("Orange Instant")
	if animation.is_playing() == false:
		destroy()

func randomizeAudioPitch() -> void:
	sfx_explode.pitch_scale = randf_range(0.1, 2)

func destroy() -> void:
	queue_free()
