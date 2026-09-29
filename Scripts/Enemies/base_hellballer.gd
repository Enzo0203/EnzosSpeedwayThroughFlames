extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

enum States {IDLE, WALKING, THROWING, RELOADING, HURT, DEAD}

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

@onready var enzoDetector2: RayCast2D = $EnzoDetector2
@onready var wall_detector: ShapeCast2D = $WallDetector

func change_state(newState: int) -> void:
	state = newState

func _ready() -> void:
	wall_detector.add_exception(hurtbox)

func _physics_process(delta: float) -> void:
	if hitstopper.time_left > 0:
		animation.speed_scale = 0
		return
	else:
		animation.speed_scale = 1
	if enzoDetector2.get_collider() != null:
		label.text = str(enzoDetector2.get_collider())
	else:
		label.text = "null"
	match state:
		States.IDLE:
			idle(delta)
		States.WALKING:
			walking(delta)
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
	if wall_detector.is_colliding():
		if wall_detector.get_collider(0) is not Hurtbox:
			wall_detector.add_exception(wall_detector.get_collider(0))

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
	# What can this transition to
	if HasBall == false:
		change_state(States.RELOADING)
	if HasBall == true and enzoDetector2.get_collider() != null:
		if enzoDetector2.get_collider().is_in_group("Hurtbox"):
			change_state(States.THROWING)
	if target and wall_detector.is_colliding() == false:
		change_state(States.WALKING)

func walking(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if target:
		if target.global_position.x > global_position.x:
			velocity.x = move_toward(velocity.x, 100, 1000 * delta)
			sprite.scale.x = 1
		if target.global_position.x < global_position.x:
			velocity.x = move_toward(velocity.x, -100, 1000 * delta)
			sprite.scale.x = -1
	
	if wall_detector.is_colliding() or target == null:
		change_state(States.IDLE)
	if HasBall == true and enzoDetector2.get_collider() != null:
		if enzoDetector2.get_collider().is_in_group("Hurtbox"):
			change_state(States.THROWING)

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

enum hellballTypes {WHITE,GREEN,RED,YELLOW,BLUE,BLACK,GOLD,PURPLE}
func launch_ball() -> void:
	if state == States.THROWING:
		var ball_instance: Node = ball.instantiate()
		ball_instance.type = hellballTypes.GREEN
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
			if HasBall == true and enzoDetector2.is_colliding():
				if enzoDetector2.get_collider().is_in_group("Hurtbox"):
					change_state(States.THROWING)
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
			if HasBall == true and enzoDetector2.is_colliding():
				if enzoDetector2.get_collider().is_in_group("Hurtbox"):
					change_state(States.THROWING)
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
	health_manager.deal_damage(amount)
	give_score(10 * amount, true)
	Globalvars.EnzoMiniCombo += amount
	Globalvars.EnzoMiniComboUpdated.emit()

func update_animations() -> void:
	if state == States.IDLE:
		animation.play("idle")
	if state == States.WALKING:
		animation.play("walk")
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

var target: CharacterBody2D
func _on_enzo_detector_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		return
	if area.owner is CharacterBody2D:
		target = area.owner

func _on_enzo_detector_area_exited(area: Area2D) -> void:
	if area is Hitbox:
		return
	if area.owner == target:
		target = null
