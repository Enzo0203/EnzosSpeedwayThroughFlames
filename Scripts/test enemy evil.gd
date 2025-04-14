extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var hurtbox: Area2D = $Sprite/Hurtbox
@onready var raycast: RayCast2D = $Sprite/Hurtbox/HitDetector


enum States {IDLE, HURT}

var state = States.IDLE

func change_state(newState):
	state = newState

var hitboxInSight = false

func _physics_process(delta):
	$Label2.text = str(raycast.get_collider())
	match state:
		States.IDLE:
			idle(delta)
		States.HURT:
			hurt(delta)
	move_and_slide()
	if $Sprite.scale.x == -1:
		$Sprite/Hurtbox/HitDetector.scale.x = -1
	else:
		$Sprite/Hurtbox/HitDetector.scale.x = 1

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
	if area.is_in_group("EnzoHitbox") or area.is_in_group("Explosion"):
		# Shoot raycast and check for wall or own hitbox
		raycast.set_collision_mask_value(11, true)
		raycast.target_position = (raycast.global_position - area.global_position) * -1
		await get_tree().process_frame
		if not raycast.is_colliding():
			# No wall, hurt enemy
			change_state(States.HURT)
			velocity = area.get_meta("kbdirection")
			if area.global_position.x >= position.x:
				$Sprite.scale.x = -1
			else:
				$Sprite.scale.x = 1
			print("test dummy hurt")
			$Label.text = "hurt"
		else:
			# Check if wall or own hitbox
			if raycast.get_collider().is_in_group("tileset"):
				# There's a wall
				print("test dummy saved by wall")
				$Label.text = "saved by wall"
			else:
				# Hitbox
				# Check if hitbox is my own
				if raycast.get_collider() == $Sprite/Hitbox and raycast.get_collider().is_in_group("HurtsEnzo"):
					# Compare strength
					if area.get_meta("strength") - 1 < $Sprite/Hitbox.get_meta("strength"):
						# Check for wall again
						raycast.set_collision_mask_value(11, false)
						await get_tree().process_frame
						if not raycast.is_colliding():
							# No wall, Clank
							print("test dummy saved by clank")
							$Label.text = "saved by clank"
							if area.global_position.x >= position.x:
								$Sprite.scale.x = -1
								velocity.x = -300
							else:
								$Sprite.scale.x = 1
								velocity.x = 300
						else:
							# There is a wall
							print("test dummy tried to save clank but stopped by wall")
							$Label.text = "tried save clank but wall"

func _on_hitbox_area_entered(area: Area2D) -> void:
	await get_tree().process_frame
	if area.is_in_group("EnzoHitbox") and hurtbox.has_overlapping_areas() == false:
		# Shoot raycast and check for wall
		raycast.set_collision_mask_value(11, false)
		raycast.global_position = $Sprite/Hitbox.global_position
		raycast.target_position = (raycast.global_position - area.global_position) * -1
		await get_tree().process_frame
		if not raycast.is_colliding():
			# No wall, clank
			print("test dummy clanked")
			$Label.text = "clanked"
			if area.global_position.x >= position.x:
				$Sprite.scale.x = -1
				velocity.x = -300
			else:
				$Sprite.scale.x = 1
				velocity.x = 300
		else:
			# There is a wall
			print("test dummy tried to clank but stopped by wall")
			$Label.text = "tried clank but wall"
