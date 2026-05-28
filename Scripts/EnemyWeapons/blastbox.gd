extends CharacterBody2D

@onready var marker: Marker2D = $Marker2D

@onready var explosion: PackedScene = preload("res://Scenes/Miscellaneous/explosion.tscn")

@onready var hurtbox: Area2D = $BlastboxSprite/Hurtbox
@onready var hurtboxshape: CollisionShape2D = $BlastboxSprite/Hurtbox/HurtboxShape

@export var blast_radius: float = 0.5
@export var fuse_length: float = 3

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var instanceSpawnPosition: Vector2
var instanceInitVelocity: Vector2

func _ready() -> void:
	$Trigger.pitch_scale = randf_range(0.9, 1.1)
	if instanceSpawnPosition and instanceInitVelocity:
		global_position = instanceSpawnPosition
		velocity = instanceInitVelocity
	await get_tree().create_timer(fuse_length, false, true).timeout
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
	explosion_instance.explosionSize = blast_radius
	explosion_instance.cantHurtEnzo = false
	get_parent().add_child(explosion_instance)
	destroy()

func destroy() -> void:
	queue_free()

func _on_hurtbox_hurt(_area: Area2D, _Damage: int, Knockback: Vector2, _DeathType: String) -> void:
	velocity = Knockback
