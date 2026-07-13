extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

enum States {IDLE, THROWING, RELOADING, HURT, DEAD}

var state: int = States.IDLE
var is_dead: bool = false

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Spritesheet
@onready var ball: PackedScene = preload("res://Scenes/EnemyWeapons/white_ball.tscn")
@onready var marker: Marker2D = $Spritesheet/Marker2D
@onready var healthbar: TextureProgressBar = $Health/HealthBar
@onready var demonheart: Sprite2D = $Health/DemonHeart
@onready var stuntimer: Timer = $Stuntimer
@onready var label: Label = $Label

@onready var hitstopper: Timer = $Hitstopper

@onready var hurtbox: Area2D = $Hurtbox
@onready var enzoDetector: RayCast2D = $EnzoDetector

@export var health: int
@export var maxHealth: int

@onready var pr_heart: CPUParticles2D = $Health/DemonHeartParticle
@onready var pr_hpbar: CPUParticles2D = $Health/HealthBarParticle

func change_state(newState: int) -> void:
	state = newState

func _physics_process(delta: float) -> void:
	if hitstopper.time_left > 0:
		animation.speed_scale = 0
		return
	else:
		animation.speed_scale = 1
	if enzoDetector.get_collider() != null:
		label.text = str(enzoDetector.get_collider())
	else:
		label.text = "null"
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
	flip_hitboxes()

var EnzoInArea: bool
var HasBall: bool = true

func idle(delta: float) -> void:
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
		if HasBall == true and enzoDetector.get_collider() != null:
			if enzoDetector.get_collider().is_in_group("Hurtbox"):
				change_state(States.THROWING)
				await get_tree().create_timer(1.0, false).timeout
				launch_ball()

func throw(delta: float) -> void:
	if animation.current_animation_position <= 0.1:
		if global_position.x <= Globalvars.EnzoPosition.x:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if state == States.THROWING:
		if animation.current_animation != "throw":
			HasBall = false
			change_state(States.RELOADING)

func launch_ball() -> void:
	if state == States.THROWING:
		var ball_instance: Node = ball.instantiate()
		ball_instance.instanceSpawnPosition = marker.global_position
		ball_instance.instanceInitVelocity.x = 400 * sprite.scale.x
		get_parent().add_child(ball_instance)

func reload(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if state == States.RELOADING:
		if animation.current_animation != "reload":
			HasBall = true
			if HasBall == true and enzoDetector.is_colliding():
				if enzoDetector.get_collider().is_in_group("Hurtbox"):
					change_state(States.THROWING)
					await get_tree().create_timer(1.0, false).timeout
					launch_ball()
				else:
					change_state(States.IDLE)
			else:
				change_state(States.IDLE)

var bounceSpeed: Variant

func hurt(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 2000)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if stuntimer.time_left == 0:
		if state == States.HURT:
			if HasBall == true and enzoDetector.is_colliding():
				if enzoDetector.get_collider().is_in_group("Hurtbox"):
					change_state(States.THROWING)
					await get_tree().create_timer(1.0, false).timeout
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

func dead(delta: float) -> void:
	# What to do
	velocity.y += gravity * delta
	collision_mask = 0

func damage(amount: int) -> void:
	health -= amount
	give_score(10 * amount, true)
	addToMiniCombo(amount)

func addToMiniCombo(value: int) -> void:
	Globalvars.EnzoMiniCombo += value
	Globalvars.EnzoMiniComboUpdated.emit()

func check_for_death() -> void:
	if health <= 0 and is_dead == false:
		health = 0
		change_state(States.DEAD)
		Globalvars.EnzoComboUpdated.emit()
		Globalvars.EnzoCombo += 1
		Globalvars.EnzoKills += 1
		is_dead = true

func update_animations() -> void:
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

func hitStop(duration: float) -> void:
	hitstopper.stop()
	await get_tree().process_frame
	hitstopper.wait_time = duration
	hitstopper.start()

func randomizeAudioPitch(audio: AudioStreamPlayer2D) -> void:
	audio.pitch_scale = randf_range(0.7, 1.1)

func set_health() -> void:
	$Health/HealthBar.value = health
	if health == maxHealth:
		healthbar.visible = false
		demonheart.visible = false
	else:
		if not is_dead:
			healthbar.visible = true
			demonheart.visible = true
		else:
			healthbar.visible = false
			demonheart.visible = false

func give_score(amount: int, accountForMultiplier: bool) -> void:
	if accountForMultiplier == true:
		Globalvars.EnzoScore += roundi(amount * Globalvars.EnzoScoreMultiplier)
	else:
		Globalvars.EnzoScore += amount

func _on_hurtbox_hurt(_area: Area2D, Damage: int, Knockback: Vector2) -> void:
	if is_dead == false:
		if health - Damage <= 0:
			damage(health)
			pr_heart.emitting = true
			pr_hpbar.emitting = true
			change_state(States.DEAD)
			give_score(50, true)
		else:
			damage(Damage)
			change_state(States.HURT)
		$PaletteSwapAnims.play("Hurt")
		velocity = Knockback
		pr_heart.direction = Knockback
		pr_hpbar.direction = Knockback
		stuntimer.start()
		hitStop(min(0.1 * Damage, 0.3))

func flip_hitboxes() -> void:
	hurtbox.scale.x = sprite.scale.x
	enzoDetector.scale.x = sprite.scale.x
