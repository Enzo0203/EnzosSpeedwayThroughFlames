extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") - 500

var SPEED = 500

@onready var sprite = $Sprite2D
@onready var label: Label = $Label

@onready var hitbox: Area2D = $Hitbox

var spawnPosition
var launchDirection: Vector2

func _ready():
	if spawnPosition and launchDirection:
		global_position = spawnPosition
		velocity = launchDirection

func _physics_process(delta):
	label.text = str(hitbox.is_monitorable())
	velocity.y += gravity * delta
	$AnimationPlayer.play("ball")
	velocity.x = SPEED * launchDirection.x
	move_and_slide()
	sprite.scale.x = launchDirection.x
	if target_y != null:
		global_position.y = move_toward(global_position.y, target_y, 300 * delta)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("tileset"):
		destroy()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox") or area.is_in_group("hazard"):
		destroy()
	if area.is_in_group("EnzoHitbox"):
		#Check for strength value
		if area.get_meta("strength") - 1 > hitbox.get_meta("strength"):
			#Make it hurt enemies and not you
			hitbox.add_to_group("EnzoHitbox")
			hitbox.set_collision_layer_value(5, true)
			#Flip direction
			if area.get_meta("kbdirection").x < 0:
				launchDirection.x = -1
			else:
				launchDirection.x = 1
			if area.get_meta("type") == "parry":
				#Parry
				gravity = 0
				hitbox.set_meta("dmg", hitbox.get_meta("dmg") + area.get_meta("dmg"))
				if area.get_meta("kbdirection").x > 0:
					SPEED = area.get_meta("kbdirection").x * 5
				else:
					SPEED = area.get_meta("kbdirection").x * -5
				velocity.y = area.get_meta("kbdirection").y * 5
			else:
				#Rebound
				SPEED = area.get_meta("kbdirection").x * Globalvars.EnzoDirection
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
