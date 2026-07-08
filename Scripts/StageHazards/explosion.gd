extends Node2D

@onready var sprite: Sprite2D = $Sprite
@onready var animation: AnimationPlayer = $Sprite/AnimationPlayer
@onready var sfx_explode: AudioStreamPlayer2D = $Sprite/ExplosionSfx
@onready var hitbox: Area2D = $Sprite/Hitbox

enum explosionTypes {
	## 1 Damage. Can't destroy anything.
	INSTANT_BANG,
	## 1 Damage. Can cause wood TNT to detonate. Leaves smoke.
	INSTANT_SMOKE,
	## 3 Damage. Can destroy metal blocks.
	INSTANT_ORANGE,
	## 5 Damage. Can destroy big metal blocks.
	INSTANT_RED,
	## 10 Damage. Can destroy terrain.
	INSTANT_BLUE,
	## 4/2 Damage. Can destroy metal blocks.
	LINGERING_ORANGE,
	## 7/4 Damage. Can destroy big metal blocks.
	LINGERING_RED,
	## 13 Damage. Can destroy terrain.
	LINGERING_BLUE
}

## All the explosion types in the game. Currently only the instant orange one is used, but in
## the full game i plan to use all of them. So if you find this, have a nice sneak peak
@export var explosionType: explosionTypes = explosionTypes.INSTANT_ORANGE

var spawnPosition: Vector2
var explosionSize: float
var cantHurtEnzo: bool

func _ready() -> void:
	global_position = spawnPosition
	sprite.scale = Vector2(explosionSize, explosionSize)
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
