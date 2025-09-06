extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") - 500

@onready var sprite = $Sprite2D
@onready var label: Label = $Label

@onready var hitbox: Area2D = $Hitbox

var instanceSpawnPosition
var instanceInitVelocity: Vector2

func _ready():
	if instanceSpawnPosition and instanceInitVelocity:
		global_position = instanceSpawnPosition
		velocity = instanceInitVelocity

func _physics_process(delta):
	label.text = str(hitbox.is_monitorable())
	velocity.y += gravity * delta
	$AnimationPlayer.play("ball")
	move_and_slide()
	if velocity.x >= 0:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1
	if target_y != null:
		global_position.y = move_toward(global_position.y, target_y, 300 * delta)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("EnvironmentalCollision"):
		destroy()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHurtbox") or area.is_in_group("hazard"):
		destroy()
	if area.is_in_group("PlayerHitbox"):
		#Check for strength value
		if area.get_meta("strength") - 1 > hitbox.get_meta("strength"):
			#Make it hurt enemies and not you
			hitbox.add_to_group("PlayerHitbox")
			hitbox.set_collision_layer_value(5, true)
			#Flip direction
			if area.get_meta("type") == "parry":
				#Parry
				gravity = 0
				hitbox.set_meta("dmg", hitbox.get_meta("dmg") + area.get_meta("dmg"))
				velocity.x = area.get_meta("kbdirection").x * 5
				velocity.y = area.get_meta("kbdirection").y * 5
			else:
				#Rebound
				velocity.x = area.get_meta("kbdirection").x
				velocity.y = area.get_meta("kbdirection").y
		else:
			#Clank
			destroy()

var target_y = null

func destroy():
	queue_free()

func hitboxstun(duration):
	hitbox.set_deferred("monitorable", false)
	await get_tree().create_timer(duration).timeout
	hitbox.set_deferred("monitorable", true)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_hurtbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
