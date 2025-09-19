extends CharacterBody2D

@onready var blastbox: Sprite2D = $CompactBlastbox
@onready var blastbox_collision: CollisionShape2D = $CollisionShape2D
@onready var animation: AnimationPlayer = $CompactBlastbox/CpbbAnimationPlayer
@onready var explosionsprite: Sprite2D = $Explosion
@onready var sfx_explode: AudioStreamPlayer2D = $Explosion/ExplosionSfx
@onready var marker: Marker2D = $Marker2D
@onready var explosion_animation: AnimationPlayer = $Explosion/AnimationPlayer
@onready var explosion: Sprite2D = $Explosion

@onready var hurtbox: Area2D = $CompactBlastbox/Hurtbox
@onready var hurtboxshape: CollisionShape2D = $CompactBlastbox/Hurtbox/HurtboxShape

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var instanceSpawnPosition: Vector2
var instanceInitVelocity: Vector2

func _ready() -> void:
	if instanceSpawnPosition and instanceInitVelocity:
		global_position = instanceSpawnPosition
		velocity = instanceInitVelocity
	animation.play("fuse")
	explosion.hide()
	await get_tree().create_timer(3).timeout
	explode()

func _physics_process(delta: float) -> void:
	if explosion.visible == false:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, 900 * delta)
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, 500)
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox"):
		velocity = area.get_meta("kbdirection")

func explode() -> void:
	var exploded: bool = false
	if exploded == false:
		velocity = Vector2(0, 0)
		explosion.show()
		explosion.global_position = marker.global_position
		explosion.scale = Vector2(0.6, 0.6)
		explosion_animation.play("Orange Instant")
		blastbox.hide()
		blastbox_collision.disabled = true
		hurtboxshape.disabled = true
		await get_tree().create_timer(1.1).timeout
		destroy()
		exploded = true

func destroy() -> void:
	hide()
	set_process(false)
