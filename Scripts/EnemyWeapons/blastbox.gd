extends CharacterBody2D

@onready var animation: AnimationPlayer = $Blastbox/BBAnimationPlayer
@onready var marker: Marker2D = $Marker2D

@onready var explosion: PackedScene = preload("res://Scenes/Miscellaneous/explosion.tscn")

@onready var hurtbox: Area2D = $Blastbox/Hurtbox
@onready var hurtboxshape: CollisionShape2D = $Blastbox/Hurtbox/HurtboxShape

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var instanceSpawnPosition: Vector2
var instanceInitVelocity: Vector2

func _ready() -> void:
	if instanceSpawnPosition and instanceInitVelocity:
		global_position = instanceSpawnPosition
		velocity = instanceInitVelocity
	animation.play("fuse")
	await get_tree().create_timer(3).timeout
	explode()

func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 900 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	move_and_slide()

func explode() -> void:
	var explosion_instance: Node = explosion.instantiate()
	explosion_instance.spawnPosition = marker.global_position
	explosion_instance.explosionSize = 0.85
	explosion_instance.cantHurtEnzo = false
	get_parent().add_child(explosion_instance)
	destroy()

func destroy() -> void:
	queue_free()

func _on_hurtbox_hurt(_area: Area2D, _Damage: int, Knockback: Vector2, _DeathType: String) -> void:
	velocity = Knockback
