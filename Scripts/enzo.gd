extends CharacterBody2D
class_name player

const SPEED: float = 300.0
const RUNNING_SPEED: float = 900.0
const ACCELERATION: float = 1000
const RUNNING_ACCELERATION: float = 1500
const FRICTION: float = 600
const HALTING_FRICTION: float = 1000
const JUMP_VELOCITY: float = -370.0
const RUNNING_JUMP_VELOCITY: float = -530.0
var health: int = Globalvars.EnzoHealth
var healtharr: Array = Globalvars.EnzoHealthArr
var regen: int = Globalvars.EnzoRegen
var regenarr: Array = Globalvars.EnzoRegenArr
var regenstate: String = "noregen"

var skateboard: Area2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var spritesheet: Sprite2D = $Spritesheet
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var invincibility_timer: Timer = $Invincibility
@onready var lava_invincibility: Timer = $LavaInvincibility
@onready var punchcooldown: Timer = $Punchcooldown
@onready var regentimer: Timer = $Regentimer
@onready var blocktimer: Timer = $Blocktimer
@onready var labelstate: Label = $State
@onready var labelspeed: Label = $Speed
@onready var labelthird: Label = $Slabel
@onready var marker: Marker2D = $Marker2D
@onready var pr_clank: CPUParticles2D = $Spritesheet/Texts/Clank
@onready var pr_rebound: CPUParticles2D = $Spritesheet/Texts/Rebound
@onready var pr_parry: CPUParticles2D = $Spritesheet/Texts/Parry

@onready var hurtbox: Area2D = $Spritesheet/Hurtbox
@onready var hitbox: Area2D = $Spritesheet/Hitbox
@onready var hitboxshape: CollisionShape2D = $Spritesheet/Hitbox/HitboxShape
@onready var raycast: RayCast2D = $Spritesheet/Hurtbox/HitDetector

enum States {IDLE, JUMPING, FALLING, WALKING, RUNNING, SPRINTING, JUMPSPRINTING, FALLSPRINTING, HALTING, CHARGEPUNCHING, PUNCHINGWEAK, PUNCHINGMID, PUNCHINGSTRONG, HURT, DEAD, BURNJUMPING, BURNRUNNING, CROUCHPREP, CROUCHING, BLOCKING, BLOCKHIT, GROUNDPOUNDPREP, GROUNDPOUND, GROUNDPOUNDLAND, WALLKICKING, SKATING, SKATECROUCHPREP, SKATECROUCHING, SKATEJUMP, SKATEJUMPDETATCH, SIDESWEEP, PARRYFORWARDS, PARRYFUPWARDS, PARRYUPWARDS, SPRINTPUNCHING, KICK, PUNCH2, AIRSTOMPPREP, AIRSTOMPHOLD, AIRSTOMPREL, DROPKICKPREP, DROPKICKHOLD, DROPKICKREL, SPIKER1, SPIKER2, AIRJAB, BLOCKPREP, BLOCKPERFECT, BLOCKREL}

var state: int = States.IDLE

func change_state(newState: int) -> void:
	state = newState

func change_hp(new_health: int) -> void:
	health = new_health

func change_regen(new_regen: int) -> void:
	regen = new_regen

func force_damage() -> void:
	change_hp(health - 1)
	heart_hit()
	if regentimer.time_left > 0:
		regenstate = "regenbroken"
		change_regen(regen - 1)
		regenarr[regen] = 0
		if regen != 0:
			regenarr[0] = 1
		regentimer.wait_time = 6
		regentimer.start()
	if health > 0:
		Globalvars.EnzoHurt = true
		await get_tree().process_frame
		Globalvars.EnzoHurt = false

func check_and_damage(doHitStop: bool, makeInvincible: bool, scoreDeduction: int) -> void:
	if invincibility_timer.time_left == 0.0:
		force_damage()
		if Globalvars.EnzoScore - scoreDeduction >= 0:
			Globalvars.EnzoScore -= scoreDeduction
		else:
			Globalvars.EnzoScore = 0
		if makeInvincible == true:
			if health >= 1:
				modulate = Color(1, 1, 1, 0.7)
				invincibility_timer.wait_time = 2
				invincibility_timer.start()
		if doHitStop == true:
			hitStop(0.5, 0.5)
	if health <= 0:
		hitStop(0.3, 1.0)

func check_for_death() -> void:
	if health <= 0:
		health = 0
		healtharr = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
		change_state(States.DEAD)

func heart_hit() -> void:
	healtharr[health] = 1

func heart_heal(amount: int) -> void:
	if amount == 1:
		healtharr[health] = 3
	if amount == 2:
		healtharr[health] = 3
		healtharr[health + 1] = 3
	if amount == 3:
		healtharr[health] = 3
		healtharr[health + 1] = 3
		healtharr[health + 2] = 3
	if amount == 4:
		healtharr[health] = 3
		healtharr[health + 1] = 3
		healtharr[health + 2] = 3
		healtharr[health + 3] = 3
	if amount == 5:
		healtharr[health] = 3
		healtharr[health + 1] = 3
		healtharr[health + 2] = 3
		healtharr[health + 3] = 3
		healtharr[health + 4] = 3

func regen_give(amount: int) -> void:
	if amount == 1:
		regenarr[regen] = 1
	if amount == 2:
		regenarr[regen] = 1
		regenarr[regen + 1] = 1
	if amount == 3:
		regenarr[regen] = 1
		regenarr[regen + 1] = 1
		regenarr[regen + 2] = 1
	if amount == 4:
		regenarr[regen] = 1
		regenarr[regen + 1] = 1
		regenarr[regen + 2] = 1
		regenarr[regen + 3] = 1
	if amount == 5:
		regenarr[regen] = 1
		regenarr[regen + 1] = 1
		regenarr[regen + 2] = 1
		regenarr[regen + 3] = 1
		regenarr[regen + 4] = 1

func check_and_regen() -> void:
	if health < 5 and regen > 0 and regenstate == "noregen":
		regentimer.wait_time = 5
		regenarr[0] = 2
		regentimer.start()
		regenstate = "regen"
	if regentimer.time_left <= 5 and regenstate == "regenbroken":
		print("i am placing blocks n shit")
		regenstate = "regen"
		regentimer.wait_time = 5
		regenarr[0] = 2
	if regentimer.time_left == 0 and regenstate == "regen":
		print("uff referencia")
		heart_heal(1)
		change_hp(health + 1)
		change_regen(regen - 1)
		regenarr[regen] = 0
		regenstate = "noregen"
	if health == 5 or regen == 0:
		if regen != 0:
			regenarr[0] = 1
		regentimer.stop()
		regenstate = "noregen"

func _ready() -> void:
	animation.speed_scale = 1

# Runs every frame
func _physics_process(delta: float) -> void:
	Globalvars.EnzoState = state
	Globalvars.EnzoVelocity = velocity.x
	Globalvars.EnzoPositionX = global_position.x
	Globalvars.EnzoPositionY = global_position.y
	Globalvars.EnzoHealth = health
	Globalvars.EnzoHealthArr = healtharr
	Globalvars.EnzoRegen = regen
	Globalvars.EnzoRegenArr = regenarr
	Globalvars.EnzoRegenState = regenstate
	labelstate.text = str(raycast.get_collider())
	labelspeed.text = str(velocity.y)
	labelthird.text = str(regentimer.time_left)
	if velocity.x > 100 and velocity.x < 800:
		Globalvars.EnzoMovement = 1
	elif velocity.x < -100 and velocity.x > -800:
		Globalvars.EnzoMovement = -1
	elif velocity.x >= 800:
		Globalvars.EnzoMovement = 2
	elif velocity.x <= -800:
		Globalvars.EnzoMovement = -2
	else:
		Globalvars.EnzoMovement = 0
	Globalvars.EnzoDirection = $Spritesheet.scale.x
	var INPUT_AXIS:float = Input.get_axis("ui_left", "ui_right")
	match state:
		States.IDLE:
			idle(delta, INPUT_AXIS)
		States.JUMPING:
			jumping(INPUT_AXIS)
		States.FALLING:
			falling(delta, INPUT_AXIS)
		States.WALKING:
			walking(delta, INPUT_AXIS)
		States.RUNNING:
			running(delta, INPUT_AXIS)
		States.SPRINTING:
			sprinting(delta, INPUT_AXIS)
		States.JUMPSPRINTING:
			jumpsprinting()
		States.FALLSPRINTING:
			fallsprinting(delta, INPUT_AXIS)
		States.HALTING:
			halting(delta, INPUT_AXIS)
		States.CHARGEPUNCHING:
			chargepunching(delta, INPUT_AXIS)
		States.PUNCHINGWEAK:
			punchingweak(delta, INPUT_AXIS)
		States.PUNCHINGMID:
			punchingmid(delta, INPUT_AXIS)
		States.PUNCHINGSTRONG:
			punchingstrong(delta, INPUT_AXIS)
		States.HURT:
			hurt(delta, INPUT_AXIS)
		States.DEAD:
			dead(delta)
		States.BURNJUMPING:
			burnjumping(delta, INPUT_AXIS)
		States.BURNRUNNING:
			burnrunning(delta)
		States.CROUCHPREP:
			crouchprep(delta, INPUT_AXIS)
		States.CROUCHING:
			crouching(delta, INPUT_AXIS)
		States.BLOCKING:
			blocking(delta, INPUT_AXIS)
		States.BLOCKHIT:
			blockhit(delta, INPUT_AXIS)
		States.GROUNDPOUNDPREP:
			gpoundprep(delta, INPUT_AXIS)
		States.GROUNDPOUND:
			groundpounding(delta, INPUT_AXIS)
		States.GROUNDPOUNDLAND:
			groundpoundland(delta, INPUT_AXIS)
		States.WALLKICKING:
			wallkicking(delta, INPUT_AXIS)
		States.SKATING:
			skating(delta, INPUT_AXIS)
		States.SKATECROUCHPREP:
			skatecrouchprep(delta, INPUT_AXIS)
		States.SKATECROUCHING:
			skatecrouching(delta, INPUT_AXIS)
		States.SKATEJUMP:
			skatejumping(delta, INPUT_AXIS)
		States.SKATEJUMPDETATCH:
			skatedetachjumping(delta, INPUT_AXIS)
		States.PARRYFORWARDS:
			parryforwards(delta, INPUT_AXIS)
		States.PARRYFUPWARDS:
			parryfupwards(delta, INPUT_AXIS)
		States.PARRYUPWARDS:
			parryupwards(delta, INPUT_AXIS)
		States.SPRINTPUNCHING:
			sprintpunch(delta, INPUT_AXIS)
		States.KICK:
			kick(delta, INPUT_AXIS)
		States.PUNCH2:
			punch2(delta, INPUT_AXIS)
		States.AIRSTOMPPREP:
			airstompprep(delta, INPUT_AXIS)
		States.AIRSTOMPHOLD:
			airstomphold(delta, INPUT_AXIS)
		States.AIRSTOMPREL:
			airstomping(delta, INPUT_AXIS)
		States.DROPKICKPREP:
			dropkickprep(delta, INPUT_AXIS)
		States.DROPKICKHOLD:
			dropkickhold(delta, INPUT_AXIS)
		States.DROPKICKREL:
			dropkicking(delta, INPUT_AXIS)
		States.SPIKER1:
			spiking1(delta, INPUT_AXIS)
		States.SPIKER2:
			spiking2(delta, INPUT_AXIS)
		States.AIRJAB:
			airjabbing(delta, INPUT_AXIS)
		States.BLOCKPREP:
			blockprep(delta, INPUT_AXIS)
		States.BLOCKPERFECT:
			blockperfect(delta, INPUT_AXIS)
		States.BLOCKREL:
			blockrelease(delta, INPUT_AXIS)
	update_animations(INPUT_AXIS)
	check_for_death()
	attachToBoard()
	check_and_regen()
	if is_on_floor():
		canEnzoStomp = true
		$Spritesheet/Walljumpdetector/Walljumpdetector.disabled = true
	else:
		$Spritesheet/Walljumpdetector/Walljumpdetector.disabled = false
	# Higher gravity when falling, Even higher if sprinting
	if velocity.y <= 0:
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	else:
		if state != States.FALLSPRINTING:
			gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.5
		else:
			gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2
	# Coyote Jump Timer Start
	var was_on_floor: bool = is_on_floor()
	move_and_slide()
	var just_left_ledge: bool = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	if invincibility_timer.time_left == 0.0:
		modulate = Color(1, 1, 1)
	if $Spritesheet/Walljumpdetector.has_overlapping_bodies():
		canWallJump = true
	else:
		canWallJump = false
	if $Spritesheet.scale.x == -1:
		$Spritesheet/Hurtbox/HitDetector.scale.x = -1
	else:
		$Spritesheet/Hurtbox/HitDetector.scale.x = 1

# Explode for no fucking reason
@onready var explosion: PackedScene = preload("res://Scenes/explosion.tscn")
func spontaniously_combust() -> void:
	var exploded: bool = false
	if exploded == false:
		var explosion_instance: Node = explosion.instantiate()
		explosion_instance.spawnPosition = marker.global_position
		explosion_instance.explosion_size = 0.5
		get_parent().add_child(explosion_instance)
		exploded = true

# Moves

func idle(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	# What can this transition to
	if state == States.IDLE:
		if INPUT_AXIS != 0:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)
		if is_on_floor():
			if Input.is_action_just_pressed("character_z"):
				change_state(States.JUMPING)
			if Input.is_action_just_pressed("character_x"):
				change_state(States.CHARGEPUNCHING)
			if Input.is_action_just_pressed("character_s"):
				change_state(States.KICK)
			if Input.is_action_just_pressed("character_c"):
				if INPUT_AXIS != 0:
					if not Input.is_action_pressed("ui_up"):
						change_state(States.PARRYFORWARDS)
					else:
						change_state(States.PARRYFUPWARDS)
				else:
					if Input.is_action_pressed("ui_up"):
						change_state(States.PARRYUPWARDS)
					else:
						blocktimer.start()
						change_state(States.BLOCKPREP)
			if Input.is_action_just_pressed("ui_down"):
				change_state(States.CROUCHPREP)

func jumping(INPUT_AXIS: float) -> void:
	# What to do
	velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("character_z") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	randomizeAudioPitch($"Spritesheet/Sound effects/Jump", 0.3)
	# Transitions
	if Input.is_action_just_pressed("character_x"):
		if INPUT_AXIS != 0:
			change_state(States.SPIKER1)
		else:
			change_state(States.AIRJAB)
	await get_tree().create_timer(0.1).timeout
	# What can this transition to after the 0.1 delay
	if state == States.JUMPING:
		if not is_on_floor():
			change_state(States.FALLING)
		else:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)

func falling(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# Cut off jump when button released, keep in mind in Godot the Y axis is reverted.
	if Input.is_action_just_released("character_z") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	if not Input.is_action_pressed("character_z") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	if Input.is_action_just_pressed("character_z"):
		if canWallJump and is_on_wall() and INPUT_AXIS != 0:
			velocity.x = 500 * $Spritesheet.scale.x * -1
			velocity.y = -250
			change_state(States.WALLKICKING)
	if Input.is_action_pressed("ui_down"):
		if Input.is_action_just_pressed("character_z"):
			change_state(States.GROUNDPOUNDPREP)
		if Input.is_action_just_pressed("character_s") and canEnzoStomp == true:
			velocity.y = -400
			change_state(States.AIRSTOMPPREP)
	if Input.is_action_just_pressed("character_x"):
		if INPUT_AXIS != 0:
			change_state(States.SPIKER1)
		else:
			change_state(States.AIRJAB)
	if Input.is_action_just_pressed("character_c"):
		if INPUT_AXIS != 0:
			if not Input.is_action_pressed("ui_up"):
				change_state(States.PARRYFORWARDS)
			else:
				change_state(States.PARRYFUPWARDS)
		else:
			if Input.is_action_pressed("ui_up"):
				change_state(States.PARRYUPWARDS)
			else:
				pass
	if state == States.FALLING:
		if is_on_floor():
			change_state(States.IDLE)
			squish()
		if coyote_jump_timer.time_left > 0.0:
			if Input.is_action_pressed("character_z"):
				change_state(States.JUMPING)

func walking(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	if state == States.WALKING:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		if not is_on_floor():
			change_state(States.FALLING)
		if Input.is_action_pressed("character_a"):
			change_state(States.RUNNING)
		if is_on_floor():
			if Input.is_action_just_pressed("character_z"):
				change_state(States.JUMPING)
			if Input.is_action_just_pressed("character_x"):
				change_state(States.CHARGEPUNCHING)
			if Input.is_action_just_pressed("character_s"):
				change_state(States.KICK)
			if Input.is_action_just_pressed("character_c"):
				if not Input.is_action_pressed("ui_up"):
					change_state(States.PARRYFORWARDS)
				else:
					change_state(States.PARRYFUPWARDS)
			if Input.is_action_just_pressed("ui_down"):
				change_state(States.CROUCHPREP)

func running(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * INPUT_AXIS, RUNNING_ACCELERATION * delta)
	# What can this transition to
	if state == States.RUNNING:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		if velocity.x > 800 or velocity.x < -800:
			change_state(States.SPRINTING)
		if not is_on_floor():
			change_state(States.FALLING)
		if not Input.is_action_pressed("character_a"):
			change_state(States.WALKING)
		if is_on_floor():
			if Input.is_action_just_pressed("character_z"):
				change_state(States.JUMPING)
			if Input.is_action_just_pressed("character_x"):
				change_state(States.CHARGEPUNCHING)
			if Input.is_action_just_pressed("character_s"):
				change_state(States.KICK)
			if Input.is_action_just_pressed("character_c"):
				if INPUT_AXIS != 0:
					if not Input.is_action_pressed("ui_up"):
						change_state(States.PARRYFORWARDS)
					else:
						change_state(States.PARRYFUPWARDS)
				else:
					if Input.is_action_pressed("ui_up"):
						change_state(States.PARRYUPWARDS)
					else:
						blocktimer.start()
						change_state(States.BLOCKPREP)
			if Input.is_action_just_pressed("ui_down"):
				change_state(States.CROUCHPREP)

func sprinting(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * INPUT_AXIS, RUNNING_ACCELERATION * delta)
	# What can this transition to
	if state == States.SPRINTING:
		if INPUT_AXIS == 0:
			change_state(States.HALTING)
		if not is_on_floor():
			change_state(States.FALLSPRINTING)
		if not Input.is_action_pressed("character_a"):
			change_state(States.HALTING)
		if velocity.x < 600 and velocity.x > -600:
			change_state(States.HALTING)
		if velocity.x > 0 and INPUT_AXIS == -1:
			change_state(States.HALTING)
		if velocity.x < 0 and INPUT_AXIS == 1:
			change_state(States.HALTING)
		if Input.is_action_pressed("character_z"):
			change_state(States.JUMPSPRINTING)
		if Input.is_action_pressed("character_x"):
			change_state(States.SPRINTPUNCHING)
		if Input.is_action_just_pressed("character_s"):
			change_state(States.DROPKICKPREP)
			velocity.x += 150 * $Spritesheet.scale.x
			velocity.y = -300

func jumpsprinting() -> void:
	# What to do
	velocity.y = RUNNING_JUMP_VELOCITY
	if Input.is_action_just_released("character_z") and velocity.y < RUNNING_JUMP_VELOCITY / 2:
		velocity.y = RUNNING_JUMP_VELOCITY / 2
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	if not is_on_floor():
		change_state(States.FALLSPRINTING)
	if Input.is_action_pressed("character_x"):
		change_state(States.SPRINTPUNCHING)
	if Input.is_action_just_pressed("character_s"):
		if Input.is_action_pressed("ui_down"):
			if canEnzoStomp:
				change_state(States.AIRSTOMPPREP)
		else:
			change_state(States.DROPKICKPREP)

func fallsprinting(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if Input.is_action_just_released("character_z") and velocity.y < RUNNING_JUMP_VELOCITY / 2:
		velocity.y = RUNNING_JUMP_VELOCITY / 2
	if not Input.is_action_pressed("character_z") and velocity.y < RUNNING_JUMP_VELOCITY / 2:
		velocity.y = RUNNING_JUMP_VELOCITY / 2
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	if is_on_floor():
		squish()
		if velocity.x > 600 or velocity.x < -600:
			change_state(States.SPRINTING)
		if velocity.x > 0 and INPUT_AXIS == -1:
			change_state(States.HALTING)
		if velocity.x < 0 and INPUT_AXIS == 1:
			change_state(States.HALTING)
	if velocity.x < 600 and velocity.x > -600:
		change_state(States.FALLING)
	if coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("character_z"):
			change_state(States.JUMPSPRINTING)
	if Input.is_action_pressed("character_x"):
			change_state(States.SPRINTPUNCHING)
	if Input.is_action_just_pressed("character_s"):
		if Input.is_action_pressed("ui_down"):
			if canEnzoStomp:
				change_state(States.AIRSTOMPPREP)
		else:
			change_state(States.DROPKICKPREP)

func sprintpunch(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * INPUT_AXIS, RUNNING_ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Midpunch"
	directionalKnockback(1000, -500, true)
	#Transitions
	if state == States.SPRINTPUNCHING:
		if animation.is_playing() == false:
			if INPUT_AXIS == 0:
				change_state(States.HALTING)
			if not is_on_floor():
				change_state(States.FALLSPRINTING)
			if not Input.is_action_pressed("character_a"):
				change_state(States.HALTING)
			else:
				change_state(States.SPRINTING)
		if velocity.x < 600 and velocity.x > -600:
			change_state(States.HALTING)
		if velocity.x > 0 and INPUT_AXIS == -1:
			change_state(States.HALTING)
		if velocity.x < 0 and INPUT_AXIS == 1:
			change_state(States.HALTING)
		if is_on_floor():
			if Input.is_action_just_pressed("character_z"):
				change_state(States.JUMPSPRINTING)

func dropkickprep(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, 800 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	if animation.is_playing() == false:
		if state == States.DROPKICKPREP:
			if not is_on_floor():
				change_state(States.DROPKICKHOLD)
			else:
				if velocity.x > -600 and velocity.x < 600:
					if INPUT_AXIS == 0:
						change_state(States.IDLE)
					else:
						change_state(States.WALKING)
				else:
					change_state(States.SPRINTING)

func dropkickhold(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, 800 * delta)
	velocity.y += gravity / 2 * delta
	velocity.y = min(velocity.y, 500)
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	if state == States.DROPKICKHOLD:
		if not is_on_floor():
			if not Input.is_action_pressed("character_s"):
				change_state(States.DROPKICKREL)
		else:
			if Input.is_action_just_pressed("character_z"):
				change_state(States.JUMPSPRINTING)
			else:
				if velocity.x > -600 and velocity.x < 600:
					if INPUT_AXIS == 0:
						change_state(States.IDLE)
					else:
						change_state(States.WALKING)
				else:
					change_state(States.SPRINTING)

func dropkicking(delta: float, INPUT_AXIS: float) -> void:
	velocity.y += gravity / 2 * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Kick"
	directionalKnockback(1300, -100, true)
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	if state == States.DROPKICKREL:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		if animation.is_playing() == false:
			if not is_on_floor():
				change_state(States.FALLING)
			else:
				if velocity.x > -600 and velocity.x < 600:
					if INPUT_AXIS == 0:
						change_state(States.IDLE)
					else:
						change_state(States.WALKING)
				else:
					change_state(States.SPRINTING)

func halting(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, 0, HALTING_FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func chargepunching(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if Input.is_action_pressed("character_x") == false:
		if animation.current_animation_position < 0.4 or animation.current_animation_position > 0.7:
				change_state(States.PUNCHINGWEAK)
				punchcooldown.start()
		if animation.current_animation_position >= 0.4 and animation.current_animation_position < 0.6:
				change_state(States.PUNCHINGMID)
		if animation.current_animation_position >= 0.6 and animation.current_animation_position <= 0.7:
				hitStop(0.1, 0.5)
				change_state(States.PUNCHINGSTRONG)
		if animation.is_playing() == false:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
			if not is_on_floor():
				change_state(States.FALLING)

func punchingweak(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Weakpunch"
	directionalKnockback(300, -150, true)
	# What can this transition to
	if state == States.PUNCHINGWEAK:
		if animation.is_playing() == false:
			if is_on_floor():
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)
			else:
				change_state(States.FALLING)
		if punchcooldown.time_left > 0:
			if Input.is_action_just_pressed("character_x") and is_on_floor():
				await get_tree().create_timer(punchcooldown.time_left).timeout
				if state == States.PUNCHINGWEAK and is_on_floor():
					punchcooldown.start()
					change_state(States.PUNCH2)
		else:
			if Input.is_action_just_pressed("character_x") and is_on_floor():
				punchcooldown.start()
				change_state(States.PUNCH2)

func punch2(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Weakpunch"
	directionalKnockback(300, -200, true)
	# What can this transition to
	if state == States.PUNCH2:
		if animation.is_playing() == false:
			if is_on_floor():
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)
			else:
				change_state(States.FALLING)
		if punchcooldown.time_left > 0:
			if Input.is_action_just_pressed("character_x") and is_on_floor():
				await get_tree().create_timer(punchcooldown.time_left).timeout
				if state == States.PUNCH2 and is_on_floor():
					punchcooldown.start()
					change_state(States.PUNCHINGWEAK)
		else:
			if Input.is_action_just_pressed("character_x") and is_on_floor():
				punchcooldown.start()
				change_state(States.PUNCHINGWEAK)

func punchingmid(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Midpunch"
	directionalKnockback(500, -200, true)
	# What can this transition to
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func punchingstrong(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Midpunch"
	directionalKnockback(500, -250, true)
	# What can this transition to
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func airjabbing(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Midpunch"
	directionalKnockback(350, -200, true)
	# What can this transition to
	if state == States.AIRJAB:
		if animation.is_playing() == false:
			if is_on_floor():
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)
			else:
				change_state(States.FALLING)
		if animation.get_current_animation_position() >= 0.1 and is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
				squish()
			else:
				change_state(States.WALKING)
				squish()

func parryforwards(delta: float, INPUT_AXIS: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Weakpunch"
	directionalKnockback(200, 0, true)
	# What can this transition to
	if state == States.PARRYFORWARDS:
		if animation.is_playing() == false:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
			if not is_on_floor():
				change_state(States.FALLING)

func parryfupwards(delta: float, INPUT_AXIS: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Weakpunch"
	directionalKnockback(200, -200, true)
	# What can this transition to
	if state == States.PARRYFUPWARDS:
		if animation.is_playing() == false:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
			if not is_on_floor():
				change_state(States.FALLING)

func parryupwards(delta: float, INPUT_AXIS: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Weakpunch"
	directionalKnockback(0, -200, true)
	# What can this transition to
	if state == States.PARRYUPWARDS:
		if animation.is_playing() == false:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
			if not is_on_floor():
				change_state(States.FALLING)

func spiking1(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Weakpunch"
	directionalKnockback(100, -500, true)
	# Transitions
	if animation.is_playing() == false:
		if state == States.SPIKER1:
			if not is_on_floor():
				change_state(States.SPIKER2)
	if is_on_floor():
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
			squish()
		else:
			change_state(States.WALKING)
			squish()

func spiking2(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Midpunch"
	directionalKnockback(400, 1000, true)
	# Transitions
	if animation.is_playing() == false:
		if state == States.SPIKER2:
			if not is_on_floor():
				change_state(States.FALLING)
			else:
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)

func kick(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Kick"
	directionalKnockback(400, -400, true)
	# What can this transition to
	if state == States.KICK:
		if animation.is_playing() == false:
			if is_on_floor():
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)
			else:
				change_state(States.FALLING)

var canEnzoStomp: bool

func airstompprep(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if state == States.AIRSTOMPPREP:
			if not is_on_floor():
				change_state(States.AIRSTOMPHOLD)
			else:
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)

func airstomphold(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if is_on_floor():
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
	elif not Input.is_action_pressed("character_s"):
		change_state(States.AIRSTOMPREL)
		velocity.y =+ 200

func airstomping(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	hitSoundType = $"Spritesheet/Sound effects/Kick"
	directionalKnockback(100, 700, true)
	# What can this transition to
	if animation.is_playing() == false:
		canEnzoStomp = false
		if state == States.AIRSTOMPREL:
			if not is_on_floor():
				change_state(States.FALLING)
			else:
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)

var collidingWithHurtbox: bool = false
var collidingWithLava: bool = false
var radical: bool = false
var isOnBoard: bool = false
var justJumpedOffBoard: bool = false
var canWallJump: bool = false
var howToDie: String
@onready var hitSoundType: AudioStreamPlayer2D = $"Spritesheet/Sound effects/Weakpunch"

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("HurtsEnzo") or area.is_in_group("Explosion"):
		# Shoot raycast and check for wall or own hitbox
		raycast.set_collision_mask_value(5, true)
		raycast.target_position = (raycast.global_position - area.global_position) * -1
		raycast.force_raycast_update()
		if raycast.is_colliding() == false:
			#No wall
			if area.is_in_group("HurtsEnzo") or area.is_in_group("Explosion"):
				# Flip sprite
				if area.global_position.x >= global_position.x:
					$Spritesheet.scale.x = 1
				else:
					$Spritesheet.scale.x = -1
				if invincibility_timer.time_left == 0.0:
					if hurtbox.get_meta("state") == "blocking":
						#Block
						change_state(States.BLOCKHIT)
						blocktimer.start()
						Globalvars.EnzoScore += 25
					elif hurtbox.get_meta("state") == "vuln":
						#Hurt
						howToDie = area.get_meta("deathtype")
						change_state(States.HURT)
						check_and_damage(true, true, 200)
						if health >= 1:
							velocity.y = -300
				if hurtbox.get_meta("state") == "blockingperfect":
						#Perfect Block
						change_state(States.BLOCKPERFECT)
						invincibility_timer.wait_time = 0.6
						invincibility_timer.start()
						blocktimer.stop()
						Globalvars.EnzoScore += 25
		else:
			# Check if wall or own hitbox
			if raycast.get_collider() != null and raycast.get_collider().is_in_group("tileset"):
				# There's a wall
				pass
			else:
				# Hitbox
				# Check if hitbox is my own
				if raycast.get_collider() == $Spritesheet/Hitbox and raycast.get_collider().is_in_group("EnzoHitbox"):
					# Compare strength
					if area.get_meta("strength") - 1 < $Spritesheet/Hitbox.get_meta("strength"):
						# Check for wall again
						raycast.set_collision_mask_value(5, false)
						raycast.force_raycast_update()
						if not raycast.is_colliding():
							# No wall, Clank
							if area.global_position.x >= position.x:
								$Spritesheet.scale.x = -1
								velocity.x = -300
							else:
								$Spritesheet.scale.x = 1
								velocity.x = 300
						else:
							# There is a wall
							pass
	elif area.is_in_group("Lava"):
		if lava_invincibility.time_left == 0:
			howToDie = "burn"
			change_state(States.BURNJUMPING)
			if area.global_position.y > global_position.y:
				velocity.y = -800
			else:
				velocity.y = 800
			lava_invincibility.start()
			check_and_damage(false, false, 200)
	elif area.is_in_group("Skateboard"):
		isOnBoard = true
		if radical == false and justJumpedOffBoard == false:
			velocity.x = 0
			radical = true
		change_state(States.SKATING)
		skateboard = area
		add_child(skateboard)
	elif area.is_in_group("Heal"):
		if health + area.get_meta("heal") > 5:
			if regen + (area.get_meta("heal") - (5 - health)) > 5:
				regen_give(5 - regen)
				change_regen(regen + (5 - regen)) 
			else:
				regen_give(area.get_meta("heal") - (5 - health))
				change_regen(regen + (area.get_meta("heal") - (5 - health))) 
			heart_heal(5 - health)
			change_hp(health + (5 - health))
		else:
			heart_heal(area.get_meta("heal"))
			change_hp(health + area.get_meta("heal"))
		Globalvars.EnzoHeal = true
		await get_tree().process_frame
		Globalvars.EnzoHeal = false

func _on_hurtbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("Skateboard"):
		isOnBoard = false
		skateboard = area
		remove_child(skateboard)
		if state != States.SKATEJUMPDETATCH:
			radical = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("HurtsEnzo"):
		if hitbox.get_meta("strength") - 1 > area.get_meta("strength"):
			if hitbox.get_meta("type") == "norm":
				#Rebound
				pr_rebound.position = hitboxshape.position
				pr_rebound.set_emitting(true)
			if hitbox.get_meta("type") == "parry":
				#Projectile Parry
				Globalvars.EnzoScore += 100
				pr_parry.set_emitting(true)
		else:
			#Clank
			print("Enzo has clanked")
			if area.global_position.x >= position.x:
				$Spritesheet.scale.x = 1
				velocity.x = -300
			else:
				$Spritesheet.scale.x = -1
				velocity.x = 300
			hurtboxstun(0.3)
			pr_clank.position = hitboxshape.position
			pr_clank.set_emitting(true)
	if hitbox.get_meta("type") == "parry":
		if area.get_meta("state") == "parriable":
			#Melee parry
			Globalvars.EnzoScore += 100
			pr_parry.set_emitting(true)
	if area.is_in_group("EnemyHurtbox"):
		randomizeAudioPitch(hitSoundType, 0.3)
		hitSoundType.play()

func hurt(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	if $Spritesheet.scale.x == 1:
		velocity.x = -500
	elif $Spritesheet.scale.x == -1:
		velocity.x = 500
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	await get_tree().create_timer(0.45).timeout
	if state == States.HURT:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func dead(delta: float) -> void:
	$Spritesheet/Hurtbox/HurtboxShape.disabled = true
	velocity.x = move_toward(velocity.x, 0, 300 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)

func burnjumping(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What this can transition to
	if state == States.BURNJUMPING:
		if is_on_floor():
			squish()
			change_state(States.BURNRUNNING)

func burnrunning(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * Globalvars.EnzoDirection, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What this can transition to
	if state == States.BURNRUNNING:
		if Input.is_action_pressed("character_z") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		await get_tree().create_timer(1.0).timeout
		if state == States.BURNRUNNING:
			check_and_damage(false, true, 200)
		await get_tree().create_timer(0.5).timeout
		if state == States.BURNRUNNING:
			change_state(States.HALTING)

func crouchprep(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false or Input.is_action_just_released("ui_down"):
		if state == States.CROUCHPREP:
			if Input.is_action_pressed("ui_down"):
				change_state(States.CROUCHING)
			else:
				if is_on_floor():
					if INPUT_AXIS == 0:
						change_state(States.IDLE)
					else:
						change_state(States.WALKING)
				else:
					change_state(States.FALLING)

func crouching(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if state == States.CROUCHING:
		if Input.is_action_just_released("ui_down"):
			if is_on_floor():
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)
			else:
				change_state(States.FALLING)

func blocking(delta: float, _INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if blocktimer.time_left == 0:
		if state == States.BLOCKING:
			change_state(States.BLOCKREL)

func blockhit(delta: float, _INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if $Spritesheet.scale.x == 1:
		velocity.x = -50
	elif $Spritesheet.scale.x == -1:
		velocity.x = 50
	# What can this transition to
	if animation.is_playing() == false:
		change_state(States.BLOCKING)

func blockprep(delta: float, _INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if state == States.BLOCKPREP:
			change_state(States.BLOCKING)

func blockperfect(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if state == States.BLOCKPERFECT:
		if not is_on_floor():
			change_state(States.FALLING)
		if is_on_floor():
			if Input.is_action_just_pressed("character_z"):
				change_state(States.JUMPING)
			if Input.is_action_just_pressed("character_x"):
				change_state(States.CHARGEPUNCHING)
			if Input.is_action_just_pressed("character_s"):
				change_state(States.KICK)
			if Input.is_action_just_pressed("character_c"):
				if INPUT_AXIS != 0:
					if not Input.is_action_pressed("ui_up"):
						change_state(States.PARRYFORWARDS)
					else:
						change_state(States.PARRYFUPWARDS)
				else:
					if Input.is_action_pressed("ui_up"):
						change_state(States.PARRYUPWARDS)
					else:
						blocktimer.start()
						change_state(States.BLOCKPREP)
			if Input.is_action_just_pressed("ui_down"):
				change_state(States.CROUCHPREP)
	if state == States.BLOCKPERFECT:
		await get_tree().create_timer(0.6).timeout
		if state == States.BLOCKPERFECT:
			if is_on_floor():
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)
			else:
				change_state(States.FALLING)

func blockrelease(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if state == States.BLOCKREL:
			if is_on_floor():
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)
			else:
				change_state(States.FALLING)

func gpoundprep(delta: float, INPUT_AXIS: float) -> void:
	velocity.y = -200
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if state == States.GROUNDPOUNDPREP:
			if not is_on_floor():
				change_state(States.GROUNDPOUND)
			else:
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)

func groundpounding(delta: float, INPUT_AXIS: float) -> void:
	hitSoundType = $"Spritesheet/Sound effects/Midpunch"
	directionalKnockback(200, velocity.y, true)
	if velocity.y > 300:
		hitbox.set_meta("dmg", int(velocity.y / 120))
		hitbox.set_meta("strength", int(velocity.y / 120))
		hitbox.set_meta("dmg", min(10, hitbox.get_meta("dmg")))
		hitbox.set_meta("strength", min(10, hitbox.get_meta("strength")))
	else:
		hitbox.set_meta("dmg", 2)
		hitbox.set_meta("strength", 2)
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	# What can this transition to
	if state == States.GROUNDPOUND:
		if is_on_floor():
			change_state(States.GROUNDPOUNDLAND)

func groundpoundland(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	hitSoundType = $"Spritesheet/Sound effects/Kick"
	directionalKnockback(200, -100, true)
	velocity.x = 0
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What this can transition to
	if state == States.GROUNDPOUNDLAND:
		await get_tree().create_timer(0.24).timeout
		if state == States.GROUNDPOUNDLAND:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
			if not is_on_floor():
				change_state(States.FALLING)

func wallkicking(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What this can transition to
	if state == States.WALLKICKING:
		if Input.is_action_pressed("ui_down"):
			if Input.is_action_just_pressed("character_z"):
				change_state(States.GROUNDPOUNDPREP)
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		await get_tree().create_timer(0.24).timeout
		if state == States.WALLKICKING:
			if is_on_floor():
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)
			else:
				change_state(States.FALLING)

func skating(_delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = 0
	# Transitions
	if Input.is_action_just_pressed("character_z"):
		change_state(States.SKATEJUMPDETATCH)
		velocity.y = -400
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.SKATECROUCHPREP)
	if radical == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func skatecrouchprep(_delta: float, INPUT_AXIS: float) -> void:
	velocity.x = 0
	if Input.is_action_just_pressed("character_z"):
		change_state(States.SKATEJUMP)
	if Input.is_action_just_released("ui_down"):
		change_state(States.SKATING)
	if animation.is_playing() == false:
		if state == States.SKATECROUCHPREP:
			change_state(States.SKATECROUCHING)
	if radical == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func skatecrouching(_delta: float, INPUT_AXIS: float) -> void:
	velocity.x = 0
	if Input.is_action_just_pressed("character_z"):
		change_state(States.SKATEJUMP)
	if Input.is_action_just_released("ui_down"):
		change_state(States.SKATING)
	if radical == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func skatejumping(_delta: float, INPUT_AXIS: float) -> void:
	if animation.is_playing() == false:
		if state == States.SKATEJUMP:
			if Input.is_action_pressed("ui_down"):
				change_state(States.SKATECROUCHING)
			else:
				change_state(States.SKATING)
	if radical == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func skatedetachjumping(delta: float, INPUT_AXIS: float) -> void:
	justJumpedOffBoard = true
	velocity.x = 330 * Globalvars.EnzoDirection
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# Transitions
	if state == States.SKATEJUMPDETATCH:
		if is_on_floor():
			if isOnBoard == true:
				change_state(States.SKATING)
			elif INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
			squish()
		if Input.is_action_pressed("ui_down"):
			if Input.is_action_just_pressed("character_z"):
				change_state(States.GROUNDPOUNDPREP)
			if Input.is_action_just_pressed("character_s") and canEnzoStomp == true:
				velocity.y = -400
				change_state(States.AIRSTOMPPREP)
		if Input.is_action_just_pressed("character_x"):
			if INPUT_AXIS != 0:
				change_state(States.SPIKER1)
			else:
				change_state(States.AIRJAB)
		if Input.is_action_just_pressed("character_c"):
			if INPUT_AXIS != 0:
				if not Input.is_action_pressed("ui_up"):
					change_state(States.PARRYFORWARDS)
				else:
					change_state(States.PARRYFUPWARDS)
			else:
				if Input.is_action_pressed("ui_up"):
					change_state(States.PARRYUPWARDS)
				else:
					pass
	await get_tree().create_timer(0.3).timeout
	justJumpedOffBoard = false

func update_animations(INPUT_AXIS: float) -> void:
	if state == States.IDLE:
		if Globalvars.EnzoCombo < 3:
			animation.play("idle")
		else:
			animation.play("idle2")
	if state == States.JUMPING:
		animation.play("jump")
	if state == States.FALLING:
		if INPUT_AXIS != 0:
			$Spritesheet.scale.x = INPUT_AXIS
		if velocity.y < 0:
			animation.play("rise")
		else:
			animation.play("fall")
	if state == States.WALKING:
		if INPUT_AXIS != 0:
			$Spritesheet.scale.x = INPUT_AXIS
		animation.play("walk")
	if state == States.RUNNING:
		if INPUT_AXIS != 0:
			$Spritesheet.scale.x = INPUT_AXIS
		animation.play("run")
	if state == States.SPRINTING:
		if INPUT_AXIS != 0:
			$Spritesheet.scale.x = INPUT_AXIS
		animation.play("sprint")
	if state == States.JUMPSPRINTING:
		animation.play("sprint")
	if state == States.FALLSPRINTING:
		animation.play("sprint")
	if state == States.HALTING:
		animation.play("skid")
	if state == States.CHARGEPUNCHING:
		animation.play("chargepunchcharge")
	if state == States.PUNCHINGWEAK:
		animation.play("punch")
	if state == States.PUNCH2:
		animation.play("punch2")
	if state == States.PUNCHINGMID:
		animation.play("chargepunchweak")
	if state == States.PUNCHINGSTRONG:
		animation.play("chargepunchstrong")
	if state == States.HURT:
		animation.play("hurt")
	if state == States.DEAD:
		if howToDie == "blunt":
			animation.play("deadblunt")
		if howToDie == "burn":
			animation.play("deadburn")
		if howToDie == "spike":
			animation.play("deadspike")
	if state == States.BURNJUMPING:
		if INPUT_AXIS != 0:
			$Spritesheet.scale.x = INPUT_AXIS
		animation.play("burnjump")
	if state == States.BURNRUNNING:
		animation.play("burnrun")
	if state == States.CROUCHPREP:
		animation.play("crouchguard")
	if state == States.CROUCHING:
		animation.play("crouch")
	if state == States.BLOCKING:
		animation.play("block")
	if state == States.BLOCKHIT:
		animation.play("blockhit")
	if state == States.GROUNDPOUNDPREP:
		animation.play("groundpoundprep")
	if state == States.GROUNDPOUND:
		animation.play("groundpound")
	if state == States.GROUNDPOUNDLAND:
		animation.play("groundpoundland")
	if state == States.WALLKICKING:
		animation.play("wallkick")
	if state == States.SKATING:
		animation.play("skating")
	if state == States.SKATECROUCHPREP:
		animation.play("skatingcrouchtransi")
	if state == States.SKATECROUCHING:
		animation.play("skatingcrouch")
	if state == States.SKATEJUMP:
		animation.play("skatingjump")
	if state == States.SKATEJUMPDETATCH:
		animation.play("roll")
		if INPUT_AXIS != 0:
			$Spritesheet.scale.x = INPUT_AXIS
	if state == States.SIDESWEEP:
		animation.play("sidesweep")
	if state == States.PARRYFORWARDS:
		animation.play("parryfoward")
	if state == States.PARRYFUPWARDS:
		animation.play("parryfupward")
	if state == States.PARRYUPWARDS:
		animation.play("parryupward")
	if state == States.SPRINTPUNCHING:
		animation.play("sprintpunch")
	if state == States.KICK:
		animation.play("kick")
	if state == States.AIRSTOMPPREP:
		animation.play("airstompprep")
	if state == States.AIRSTOMPHOLD:
		animation.play("airstomphold")
	if state == States.AIRSTOMPREL:
		animation.play("airstompattack")
	if state == States.DROPKICKPREP:
		animation.play("dropkickprep")
	if state == States.DROPKICKHOLD:
		animation.play("dropkickhold")
	if state == States.DROPKICKREL:
		animation.play("dropkickattack")
	if state == States.SPIKER1:
		animation.play("spikerfirsthalf")
		if INPUT_AXIS != 0:
			$Spritesheet.scale.x = INPUT_AXIS
	if state == States.SPIKER2:
		animation.play("spikersecondhalf")
	if state == States.AIRJAB:
		animation.play("airjab")
	if state == States.BLOCKPREP:
		animation.play("blockprep")
	if state == States.BLOCKREL:
		animation.play("blockrelease")
	if state == States.BLOCKPERFECT:
		animation.play("blockperfect")

func hitStop(_timeScale: float, _duration: float) -> void:
	pass

func squish() -> void:
	spritesheet.position.y = 14
	spritesheet.scale.y = 0.7
	await get_tree().create_timer(0.05).timeout
	spritesheet.position.y = 10
	spritesheet.scale.y = 0.8
	await get_tree().create_timer(0.05).timeout
	spritesheet.position.y = 6
	spritesheet.scale.y = 0.9
	await get_tree().create_timer(0.05).timeout
	spritesheet.position.y = 0
	spritesheet.scale.y = 1

func destroy() -> void:
	queue_free()

func randomizeAudioPitch(audio: AudioStreamPlayer2D, pitchRange: float) -> void:
	audio.pitch_scale = randf_range(1 - pitchRange, 1 + pitchRange)

func attachToBoard() -> void:
	if skateboard:
		if state == States.SKATING or state == States.SKATECROUCHPREP or state == States.SKATECROUCHING or state == States.SKATEJUMP:
			velocity = Vector2(0, 0) 
			position = Vector2(skateboard.global_position.x, skateboard.global_position.y - 40)

func directionalKnockback(valueX: float, valueY: float, directional: bool) -> void:
	if directional == false:
		hitbox.set_meta("kbdirection", Vector2(valueX, valueY))
	else:
		hitbox.set_meta("kbdirection", Vector2(valueX * $Spritesheet.scale.x, valueY))

func hurtboxstun(duration: float) -> void:
	hitbox.set_deferred("monitorable", false)
	await get_tree().create_timer(duration).timeout
	hitbox.set_deferred("monitorable", true)
