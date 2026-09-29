extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

enum States {IDLE, JUMPPREP, FALLING, HURT, DEAD}

var state: int = States.IDLE
var is_dead: bool = false

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Spritesheet
@onready var ball: PackedScene = preload("res://Scenes/EnemyWeapons/hellball.tscn")
@onready var marker: Marker2D = $Spritesheet/Marker2D
@onready var stuntimer: Timer = $Stuntimer
@onready var label: Label = $Label

@onready var health_manager: HealthManager = $HealthManager

@onready var hitstopper: Timer = $Hitstopper

@onready var hurtbox: Area2D = $Hurtbox
@onready var enzo_detector: CharacterTracker = $EnzoDetector

func change_state(newState: int) -> void:
	state = newState

func _physics_process(delta: float) -> void:
	if hitstopper.time_left > 0:
		animation.speed_scale = 0
		return
	else:
		animation.speed_scale = 1
	match state:
		States.IDLE:
			idle(delta)
		States.JUMPPREP:
			jumpprep(delta)
		States.FALLING:
			falling(delta)
		States.HURT:
			hurt(delta)
		States.DEAD:
			dead(delta)
	move_and_slide()
	update_animations()
	flip_hitboxes()

var EnzoInArea: bool

func idle(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = move_toward(velocity.x, 0, 1000 * delta)
	# What to do
	if global_position.x <= Globalvars.EnzoPosition.x: # Flip towards Enzo
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1
	# What can this transition to
	if not is_on_floor():
		change_state(States.FALLING)
	if enzo_detector.target:
		change_state(States.JUMPPREP)

var _jump_direction: float = 0
func jumpprep(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = move_toward(velocity.x, 0, 1000 * delta)
	# What to do
	# What can this transition to
	if not is_on_floor():
		change_state(States.FALLING)
	await animation.animation_finished
	if state == States.JUMPPREP:
		_jump_direction = sprite.scale.x
		velocity.x = 150 * sprite.scale.x
		velocity.y = -300

func falling(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	velocity.x = 150 * _jump_direction
	if is_on_floor():
		change_state(States.IDLE)

var bounceSpeed: Variant
func hurt(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 2000)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if stuntimer.time_left == 0:
		if state == States.HURT:
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
	health_manager.deal_damage(amount)
	give_score(10 * amount, true)
	addToMiniCombo(amount)

func addToMiniCombo(value: int) -> void:
	Globalvars.EnzoMiniCombo += value
	Globalvars.EnzoMiniComboUpdated.emit()

func update_animations() -> void:
	match state:
		States.IDLE:
			animation.play("idle")
		States.JUMPPREP:
			animation.play("jumpprep")
		States.FALLING:
			if velocity.y < 0:
				animation.play("rise")
			else:
				animation.play("fall")
		States.HURT:
			animation.play("hurt")
		States.DEAD:
			animation.play("dead")

func hitStop(duration: float) -> void:
	hitstopper.stop()
	await get_tree().process_frame
	hitstopper.wait_time = duration
	hitstopper.start()

func randomizeAudioPitch(audio: AudioStreamPlayer2D) -> void:
	audio.pitch_scale = randf_range(0.7, 1.1)

func give_score(amount: int, accountForMultiplier: bool) -> void:
	if accountForMultiplier == true:
		Globalvars.EnzoScore += roundi(amount * Globalvars.EnzoScoreMultiplier)
	else:
		Globalvars.EnzoScore += amount

func _on_hurtbox_hurt(_area: Area2D, Damage: int, Knockback: Vector2) -> void:
	damage(Damage)
	change_state(States.HURT)
	$PaletteSwapAnims.play("Hurt")
	stuntimer.start()
	await get_tree().process_frame
	velocity = Knockback
	hitStop(min(0.1 * Damage, 0.3))

func _on_health_manager_dead() -> void:
	change_state(States.DEAD)
	give_score(50, true)
	health_manager.health = 0
	Globalvars.EnzoComboUpdated.emit()
	Globalvars.EnzoCombo += 1
	Globalvars.EnzoKills += 1
	is_dead = true

func flip_hitboxes() -> void:
	hurtbox.scale.x = sprite.scale.x
	enzo_detector.scale.x = sprite.scale.x
