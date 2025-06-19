extends CharacterBody2D

@onready var blastbox: Sprite2D = $CompactBlastbox
@onready var blastbox_collision: CollisionShape2D = $CollisionShape2D
@onready var animation = $CompactBlastbox/CpbbAnimationPlayer
@onready var explosionsprite = $Explosion
@onready var sfx_explode = $Explosion/ExplosionSfx
@onready var marker: Marker2D = $Marker2D
@onready var explosion_animation: AnimationPlayer = $Explosion/AnimationPlayer
@onready var explosion: Sprite2D = $Explosion

@onready var hurtbox = $CompactBlastbox/Hurtbox
@onready var hurtboxshape = $CompactBlastbox/Hurtbox/HurtboxShape

var collidingWith = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var spawnPosition
var launchDirection: Vector2

func _ready() -> void:
	if spawnPosition and launchDirection:
		global_position = spawnPosition
		velocity = launchDirection
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

func explode():
	var exploded = false
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

func destroy():
	hide()
	set_process(false)
