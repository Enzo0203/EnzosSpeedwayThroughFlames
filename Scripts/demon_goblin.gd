extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum States {IDLE, WALKING, ATTACKPREP, ATTACKING, DEAD}

var state = States.IDLE
var is_dead = false

@onready var animation: AnimationPlayer = $Spritesheet/AnimationPlayer
@onready var sprite: Sprite2D = $Spritesheet
@onready var label: Label = $Label

@onready var hitbox: Area2D = $Spritesheet/Hitbox
@onready var hitboxshape: CollisionShape2D = $Spritesheet/Hitbox/HitboxShape
@onready var hurtbox: Area2D = $Spritesheet/Hurtbox
@onready var raycast: RayCast2D = $Spritesheet/Hurtbox/HitDetector

func change_state(newState):
	state = newState

func _physics_process(delta):
	match state:
		States.IDLE:
			idle(delta)
		States.WALKING:
			walking(delta)
		States.ATTACKPREP:
			attackprep(delta)
		States.ATTACKING:
			attacking(delta)
		States.DEAD:
			dead(delta)
	move_and_slide()
	update_animations()
	if $Spritesheet.scale.x < 0:
		$Spritesheet/Hurtbox/HitDetector.scale.x = -1
	else:
		$Spritesheet/Hurtbox/HitDetector.scale.x = 1

var EnzoInArea: bool = false
var EnzoInArea2: bool = false
var Obstacle: bool

func _on_enzo_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox"):
		EnzoInArea = true

func _on_enzo_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox"):
		EnzoInArea = false

func _on_enzo_detector_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox"):
		EnzoInArea2 = true

func _on_enzo_detector_2_area_exited(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox"):
		EnzoInArea2 = false

func _on_obstacle_detector_body_entered(_body: Node2D) -> void:
	Obstacle = true

func _on_obstacle_detector_body_exited(_body: Node2D) -> void:
	Obstacle = false

func idle(delta):
	# What to do
	velocity.x = move_toward(velocity.x, 0, 500 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if EnzoInArea == true and EnzoInArea2 == false:
		change_state(States.WALKING)
		await get_tree().create_timer(0.6).timeout
	if EnzoInArea2 == true:
		change_state(States.ATTACKPREP)

func walking(delta):
	if Globalvars.EnzoPositionX > position.x:
		velocity.x = move_toward(velocity.x, 200, 1000 * delta)
		sprite.scale.x = 1
	if Globalvars.EnzoPositionX < position.x:
		velocity.x = move_toward(velocity.x, -200, 1000 * delta)
		sprite.scale.x = -1
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, 500)
	else:
		if Obstacle:
			velocity.y = -420
	if EnzoInArea == false:
		change_state(States.IDLE)
	if EnzoInArea2 == true and Obstacle == false and is_on_floor():
		change_state(States.ATTACKPREP)

func attackprep(delta):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = move_toward(velocity.x, 0, 300 * delta)
	if animation.is_playing() == false:
		if state == States.ATTACKPREP:
			change_state(States.ATTACKING)
			velocity.x = 300 * sprite.scale.x

func attacking(delta):
	if state == States.ATTACKING:
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, 500)
		velocity.x = move_toward(velocity.x, 0, 200 * delta)
		if velocity.x > -120 and velocity.x < 120:
			change_state(States.IDLE)

func dead(delta):
	# What to do
	velocity.y += gravity * delta
	collision_mask = 0

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHitbox") or area.is_in_group("Explosion"):
		# Shoot raycast and check for wall or own hitbox
		raycast.set_collision_mask_value(11, true)
		raycast.target_position = (raycast.global_position - area.global_position) * -1
		raycast.force_raycast_update()
		if not raycast.is_colliding():
			# No wall, hurt enemy
				if is_dead == false:
					if area.is_in_group("EnzoHitbox") or area.is_in_group("Explosion"):
						addToMiniCombo(1)
						Globalvars.EnzoScore += 100
						hitStop(0.1, 0.3)
						change_state(States.DEAD)
						velocity = area.get_meta("kbdirection")
						is_dead = true
						Globalvars.EnzoComboUpdated = true
						Globalvars.EnzoCombo += 1
						await get_tree().process_frame
						Globalvars.EnzoComboUpdated = false
		else:
			# Check if wall or own hitbox
			if raycast.get_collider().is_in_group("tileset"):
				# There's a wall
				pass
			else:
				# Hitbox
				# Check if hitbox is my own
				if raycast.get_collider() == $Spritesheet/Hitbox and raycast.get_collider().is_in_group("HurtsEnzo"):
					# Compare strength
					if area.get_meta("strength") - 1 <= $Spritesheet/Hitbox.get_meta("strength"):
						# Check for wall again
						raycast.set_collision_mask_value(11, false)
						raycast.force_raycast_update()
						if not raycast.is_colliding():
							# No wall, Clank
							print("Goblin clank")
							if area.global_position.x >= position.x:
								$Spritesheet.scale.x = 1
								velocity.x = -200
							else:
								$Spritesheet.scale.x = -1
								velocity.x = 200
						else:
							# There is a wall
							pass

func addToMiniCombo(value: int):
	Globalvars.EnzoMiniCombo += value
	Globalvars.EnzoMiniComboUpdated = true
	await get_tree().process_frame
	Globalvars.EnzoMiniComboUpdated = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHitbox") and hurtbox.has_overlapping_areas() == false:
		# Shoot raycast and check for wall
		raycast.set_collision_mask_value(11, false)
		raycast.target_position = (raycast.global_position - area.global_position) * -1
		raycast.force_raycast_update()
		if not raycast.is_colliding():
			# No wall, compare strength
			if area.get_meta("strength") - 1 > hitbox.get_meta("strength"):
				# Insert Minicounter below
				# Parry
				if area.get_meta("type") == "parry":
					if is_dead == false:
						velocity = area.get_meta("kbdirection")
						change_state(States.DEAD)
						Globalvars.EnzoScore += 100
						hitStop(0.1, 0.3)
			else:
				# Clank
				if area.global_position.x >= position.x:
					$Spritesheet.scale.x = 1
					velocity.x = -200
				else:
					$Spritesheet.scale.x = -1
					velocity.x = 200
				hurtboxstun(0.3)
		else:
			# There is a wall
			pass

func update_animations():
	if state == States.IDLE:
		animation.play("idle")
	if state == States.WALKING:
		if is_on_floor():
			animation.play("walk")
		else:
			animation.play("fall")
	if state == States.ATTACKPREP:
		animation.play("attackprep")
	if state == States.ATTACKING:
		animation.play("attack")
	if state == States.DEAD:
		animation.play("dead")

func hitStop(_timeScale, _duration):
	pass

func randomizeAudioPitch(audio):
	audio.pitch_scale = randf_range(0.7, 1.1)

func hurtboxstun(duration):
	hitboxshape.set_deferred("monitorable", false)
	await get_tree().create_timer(duration).timeout
	hitboxshape.set_deferred("monitorable", true)
