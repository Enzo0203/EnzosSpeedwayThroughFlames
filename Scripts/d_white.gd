extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum States {IDLE, THROWING, RELOADING, HURT, DEAD}

var state = States.IDLE
var is_dead = false

@onready var animation = $AnimationPlayer
@onready var sprite = $Spritesheet
@onready var ball = preload("res://Scenes/EnemyWeapons/white_ball.tscn")
@onready var marker = $Spritesheet/Marker2D
@onready var healthbar: TextureRect = $Health/Health
@onready var healthbarbackdrop: TextureRect = $Health/Healthbackdrop
@onready var stuntimer: Timer = $Stuntimer

@onready var hurtbox: Area2D = $Spritesheet/Hurtbox
@onready var enzoDetector: RayCast2D = $Spritesheet/EnzoDetector


var health = 2

func change_state(newState):
	state = newState

func _ready() -> void:
	healthbarbackdrop.size.x = 24 * health

func _physics_process(delta):
	match state:
		States.IDLE:
			idle(delta)
		States.THROWING:
			throw(delta)
		States.RELOADING:
			reload(delta)
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

var EnzoInArea
var HasBall = true

func idle(delta):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	# What to do
	if global_position.x <= Globalvars.EnzoPosition.x:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1
	velocity.x = move_toward(velocity.x, 0, 500 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if state == States.IDLE:
		if HasBall == false:
			change_state(States.RELOADING)
		if HasBall == true and enzoDetector.is_colliding():
			if enzoDetector.get_collider().is_in_group("PlayerHurtbox"):
				change_state(States.THROWING)
				await get_tree().create_timer(0.6).timeout
				launch_ball()

func throw(delta):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if state == States.THROWING:
		if animation.current_animation != "throw":
			HasBall = false
			change_state(States.RELOADING)

func launch_ball():
	if state == States.THROWING:
		var ball_instance = ball.instantiate()
		ball_instance.instanceSpawnPosition = marker.global_position
		ball_instance.instanceInitVelocity.x = 500 * sprite.scale.x
		get_parent().add_child(ball_instance)

func reload(delta):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if state == States.RELOADING:
		if animation.current_animation != "reload":
			HasBall = true
			if HasBall == true and enzoDetector.is_colliding():
				if enzoDetector.get_collider().is_in_group("PlayerHurtbox"):
					change_state(States.THROWING)
					await get_tree().create_timer(0.6).timeout
					launch_ball()
				else:
					change_state(States.IDLE)
			else:
				change_state(States.IDLE)

var bounceSpeed

func hurt(delta):
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 2000)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if stuntimer.time_left == 0:
		if state == States.HURT:
			if HasBall == true and enzoDetector.is_colliding():
				if enzoDetector.get_collider().is_in_group("PlayerHurtbox"):
					change_state(States.THROWING)
					await get_tree().create_timer(0.6).timeout
					launch_ball()
				else:
					change_state(States.IDLE)
			else:
				change_state(States.IDLE)
	if not is_on_floor() and velocity.y >= 500:
		bounceSpeed = velocity.y
	if velocity.y >= 500:
		if is_on_floor():
			velocity.y = velocity.y / 2 * -1
	if is_on_floor():
		if bounceSpeed:
			velocity.y = bounceSpeed / 2 * -1
			bounceSpeed = null

func dead(delta):
	# What to do
	velocity.y += gravity * delta
	collision_mask = 0

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHitbox") or area.is_in_group("EnvironmentalHitbox"):
		if is_dead == false:
			if health - area.get_meta("dmg") <= 0:
				damage(health)
				change_state(States.DEAD)
			else:
				damage(area.get_meta("dmg"))
				change_state(States.HURT)
			velocity = area.get_meta("kbdirection")
			stuntimer.start()
			hitStop(0.1, 0.3)

func damage(amount):
	health -= amount
	give_score(10 * amount, true)
	addToMiniCombo(amount)

func addToMiniCombo(value: int):
	Globalvars.EnzoMiniCombo += value
	Globalvars.EnzoMiniComboUpdated.emit()

func check_for_death():
	if health <= 0 and is_dead == false:
		health = 0
		change_state(States.DEAD)
		Globalvars.EnzoComboUpdated.emit()
		Globalvars.EnzoCombo += 1
		is_dead = true

func update_animations():
	if state == States.IDLE:
		animation.play("idle")
	if state == States.THROWING:
		animation.play("throw")
	if state == States.RELOADING:
		animation.play("reload")
	if state == States.HURT:
		animation.play("hurt")
	if state == States.DEAD:
		animation.play("dead")

func hitStop(timeScale, duration):
	pass

func randomizeAudioPitch(audio):
	audio.pitch_scale = randf_range(0.7, 1.1)

func set_health():
	healthbar.size.x = 24 * health

func give_score(amount: int, accountForMultiplier: bool) -> void:
	if accountForMultiplier == true:
		Globalvars.EnzoScore += amount * Globalvars.EnzoScoreMultiplier
	else:
		Globalvars.EnzoScore += amount
