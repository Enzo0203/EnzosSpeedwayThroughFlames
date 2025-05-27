extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.5

enum States {IDLE, JUMPING, THROWING, JUMPTHROWING, BIGTHROWING, HURT, DEAD}

var state: int = States.IDLE
var is_dead: bool = false

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Spritesheet
@onready var marker: Marker2D = $Spritesheet/Marker2D
@onready var marker_2: Marker2D = $Spritesheet/Marker2D2
@onready var healthbar: TextureRect = $Health/Health
@onready var healthbarbackdrop: TextureRect = $Health/Healthbackdrop
@onready var healthbar2: TextureRect = $Health/Health2
@onready var healthbarbackdrop2: TextureRect = $Health/Healthbackdrop2
@onready var healthbar3: TextureRect = $Health/Health3
@onready var healthbarbackdrop3: TextureRect = $Health/Healthbackdrop3
@onready var stuntimer: Timer = $Stuntimer
@onready var jumptimer: Timer = $Jumptimer
@onready var label: Label = $Label
@onready var cpbbcooldown: Timer = $CPBBcooldown
@onready var blastboxcooldown: Timer = $Blastboxcooldown

@onready var hitbox: Area2D = $Spritesheet/Hitbox
@onready var hitboxshape: CollisionShape2D = $Spritesheet/Hitbox/HitboxShape
@onready var hurtbox: Area2D = $Spritesheet/Hurtbox

@onready var raycast: RayCast2D = $Spritesheet/Hurtbox/HitDetector
@onready var anticlip: RayCast2D = $Spritesheet/Anticlip


var health: int = 30

func change_state(newState: int) -> void:
	state = newState

func _ready() -> void:
	if health <= 10:
		healthbarbackdrop.size.x = 24 * health
		healthbarbackdrop2.size.x = 0
		healthbarbackdrop3.size.x = 0
	if health > 10 and health <= 20:
		healthbarbackdrop2.size.x = 24 * (health - 10)
		healthbarbackdrop3.size.x = 0
	if health > 20 and health <= 30:
		healthbarbackdrop3.size.x = 24 * (health - 20)

func _physics_process(delta: float) -> void:
	label.text = str(health)
	match state:
		States.IDLE:
			idle(delta)
		States.JUMPING:
			jumping(delta)
		States.THROWING:
			throwing(delta)
		States.JUMPTHROWING:
			jumpthrowing(delta)
		States.BIGTHROWING:
			bigthrowing(delta)
		States.HURT:
			hurt(delta)
		States.DEAD:
			dead(delta)
	move_and_slide()
	update_animations()
	set_health()
	check_for_death()
	if $Spritesheet.scale.x == -1:
		$Spritesheet/Hurtbox/HitDetector.scale.x = -1
	else:
		$Spritesheet/Hurtbox/HitDetector.scale.x = 1

func idle(delta: float):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 600)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	# What to do
	if position.x <= Globalvars.EnzoPositionX:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1
	# What can this transition to
	if state == States.IDLE:
		if EnzoInArea1 == true and EnzoInArea2 == false and EnzoInArea3 == false:
			if jumptimer.time_left == 0 and is_on_floor():
				change_state(States.JUMPING)
				jumptimer.wait_time = randi_range(0.5, 1)
				jumptimer.start()
				velocity.y = -600
				velocity.x = 50 * sprite.scale.x
		if EnzoInArea1 == true and EnzoInArea2 == true and EnzoInArea3 == false:
			if jumptimer.time_left == 0 and is_on_floor():
				change_state(States.JUMPING)
				jumptimer.wait_time = randi_range(1, 2)
				jumptimer.start()
				velocity.y = -400
				velocity.x = 150 * sprite.scale.x
			if cpbbcooldown.time_left == 0:
				change_state(States.THROWING)
				launch_compact_blastbox()
		if EnzoInArea1 == true and EnzoInArea2 == true and EnzoInArea3 == true:
			if jumptimer.time_left == 0 and blastboxcooldown.time_left != 0 and is_on_floor():
				change_state(States.JUMPING)
				jumptimer.wait_time = randi_range(0.3, 1)
				jumptimer.start()
				velocity.y = -400
				if randi_range(0, 1) == 0:
					velocity.x = 150 * sprite.scale.x
				else:
					velocity.x = 150 * sprite.scale.x * -2
			if blastboxcooldown.time_left == 0:
				change_state(States.BIGTHROWING)

func jumping(delta: float):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	#Transitions
	if state == States.JUMPING:
		if is_on_floor():
			change_state(States.IDLE)
		await get_tree().create_timer(0.3).timeout
		if state == States.JUMPING:
			if cpbbcooldown.time_left == 0:
				change_state(States.JUMPTHROWING)
				launch_compact_blastbox()

func throwing(delta: float):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if state == States.THROWING:
		await get_tree().create_timer(0.2).timeout
		if state == States.THROWING:
			if is_on_floor():
				change_state(States.IDLE)
			else:
				change_state(States.JUMPING)

func jumpthrowing(delta: float):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if state == States.JUMPTHROWING:
		await get_tree().create_timer(0.2).timeout
		if state == States.JUMPTHROWING:
			if is_on_floor():
				change_state(States.IDLE)
			else:
				change_state(States.JUMPING)

func bigthrowing(delta: float):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if state == States.BIGTHROWING:
		await get_tree().create_timer(0.75).timeout
		if state == States.BIGTHROWING and animation.current_animation_position > 0.75:
			launch_blastbox()
			blastboxcooldown.start()
			await get_tree().create_timer(0.25).timeout
			if state == States.BIGTHROWING:
				if is_on_floor():
					change_state(States.IDLE)
				else:
					change_state(States.JUMPING)

@onready var compactblastbox = preload("res://Scenes/compact_blastbox.tscn")
func launch_compact_blastbox():
	if cpbbcooldown.time_left == 0:
		var compactblastbox_instance = compactblastbox.instantiate()
		compactblastbox_instance.spawnPosition = marker.global_position
		compactblastbox_instance.launchDirection = Vector2(-500 * sprite.scale.x, -100)
		get_parent().add_child(compactblastbox_instance)
		cpbbcooldown.start()

@onready var blastbox = preload("res://Scenes/blastbox.tscn")
func launch_blastbox():
	if blastboxcooldown.time_left == 0:
		var blastbox_instance = blastbox.instantiate()
		blastbox_instance.spawnPosition = marker_2.global_position
		blastbox_instance.launchDirection = Vector2(-400 * sprite.scale.x, -150)
		get_parent().add_child(blastbox_instance)
		blastboxcooldown.start()

var bounceSpeed

func hurt(delta: float):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 2000)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if stuntimer.time_left == 0:
		if state == States.HURT:
			if is_on_floor():
				change_state(States.IDLE)
			else:
				change_state(States.JUMPING)
	if not is_on_floor() and velocity.y >= 500:
		bounceSpeed = velocity.y
	if velocity.y >= 500:
		if is_on_floor():
			velocity.y = velocity.y / 2 * -1
	if is_on_floor():
		if bounceSpeed:
			velocity.y = bounceSpeed / 2 * -1
			bounceSpeed = null

func dead(delta: float):
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
					if health - area.get_meta("dmg") <= 0:
						change_state(States.DEAD)
					else:
						change_state(States.HURT)
					velocity = area.get_meta("kbdirection")
					stuntimer.start()
					Globalvars.EnzoScore += 100
					hitStop(0.1, 0.3)
					if hurtbox.get_meta("state") == "parriable" and area.get_meta("type") == "parry":
						if health - area.get_meta("dmg") <= 0:
							addToMiniCombo(health)
						else:
							addToMiniCombo(hitbox.get_meta("dmg"))
						health -= hitbox.get_meta("dmg")
						blastboxcooldown.start()
					else:
						if health - area.get_meta("dmg") <= 0:
							addToMiniCombo(health)
						else:
							addToMiniCombo(area.get_meta("dmg"))
						health -= area.get_meta("dmg")
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
					if area.get_meta("strength") - 1 < $Spritesheet/Hitbox.get_meta("strength"):
						# Check for wall again
						raycast.set_collision_mask_value(11, false)
						raycast.force_raycast_update()
						if not raycast.is_colliding():
							# No wall, Save clank
							print("bombarSaveClank")
							if area.global_position.x >= position.x:
								$Spritesheet.scale.x = -1
								velocity.x = -300
							else:
								$Spritesheet.scale.x = 1
								velocity.x = 300
						else:
							# There is a wall
							print("bombarFailClankWall")
							pass

func addToMiniCombo(value: int):
	Globalvars.EnzoMiniCombo += value
	Globalvars.EnzoMiniComboUpdated.emit()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHitbox") and hurtbox.has_overlapping_areas() == false:
		# Shoot raycast and check for wall
		raycast.set_collision_mask_value(11, false)
		raycast.target_position = (raycast.global_position - area.global_position) * -1
		raycast.force_raycast_update()
		if not raycast.is_colliding():
			# No wall, compare strength
			if area.get_meta("strength") - 1 > hitbox.get_meta("strength"):
				# Minicounter
				if area.get_meta("type") == "parry":
					if is_dead == false:
						velocity = area.get_meta("kbdirection")
						change_state(States.HURT)
						stuntimer.start()
						Globalvars.EnzoScore += 100
						hitStop(0.1, 0.3)
						health -= hitbox.get_meta("dmg")
			else:
				# Clank
				print("bombarClank")
				if area.global_position.x >= position.x:
					$Spritesheet.scale.x = -1
					velocity.x = -300
				else:
					$Spritesheet.scale.x = 1
					velocity.x = 300
		else:
			# There is a wall
			pass

func update_animations():
	if state == States.IDLE:
		animation.play("Idle")
	if state == States.JUMPING:
		animation.play("Jump")
	if state == States.THROWING:
		animation.play("Throw")
	if state == States.JUMPTHROWING:
		animation.play("JumpThrow")
	if state == States.BIGTHROWING:
		animation.play("Bigthrow")
	if state == States.HURT:
		animation.play("Hurt")
	if state == States.DEAD:
		animation.play("Dead")

func hitStop(_timeScale, _duration):
	pass

@onready var snackbox = preload("res://Scenes/Items/snackbox.tscn")
func check_for_death():
	if health <= 0 and is_dead == false:
		health = 0
		change_state(States.DEAD)
		Globalvars.EnzoComboUpdated.emit()
		Globalvars.EnzoCombo += 1
		var snackbox_instance = snackbox.instantiate()
		snackbox_instance.spawnPosition = hurtbox.global_position
		get_parent().add_child(snackbox_instance)
		is_dead = true

func randomizeAudioPitch(_audio):
	pass

func set_health():
	if health <= 10:
		healthbar.size.x = 24 * health
		healthbar2.size.x = 0
		healthbar3.size.x = 0
	if health > 10 and health <= 20:
		healthbar2.size.x = 24 * (health - 10)
		healthbar3.size.x = 0
	if health > 20 and health <= 30:
		healthbar3.size.x = 24 * (health - 20)

var EnzoInArea1 = false
var EnzoInArea2 = false
var EnzoInArea3 = false
var HasBall = true

func _on_enzo_detector_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox"):
		EnzoInArea1 = true

func _on_enzo_detector_1_area_exited(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox"):
		EnzoInArea1 = false

func _on_enzo_detector_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox"):
		EnzoInArea2 = true

func _on_enzo_detector_2_area_exited(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox"):
		EnzoInArea2 = false

func _on_enzo_detector_3_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox"):
		EnzoInArea3 = true

func _on_enzo_detector_3_area_exited(area: Area2D) -> void:
	if area.is_in_group("EnzoHurtbox"):
		EnzoInArea3 = false
