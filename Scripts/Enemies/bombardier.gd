extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.5

enum States {IDLE, JUMPING, THROWING, JUMPTHROWING, BIGTHROWING, HURT, DEAD, AIRWEAVING}

var state: int = States.IDLE
var is_dead: bool = false

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Spritesheet
@onready var marker: Marker2D = $Spritesheet/Marker2D
@onready var marker_2: Marker2D = $Spritesheet/Marker2D2
@onready var healthbar: TextureProgressBar = $Health/HealthBar
@onready var demonheart: Sprite2D = $Health/DemonHeart

@onready var hitstopper: Timer = $Hitstopper
@onready var stuntimer: Timer = $Stuntimer
@onready var jumptimer: Timer = $Jumptimer

@onready var label: Label = $Label
@onready var cpbbcooldown: Timer = $CPBBcooldown
@onready var blastboxcooldown: Timer = $Blastboxcooldown

@onready var hitbox: Area2D = $Hitbox
@onready var hitboxshape: CollisionShape2D = $Hitbox/HitboxShape
@onready var hurtbox: Area2D = $Hurtbox

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
	label.text = str(blastboxcooldown.time_left)
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
		States.AIRWEAVING:
			airweaving(delta)
	move_and_slide()
	update_animations()
	set_health()
	check_for_death()
	flip_hitboxes()

func idle(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	# What to do
	if position.x <= Globalvars.EnzoPosition.x:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1
	# What can this transition to
	if state == States.IDLE:
		if EnzoInArea1 == true and EnzoInArea2 == false and EnzoInArea3 == false:
			if jumptimer.time_left == 0 and is_on_floor():
				change_state(States.JUMPING)
				jumptimer.wait_time = randf_range(0.5, 1.0)
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
		if EnzoInArea1 == true and EnzoInArea2 == true and EnzoInArea3 == true:
			if blastboxcooldown.time_left != 0:
				if jumptimer.time_left == 0 and is_on_floor():
					change_state(States.JUMPING)
					jumptimer.wait_time = randf_range(0.3, 1.0)
					jumptimer.start()
					velocity.y = -400
					if randi_range(0, 1) == 0:
						velocity.x = 150 * sprite.scale.x
					else:
						velocity.x = 150 * sprite.scale.x * -2
			else:
				change_state(States.BIGTHROWING)
				$PaletteSwapAnims.play("Parriable")

func jumping(delta: float) -> void:
	apply_gravity(delta)
	#Transitions
	if state == States.JUMPING:
		if is_on_floor():
			change_state(States.IDLE)
		await get_tree().create_timer(0.3, false).timeout
		if state == States.JUMPING:
			if cpbbcooldown.time_left == 0:
				change_state(States.JUMPTHROWING)

func airweaving(delta: float) -> void:
	apply_gravity(delta)
	if position.x <= Globalvars.EnzoPosition.x:
		sprite.scale.x = 1
	else:
		sprite.scale.x = -1
	#Transitions
	if state == States.AIRWEAVING:
		if is_on_floor():
			change_state(States.IDLE)
		await get_tree().create_timer(0.3, false).timeout
		if state == States.AIRWEAVING:
			if cpbbcooldown.time_left == 0:
				change_state(States.JUMPTHROWING)

func throwing(delta: float) -> void:
	apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if state == States.THROWING:
		await get_tree().create_timer(0.2, false).timeout
		if state == States.THROWING:
			if is_on_floor():
				change_state(States.IDLE)
			else:
				change_state(States.JUMPING)

func jumpthrowing(delta: float) -> void:
	apply_gravity(delta)
	if state == States.JUMPTHROWING:
		await get_tree().create_timer(0.2, false).timeout
		if state == States.JUMPTHROWING:
			if is_on_floor():
				change_state(States.IDLE)
			else:
				change_state(States.JUMPING)

func bigthrowing(delta: float) -> void:
	apply_gravity(delta)
	if animation.current_animation_position < 0.3:
		if position.x <= Globalvars.EnzoPosition.x:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if state == States.BIGTHROWING:
		if animation.is_playing() == false:
			if state == States.BIGTHROWING:
				if is_on_floor():
					change_state(States.IDLE)
				else:
					change_state(States.JUMPING)

@onready var compactblastbox: PackedScene = preload("res://Scenes/EnemyWeapons/compact_blastbox.tscn")
func launch_compact_blastbox() -> void:
	if cpbbcooldown.time_left == 0:
		var compactblastbox_instance: Node = compactblastbox.instantiate()
		compactblastbox_instance.instanceSpawnPosition = marker.global_position
		compactblastbox_instance.instanceInitVelocity = [\
		Vector2(500 * sprite.scale.x, -100),\
		Vector2(300 * sprite.scale.x, -300),\
		Vector2(200 * sprite.scale.x, -400),\
		Vector2(100 * sprite.scale.x, -400)\
		].pick_random()
		get_parent().add_child(compactblastbox_instance)
		cpbbcooldown.start()

@onready var blastbox: PackedScene = preload("res://Scenes/EnemyWeapons/blastbox.tscn")
func launch_blastbox() -> void:
	if blastboxcooldown.time_left == 0:
		var blastbox_instance: Node = blastbox.instantiate()
		blastbox_instance.instanceSpawnPosition = marker_2.global_position
		blastbox_instance.instanceInitVelocity = Vector2(400 * sprite.scale.x, -150)
		get_parent().add_child(blastbox_instance)
		blastboxcooldown.start()

var bounceSpeed: Variant

func hurt(delta: float) -> void:
	apply_gravity(delta, false)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	if stuntimer.time_left == 0:
		if state == States.HURT:
			if is_on_floor():
				if $WallDetector.get_collider() != null:
					velocity.x = 450 * sprite.scale.x
					velocity.y = -500
					GlobalAudioManager.play_audio_2d("res://Sfx/Whoosh.ogg", global_position, 10.0, randf_range(0.9, 1.1))
					change_state(States.AIRWEAVING)
				elif randi_range(0, 2) == 1:
					velocity.x = 450 * sprite.scale.x * -1
					velocity.y = -500
					GlobalAudioManager.play_audio_2d("res://Sfx/Whoosh.ogg", global_position, 10.0, randf_range(0.9, 1.1))
					change_state(States.AIRWEAVING)
				else:
					change_state(States.IDLE)
			else:
				if $WallDetector.get_collider() != null:
					velocity.x = 450 * sprite.scale.x
					GlobalAudioManager.play_audio_2d("res://Sfx/Whoosh.ogg", global_position, 10.0, randf_range(0.9, 1.1))
					change_state(States.AIRWEAVING)
				elif randi_range(0, 2) == 1:
					velocity.x = 450 * sprite.scale.x * -1
					GlobalAudioManager.play_audio_2d("res://Sfx/Whoosh.ogg", global_position, 10.0, randf_range(0.9, 1.1))
					change_state(States.AIRWEAVING)
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

func dead(delta: float) -> void:
	# What to do
	apply_gravity(delta, false)
	collision_mask = 0

func _on_hurtbox_hurt(_area: Area2D, Damage: int, Knockback: Vector2) -> void:
	if is_dead == false:
		if health - Damage <= 0:
			damage(health)
			pr_heart.emitting = true
			pr_hpbar.emitting = true
			change_state(States.DEAD)
			give_score(300, true)
		else:
			damage(Damage)
			change_state(States.HURT)
		$PaletteSwapAnims.play("Hurt")
		velocity = Knockback
		pr_heart.direction = Knockback
		pr_hpbar.direction = Knockback
		stuntimer.start()
		hitStop(min(0.1 * Damage, 0.3))

func _on_hurtbox_parried(_area: Area2D, _range: String) -> void:
	if health - $Hitbox.Damage <= 0:
		damage(health)
	else:
		damage($Hitbox.Damage)
	blastboxcooldown.start()

func damage(amount: int) -> void:
	health -= amount
	give_score(10 * amount, true)
	addToMiniCombo(amount)

func addToMiniCombo(value: int) -> void:
	Globalvars.EnzoMiniCombo += value
	Globalvars.EnzoMiniComboUpdated.emit()

func _on_hitbox_clank(area: Area2D) -> void:
	if area.global_position.x >= position.x:
		$Spritesheet.scale.x = -1
		velocity.x = -300
	else:
		$Spritesheet.scale.x = 1
		velocity.x = 300

func apply_gravity(delta: float, capped: bool = true) -> void:
	velocity.y += gravity * delta
	if capped:
		velocity.y = min(velocity.y, 500)

func flip_hitboxes() -> void:
	$Hurtbox.scale.x = sprite.scale.x
	$Hitbox.scale.x = sprite.scale.x
	$EnzoDetector1.scale.x = sprite.scale.x
	$EnzoDetector2.scale.x = sprite.scale.x
	$EnzoDetector3.scale.x = sprite.scale.x
	$WallDetector.scale.x = sprite.scale.x

func update_animations() -> void:
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
	if state == States.AIRWEAVING:
		animation.play("Jump")
		$AfterImager.active = true
	else:
		$AfterImager.active = false

func hitStop(duration: float) -> void:
	hitstopper.stop()
	await get_tree().process_frame
	hitstopper.wait_time = duration
	hitstopper.start()

#@onready var snackbox: PackedScene = preload("res://Scenes/Items/snackbox.tscn")
func check_for_death() -> void:
	if health <= 0 and is_dead == false:
		health = 0
		change_state(States.DEAD)
		Globalvars.EnzoComboUpdated.emit()
		Globalvars.EnzoCombo += 1
		Globalvars.EnzoKills += 1
		#var snackbox_instance: Node = snackbox.instantiate()
		#snackbox_instance.spawnPosition = hurtbox.global_position
		#get_parent().add_child(snackbox_instance)
		is_dead = true

func randomizeAudioPitch(_audio: String) -> void:
	pass

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

var EnzoInArea1: bool = false
var EnzoInArea2: bool = false
var EnzoInArea3: bool = false

func _on_enzo_detector_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		EnzoInArea1 = true

func _on_enzo_detector_1_area_exited(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		EnzoInArea1 = false

func _on_enzo_detector_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		EnzoInArea2 = true

func _on_enzo_detector_2_area_exited(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		EnzoInArea2 = false

func _on_enzo_detector_3_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		EnzoInArea3 = true

func _on_enzo_detector_3_area_exited(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		EnzoInArea3 = false

func give_score(amount: int, accountForMultiplier: bool) -> void:
	if accountForMultiplier == true:
		Globalvars.EnzoScore += roundi(amount * Globalvars.EnzoScoreMultiplier)
	else:
		Globalvars.EnzoScore += amount

func _on_hitbox_hurt_something(_area: Area2D) -> void:
	GlobalAudioManager.play_audio_2d(hitbox.ImpactSfx.resource_path, hitboxshape.global_position)


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name != "Bigthrow":
		$"Sound Effects/ChargeAttack".stop()
