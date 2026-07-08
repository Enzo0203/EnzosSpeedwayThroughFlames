extends CharacterBody2D

var gravity: float = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox
@onready var hitboxshape: CollisionShape2D = $Hitbox/HitboxShape
@onready var hitstopper: Timer = $Hitstopper

enum hellballTypes {
	## Disappears on contact with tileset or enemy.
	WHITE,
	## Bounces off walls and ceilings, can bounce off the floor once.
	GREEN,
	## Same as green, but homes towards an enemy when bouncing.
	RED,
	## Same as red, but homes towards an enemy at all times and can bounce off the floor thrice.
	YELLOW,
	## Same as white, but flies, slowly dashing towards an enemy. Regains gravity after 3 seconds.
	BLUE,
	## Same as white, but explodes instead of disappearing.
	BLACK,
	## Combination of red and black.
	GOLD,
	## Combination of blue and black.
	PURPLE
}

## All the hellball types in the game. Currently only the white one is used, but in
## the full game i plan to use all of them. So if you find this, have a nice sneak peak
@export var type: hellballTypes = hellballTypes.WHITE

var dissappearsOnHurtingSomething: bool = true
var floorBouncesRemaining: int = 0

var instanceSpawnPosition: Vector2
var instanceInitVelocity: Vector2

func _ready() -> void:
	if instanceSpawnPosition and instanceInitVelocity:
		global_position = instanceSpawnPosition
		velocity = instanceInitVelocity
	gravity = 0
	await get_tree().create_timer(0.3, false).timeout
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity") - 500

func _physics_process(delta: float) -> void:
	if hitstopper.time_left > 0:
		animation.speed_scale = 0
		return
	else:
		animation.speed_scale = 1
	label.text = str(hitbox.is_monitorable())
	velocity.y += gravity * delta
	move_and_slide()
	destroy_when_hitting_tileset()

# Hit/hurtbox functions

func _on_hitbox_parried(area: Area2D, _range: String) -> void:
	$AfterimageAnims.play("Parried")
	hitbox.set_collision_layer_value(6, false)
	hitbox.set_collision_layer_value(5, true)
	hitbox.set_collision_mask_value(5, false)
	hitbox.set_collision_mask_value(6, true)
	hitStop(0.25)
	gravity = 0
	hitbox.Damage = hitbox.Damage + area.Damage
	velocity.x = area.Knockback.x * 5 * area.scale.x
	velocity.y = area.Knockback.y * 5 * area.scale.y
	await get_tree().physics_frame
	hitbox.Strength = hitbox.Strength + area.Strength

func _on_hitbox_clank(_area: Area2D) -> void:
	destroy()

func _on_hitbox_rebounded(area: Area2D) -> void:
	hitbox.collision_layer = 0
	hitbox.collision_layer = area.collision_layer
	hitbox.collision_mask = 0
	hitbox.collision_mask = area.collision_mask
	velocity.x = area.Knockback.x * area.scale.x
	velocity.y = area.Knockback.y * area.scale.y

func _on_hitbox_hurt_something(_area: Area2D) -> void:
	GlobalAudioManager.play_audio_2d(hitbox.ImpactSfx.resource_path, hitboxshape.global_position, 0, randf_range(0.9, 1.1))
	if hitbox.get_collision_layer_value(6) == true:
		destroy()

func _on_hitbox_blocked(_area: Area2D) -> void:
	destroy()

# Misc functions

func destroy_when_hitting_tileset() -> void:
	if is_on_floor() or is_on_wall() or is_on_ceiling():
		destroy()

func destroy() -> void:
	queue_free()

func hitStop(duration: float) -> void:
	hitstopper.stop()
	await get_tree().process_frame
	hitstopper.wait_time = duration
	hitstopper.start()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destroy()
