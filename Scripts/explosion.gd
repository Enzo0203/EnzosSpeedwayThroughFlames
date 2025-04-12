extends Sprite2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sfx_explode: AudioStreamPlayer2D = $ExplosionSfx

var spawnPosition
var explosion_size

func _ready():
	global_position = spawnPosition
	scale.x = explosion_size
	scale.y = explosion_size
	randomizeAudioPitch()
	animation.play("Orange Instant")
	if animation.is_playing() == false:
		destroy()

func randomizeAudioPitch():
	sfx_explode.pitch_scale = randf_range(0.1, 2)

func destroy():
	queue_free()
