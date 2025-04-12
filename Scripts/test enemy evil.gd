extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var hurtbox: Area2D = $Sprite/Hurtbox
@onready var raycast: RayCast2D = $Sprite/Hurtbox/RayCast2D


enum States {IDLE, HURT}

var state = States.IDLE

func change_state(newState):
	state = newState

var hitboxInSight = false

func _physics_process(delta):
	match state:
		States.IDLE:
			idle(delta)
		States.HURT:
			hurt(delta)
	move_and_slide()
	if $Sprite.scale.x == -1:
		$Sprite/Hurtbox/RayCast2D.scale.x = -1
	else:
		$Sprite/Hurtbox/RayCast2D.scale.x = 1

func idle(delta):
	# What to do
	velocity.x = move_toward(velocity.x, 0, 500 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 2000)
	# What can this transition to

var bounceSpeed

func hurt(delta):
	velocity.x = move_toward(velocity.x, 0, 500 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 2000)
	# What to do
	if not is_on_floor() and velocity.y >= 500:
		bounceSpeed = velocity.y
	if velocity.y >= 500:
		if is_on_floor():
			velocity.y = velocity.y / 2 * -1
	if is_on_floor():
		if bounceSpeed:
			velocity.y = bounceSpeed / 2 * -1
			bounceSpeed = null
	await get_tree().create_timer(0.2).timeout
	# What can this transition to
	change_state(States.IDLE)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHitbox"):
		raycast.set_collision_mask_value(11, true)
		raycast.target_position = (raycast.global_position - area.global_position) * -1
		await get_tree().process_frame
		if not raycast.is_colliding():
			change_state(States.HURT)
			velocity = area.get_meta("kbdirection")
			if area.global_position.x >= position.x:
				$Sprite.scale.x = -1
			else:
				$Sprite.scale.x = 1
			print("test dummy hurt")
			$Label.text = "hurt"
		else:
			if raycast.get_collider().is_in_group("tileset"):
				print("test dummy saved by wall")
				$Label.text = "saved by wall"
			else:
				if raycast.get_collider().is_in_group("HurtsEnzo") and area.get_meta("strength") - 1 < $Sprite/Hitbox.get_meta("strength"):
					raycast.set_collision_mask_value(11, false)
					raycast.target_position = (raycast.global_position - area.global_position) * -1
					await get_tree().process_frame
					if not raycast.is_colliding():
						print("test dummy saved by clank")
						$Label.text = "saved by clank"
						if area.global_position.x >= position.x:
							$Sprite.scale.x = -1
							velocity.x = -300
						else:
							$Sprite.scale.x = 1
							velocity.x = 300
					else:
						print("test dummy tried to save clank but stopped by wall")
						$Label.text = "tried save clank but wall"

func _on_hitbox_area_entered(area: Area2D) -> void:
	await get_tree().process_frame
	if area.is_in_group("EnzoHitbox") and hurtbox.has_overlapping_areas() == false:
		raycast.set_collision_mask_value(11, false)
		raycast.global_position = $Sprite/Hitbox.global_position
		raycast.target_position = (raycast.global_position - area.global_position) * -1
		await get_tree().process_frame
		if not raycast.is_colliding():
			print("test dummy clanked")
			$Label.text = "clanked"
			if area.global_position.x >= position.x:
				$Sprite.scale.x = -1
				velocity.x = -300
			else:
				$Sprite.scale.x = 1
				velocity.x = 300
		else:
			print("test dummy tried to clank but stopped by wall")
			$Label.text = "tried clank but wall"
