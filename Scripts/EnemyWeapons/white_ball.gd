extends CharacterBody2D

var gravity: float = 0
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

@onready var hitbox: Area2D = $Hitbox

@onready var hit: AudioStreamPlayer2D = $Hit

var instanceSpawnPosition: Vector2
var instanceInitVelocity: Vector2

func _ready() -> void:
	if instanceSpawnPosition and instanceInitVelocity:
		global_position = instanceSpawnPosition
		velocity = instanceInitVelocity
	gravity = 0
	await get_tree().create_timer(0.3, false).timeout
	if velocity.x > -500 and velocity.x < 500:
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity") - 500

func _physics_process(delta: float) -> void:
	label.text = str(hitbox.is_monitorable())
	velocity.y += gravity * delta
	move_and_slide()
	if velocity.x >= 0:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1

func _on_hitbox_body_entered(_body: Node2D) -> void:
	destroy()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("hazard"):
		destroy()

func destroy() -> void:
	queue_free()

func _on_hitbox_parried(area: Area2D) -> void:
	hitbox.set_collision_layer_value(6, false)
	hitbox.set_collision_layer_value(5, true)
	gravity = 0
	hitbox.Damage = hitbox.Damage + area.Damage
	velocity.x = area.Knockback.x * 5 * area.scale.x
	velocity.y = area.Knockback.y * 5 * area.scale.y

func _on_hitbox_clank(_area: Area2D) -> void:
	destroy()

func _on_hitbox_rebounded(area: Area2D) -> void:
	hitbox.set_collision_layer_value(6, false)
	hitbox.set_collision_layer_value(5, true)
	velocity.x = area.Knockback.x * area.scale.x
	velocity.y = area.Knockback.y * area.scale.y

func _on_hitbox_hurt_something(area: Area2D) -> void:
	if not area.Intangible:
		$Hit.play()
		destroy()
