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
		hitbox.set_collision_layer_value(7, false)
		hitbox.set_collision_layer_value(5, true)
	randomizeAudioPitch()
	animation.play("Orange Instant")
	if animation.is_playing() == false:
		destroy()

func randomizeAudioPitch() -> void:
	sfx_explode.pitch_scale = randf_range(0.5, 1.5)

func destroy() -> void:
	queue_free()
