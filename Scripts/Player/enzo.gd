extends CharacterBody2D
class_name player

const SPEED: float = 300.0
const RUNNING_SPEED: float = 900.0
const ACCELERATION: float = 3000
const RUNNING_ACCELERATION: float = 1500
const FRICTION: float = 1000
const HALTING_FRICTION: float = 2400
const JUMP_VELOCITY: float = -500.0
const RUNNING_JUMP_VELOCITY: float = -530.0

var health: int
var healtharr: Array
var regen: int
var regenarr: Array
var regenstate: String
var direction: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Spritesheet

@onready var hitstopper: Timer = $Hitstopper

@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var intangibility_timer: Timer = $Intangibility
@onready var lava_invincibility: Timer = $LavaInvincibility
@onready var punchcooldown: Timer = $Punchcooldown
@onready var regentimer: Timer = $Regentimer

@onready var labelstate: Label = $State
@onready var labelspeed: Label = $Speed
@onready var labelthird: Label = $Slabel
@onready var ExplosionMarker: Marker2D = $ExplosionMarker
@onready var pr_clank: CPUParticles2D = $Spritesheet/Texts/Clank
@onready var pr_rebound: CPUParticles2D = $Spritesheet/Texts/Rebound
@onready var pr_clashcounter: CPUParticles2D = $Spritesheet/Texts/ClashCounter
@onready var pr_clashcountered: CPUParticles2D = $Spritesheet/Texts/ClashCountered
@onready var pr_parry: CPUParticles2D = $Spritesheet/Texts/Parry
@onready var pr_blocked: CPUParticles2D = $Spritesheet/Texts/Blocked
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox
@onready var hitboxshape: CollisionShape2D = $Hitbox/HitboxShape

enum States {IDLE, JUMPING, FALLING, WALKING, RUNNING, #0-4
SPRINTING, JUMPSPRINTING, FALLSPRINTING, HALTING, CHARGEPUNCHCHARGE, #5-9
PUNCHING, CHARGEPUNCHWEAK, CHARGEPUNCHSTRONG, HURT, DEAD, #10-14
BURNJUMPING, BURNRUNNING, CROUCHPREP, CROUCHING, BLOCKING, #15-19
BLOCKHIT, GROUNDPOUNDPREP, GROUNDPOUND, GROUNDPOUNDLAND, WALLKICKING, #20-24
SKATING, SKATECROUCHPREP, SKATECROUCHING, SKATEJUMP, SKATEJUMPDETATCH, #25-29
SIDESWEEP, PARRYFORWARDS, PARRYFUPWARDS, PARRYUPWARDS, SPRINTPUNCHING,
KICK, PUNCH2, AIRSTOMPPREP, AIRSTOMPHOLD, AIRSTOMPREL,
DROPKICKPREP, DROPKICKHOLD, DROPKICKREL, SPIKER, AIRJAB, 
BLOCKACTIONABLE, BLOCKPERFECT, SEXKICK, CHARGEKICKCHARGE, CHARGEKICKWEAK, CHARGEKICKSTRONG, 
CHARGEKICKEXPLODE, WALLRUN, DODGE, LANDING, LANDINGWALK, 
LANDINGAIRJAB, LANDINGSEXKICK, SHOULDERBASH, HURTJUMP
}

var state: States
var state_just_changed: bool = false

var instanceSpawnPosition: Vector2
var instanceInitVelocity: Vector2
var instanceReason: String

var INPUT_AXIS: float

# Main functions

func _ready() -> void:
	Globalvars.EnzoKills = 0
	Globalvars.EnzoScore = 000000
	Globalvars.EnzoMaxCombo = 0
	is_dead = false
	health = 5
	healtharr = [3, 3, 3, 3, 3, 0, 0, 0, 0, 0]
	regen = 0
	regenarr = [0, 0, 0, 0, 0]
	regenstate = "noregen"
	Globalvars.stopwatchPlaying = true
	if instanceSpawnPosition and instanceInitVelocity:
		global_position = instanceSpawnPosition
		velocity = instanceInitVelocity
	if instanceReason:
		if instanceReason == "JeepEntrance":
			state = States.SKATEJUMPDETATCH
	else:
		state = States.IDLE
	await get_tree().physics_frame
	if Globalvars.Enzo == null:
		Globalvars.Enzo = self

func _physics_process(delta: float) -> void:
	if hitstopper.time_left > 0:
		animation.speed_scale = 0
		$HitboxDataPlayer.speed_scale = 0
		$PaletteSwapAnims.speed_scale = 0
		$AfterimageAnims.speed_scale = 0
		return
	else:
		animation.speed_scale = 1
		$HitboxDataPlayer.speed_scale = 1
		$PaletteSwapAnims.speed_scale = 1
		$AfterimageAnims.speed_scale = 1
	direction = $Spritesheet.scale.x
	# Debug labels

	# Input axis
	INPUT_AXIS = signf(Input.get_axis("ui_left", "ui_right"))
	# The State Machine
	state_just_changed = false
	match state:
		States.IDLE:
			idle(delta)
		States.JUMPING:
			jumping(delta)
		States.FALLING:
			falling(delta)
		States.WALKING:
			walking(delta)
		States.RUNNING:
			running(delta)
		States.SPRINTING:
			sprinting(delta)
		States.JUMPSPRINTING:
			jumpsprinting(delta)
		States.FALLSPRINTING:
			fallsprinting(delta)
		States.HALTING:
			halting(delta)
		States.CHARGEPUNCHCHARGE:
			chargepunching(delta)
		States.PUNCHING:
			punchingweak(delta)
		States.CHARGEPUNCHWEAK:
			punchingmid(delta)
		States.CHARGEPUNCHSTRONG:
			punchingstrong(delta)
		States.HURT:
			hurt(delta)
		States.HURTJUMP:
			hurtjump(delta)
		States.DEAD:
			dead(delta)
		States.BURNJUMPING:
			burnjumping(delta)
		States.BURNRUNNING:
			burnrunning(delta)
		States.CROUCHPREP:
			crouchprep(delta)
		States.CROUCHING:
			crouching(delta)
		States.GROUNDPOUNDPREP:
			gpoundprep(delta)
		States.GROUNDPOUND:
			groundpounding(delta)
		States.GROUNDPOUNDLAND:
			groundpoundland(delta)
		States.WALLKICKING:
			wallkicking(delta)
		States.SKATING:
			skating(delta)
		States.SKATECROUCHPREP:
			skatecrouchprep(delta)
		States.SKATECROUCHING:
			skatecrouching(delta)
		States.SKATEJUMP:
			skatejumping(delta)
		States.SKATEJUMPDETATCH:
			skatedetachjumping(delta)
		States.PARRYFORWARDS:
			parryforwards(delta)
		States.PARRYFUPWARDS:
			parryfupwards(delta)
		States.PARRYUPWARDS:
			parryupwards(delta)
		States.SPRINTPUNCHING:
			sprintpunch(delta)
		States.KICK:
			kick(delta)
		States.PUNCH2:
			punch2(delta)
		States.AIRSTOMPPREP:
			airstompprep(delta)
		States.AIRSTOMPHOLD:
			airstomphold(delta)
		States.AIRSTOMPREL:
			airstomping(delta)
		States.DROPKICKPREP:
			dropkickprep(delta)
		States.DROPKICKHOLD:
			dropkickhold(delta)
		States.DROPKICKREL:
			dropkicking(delta)
		States.SPIKER:
			spiking(delta)
		States.AIRJAB:
			airjabbing(delta)
		States.BLOCKING:
			blocking(delta)
		States.BLOCKHIT:
			blockhit(delta)
		States.BLOCKACTIONABLE:
			blockactionable(delta)
		States.BLOCKPERFECT:
			blockperfect(delta)
		States.SEXKICK:
			sexkick(delta)
		States.CHARGEKICKCHARGE:
			chargekicking(delta)
		States.CHARGEKICKWEAK:
			chargekickweak(delta)
		States.CHARGEKICKSTRONG:
			chargekickstrong(delta)
		States.CHARGEKICKEXPLODE:
			chargekickexplode(delta)
		States.WALLRUN:
			wallrunning(delta)
		States.DODGE:
			dodge(delta)
		States.LANDING:
			landing(delta)
		States.LANDINGWALK:
			landingwalk(delta)
		States.LANDINGAIRJAB:
			landingairjab(delta)
		States.LANDINGSEXKICK:
			landingsexkick(delta)
		States.SHOULDERBASH:
			shoulderbashing(delta)
			
	# Constant functions
	update_animations()
	flip_hitboxes()
	check_for_death()
	check_and_regen()
	set_skating()
	# Check for stomp refresh
	if is_on_floor():
		canEnzoStomp = true
		$Walljumpdetector/Walljumpdetector.disabled = true
	else:
		$Walljumpdetector/Walljumpdetector.disabled = false
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
	# Invincibility transparency
	if intangibility_timer.time_left == 0.0:
		hurtbox.IntangibleGrace = false
		sprite.self_modulate.a = 1
	else:
		hurtbox.IntangibleGrace = true
		sprite.self_modulate.a = 0.7
	if hurtbox.Intangible:
		sprite.self_modulate.v = 2
	else:
		sprite.self_modulate.v = 1
	# Walljump check
	if $Walljumpdetector.has_overlapping_bodies():
		canWallJump = true
	else:
		canWallJump = false

# Moves

func change_state(newState: States) -> void:
	if state_just_changed and \
	newState != States.HURT and \
	newState != States.HURTJUMP and \
	newState != States.BURNJUMPING and \
	newState != States.DEAD:
		return
	state_just_changed = true
	state = newState

func idle(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	# What can this transition to
	actionable()
	if INPUT_AXIS != 0:
		change_state(States.WALKING)
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)

func jumping(delta: float) -> void:
	# What to do
	if (abs(velocity.x) < SPEED):
		velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	else:
		if (velocity.x > 0 and INPUT_AXIS == -1) or (velocity.x < 0 and INPUT_AXIS == 1) or INPUT_AXIS == 0:
			velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if Input.is_action_just_released("input_jump") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	# Transitions
	actionable()
	# What this can transition to
	await animation.animation_finished
	if state == States.JUMPING:
		if not is_on_floor():
			change_state(States.FALLING)
		else:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)

func falling(delta: float) -> void:
	# What to do
	if (abs(velocity.x) < SPEED):
		velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	else:
		if (velocity.x > 0 and INPUT_AXIS == -1) or (velocity.x < 0 and INPUT_AXIS == 1) or INPUT_AXIS == 0:
			velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# Cut off jump when button released
	if not Input.is_action_pressed("input_jump") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	# Fastfall
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	actionable()
	if is_on_floor():
		if INPUT_AXIS == 0:
			if INPUT_AXIS == 0:
				change_state(States.LANDING)
			else:
				change_state(States.LANDINGWALK)
		else:
			change_state(States.LANDINGWALK)
	if Input.is_action_just_pressed("input_jump"):
		if coyote_jump_timer.time_left > 0.0 and not Input.is_action_pressed("ui_down"):
			velocity.y = JUMP_VELOCITY
			coyote_jump_timer.stop()
			change_state(States.JUMPING)
	if Input.is_action_just_pressed("input_jump"):
		if canWallJump and is_on_wall() and INPUT_AXIS != 0:
			velocity.x = 700 * $Spritesheet.scale.x * -1
			velocity.y = -300
			change_state(States.WALLKICKING)

func walking(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	actionable()
	if INPUT_AXIS == 0:
		change_state(States.IDLE)
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_pressed("input_run"):
		change_state(States.RUNNING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)

func running(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * INPUT_AXIS, RUNNING_ACCELERATION * delta)
	# What can this transition to
	if INPUT_AXIS == 0:
		change_state(States.IDLE)
	if abs(velocity.x) > RUNNING_SPEED - 100:
		change_state(States.SPRINTING)
	if not is_on_floor():
		change_state(States.FALLING)
	if not Input.is_action_pressed("input_run"):
		change_state(States.WALKING)
	if is_on_floor():
		if Input.is_action_just_pressed("input_jump") and not Input.is_action_just_pressed("input_punch") and not Input.is_action_just_pressed("input_kick") and not Input.is_action_just_pressed("input_block"):
			change_state(States.JUMPING)
			velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("input_punch"):
		change_state(States.SHOULDERBASH)
	if Input.is_action_just_pressed("input_kick"):
		change_state(States.KICK)
	if Input.is_action_just_pressed("input_block"):
		if INPUT_AXIS == 0 and not Input.is_action_pressed("ui_up"):
			change_state(States.BLOCKING)
		elif INPUT_AXIS != 0 and not Input.is_action_pressed("ui_up"):
			$Spritesheet.scale.x = INPUT_AXIS
			change_state(States.PARRYFORWARDS)
		elif INPUT_AXIS != 0 and Input.is_action_pressed("ui_up"):
			$Spritesheet.scale.x = INPUT_AXIS
			change_state(States.PARRYFUPWARDS)
		elif INPUT_AXIS == 0 and Input.is_action_pressed("ui_up"):
			change_state(States.PARRYUPWARDS)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)

func sprinting(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * INPUT_AXIS, RUNNING_ACCELERATION * delta)
	actionable()
	# What can this transition to
	if is_on_wall() and (roundi(acos(get_floor_normal().dot(Vector2.UP)) * rad_to_deg(1)) >= 42) and (roundi(acos(get_floor_normal().dot(Vector2.UP)) * rad_to_deg(1)) <= 48) and ((velocity.x > 0 and INPUT_AXIS == 1) or (velocity.x < 0 and INPUT_AXIS == -1)):
		change_state(States.WALLRUN)
		velocity.y = RUNNING_SPEED / 2 * -1
	if not is_on_floor():
		change_state(States.FALLSPRINTING)
	if not Input.is_action_pressed("input_run"):
		change_state(States.HALTING)
	if velocity.x < 600 and velocity.x > -600:
		change_state(States.HALTING)
	if velocity.x > 0 and INPUT_AXIS != 1:
		change_state(States.HALTING)
	if velocity.x < 0 and INPUT_AXIS != -1:
		change_state(States.HALTING)

func jumpsprinting(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * sprite.scale.x, RUNNING_ACCELERATION * delta)
	velocity.y = RUNNING_JUMP_VELOCITY
	actionable()
	# What can this transition to
	if is_on_wall_only() and ((velocity.x > 0 and INPUT_AXIS == 1) or (velocity.x < 0 and INPUT_AXIS == -1)):
		change_state(States.WALLRUN)
		velocity.y = RUNNING_SPEED / 2 * -1
	if Input.is_action_just_released("input_jump") and velocity.y < RUNNING_JUMP_VELOCITY / 2:
		velocity.y = RUNNING_JUMP_VELOCITY / 2
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	if not is_on_floor():
		change_state(States.FALLSPRINTING)

func fallsprinting(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * sprite.scale.x, RUNNING_ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	actionable()
	# What can this transition to
	if is_on_wall_only() and ((velocity.x > 0 and INPUT_AXIS == 1) or (velocity.x < 0 and INPUT_AXIS == -1)):
		velocity.y = RUNNING_SPEED / 2 * -1
		change_state(States.WALLRUN)
	if Input.is_action_just_released("input_jump") and velocity.y < RUNNING_JUMP_VELOCITY / 2:
		velocity.y = RUNNING_JUMP_VELOCITY / 2
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	if (velocity.x > 0 and INPUT_AXIS == -1) or (velocity.x < 0 and INPUT_AXIS == 1):
		change_state(States.FALLING)
	if not Input.is_action_pressed("input_run"):
		change_state(States.FALLING)
	if is_on_floor():
		if velocity.x > 600 or velocity.x < -600:
			change_state(States.SPRINTING)
		if (velocity.x > 0 and INPUT_AXIS == -1) or (velocity.x < 0 and INPUT_AXIS == 1):
			change_state(States.HALTING)
	if velocity.x < 600 and velocity.x > -600:
		change_state(States.FALLING)
	if coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("input_jump") and not Input.is_action_pressed("ui_down"):
			change_state(States.JUMPSPRINTING)
			coyote_jump_timer.stop()

func shoulderbashing(delta: float) -> void:
	if animation.current_animation_position < 0.2:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.x = 600 * sprite.scale.x
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				if Input.is_action_pressed("input_run"):
					change_state(States.RUNNING)
				else:
					change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func sprintpunch(delta: float) -> void:
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * INPUT_AXIS, RUNNING_ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	#Transitions
	if is_on_wall_only() and ((velocity.x > 0 and INPUT_AXIS == 1) or (velocity.x < 0 and INPUT_AXIS == -1)):
		change_state(States.WALLRUN)
		velocity.y = RUNNING_SPEED / 2 * -1
	if animation.is_playing() == false:
		if is_on_floor():
			if not Input.is_action_pressed("input_run"):
				change_state(States.HALTING)
			else:
				change_state(States.SPRINTING)
		else:
			if (velocity.x > 0 and INPUT_AXIS == -1) or (velocity.x < 0 and INPUT_AXIS == 1) or INPUT_AXIS == 0:
				change_state(States.FALLING)
			if not Input.is_action_pressed("input_run"):
				change_state(States.FALLING)
			else:
				change_state(States.FALLSPRINTING)
	if velocity.x < 600 and velocity.x > -600:
		if is_on_floor():
			change_state(States.HALTING)
		else:
			change_state(States.FALLING)
	if (velocity.x > 0 and INPUT_AXIS == -1) or (velocity.x < 0 and INPUT_AXIS == 1):
		if is_on_floor():
			change_state(States.HALTING)
		else:
			change_state(States.FALLING)
	if is_on_floor():
		if Input.is_action_just_pressed("input_jump"):
			change_state(States.JUMPSPRINTING)

func dropkickprep(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, 800 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	if animation.is_playing() == false:
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

func dropkickhold(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, 800 * delta)
	velocity.y += gravity / 2 * delta
	velocity.y = min(velocity.y, 500)
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	if not is_on_floor():
		if not Input.is_action_pressed("input_kick"):
			change_state(States.DROPKICKREL)
	else:
		if Input.is_action_just_pressed("input_jump"):
			change_state(States.JUMPSPRINTING)
		else:
			if velocity.x > -600 and velocity.x < 600:
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)
			else:
				change_state(States.SPRINTING)

func dropkicking(delta: float) -> void:
	velocity.y += gravity / 2 * delta
	velocity.y = min(velocity.y, 500)
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
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

func halting(delta: float) -> void:
	# What to do
	actionable()
	if ($Spritesheet.scale.x == 1 and INPUT_AXIS == -1) or ($Spritesheet.scale.x == -1 and INPUT_AXIS == 1):
		velocity.x = move_toward(velocity.x, RUNNING_SPEED * INPUT_AXIS, HALTING_FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, 1600 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if ($Spritesheet.scale.x == 1 and velocity.x <= -600) or ($Spritesheet.scale.x == -1 and velocity.x >= 600):
		if state == States.HALTING:
			change_state(States.SPRINTING)
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func chargepunching(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if state == States.CHARGEPUNCHCHARGE:
		if Input.is_action_pressed("input_punch") == false:
			if animation.current_animation_position < 0.4 or animation.current_animation_position > 0.7:
				change_state(States.PUNCHING)
				punchcooldown.start()
			if animation.current_animation_position >= 0.4 and animation.current_animation_position < 0.6:
				change_state(States.CHARGEPUNCHWEAK)
			if animation.current_animation_position >= 0.6 and animation.current_animation_position <= 0.7:
				hitStop(0.1)
				change_state(States.CHARGEPUNCHSTRONG)
			await animation.animation_finished
			if state == States.CHARGEPUNCHCHARGE:
				if INPUT_AXIS == 0:
					change_state(States.IDLE)
				else:
					change_state(States.WALKING)
				if not is_on_floor():
					change_state(States.FALLING)

func punchingweak(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
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
	if Input.is_action_just_pressed("input_punch") and is_on_floor():
		if punchcooldown.time_left > 0:
			await get_tree().create_timer(punchcooldown.time_left, false).timeout
		punchcooldown.start()
		if state == States.PUNCHING:
			change_state(States.PUNCH2)

func punch2(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
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
	if Input.is_action_just_pressed("input_punch") and is_on_floor():
		if punchcooldown.time_left > 0:
			await get_tree().create_timer(punchcooldown.time_left, false).timeout
		punchcooldown.start()
		if state == States.PUNCH2:
			change_state(States.PUNCHING)

func punchingmid(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
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

func punchingstrong(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
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

func airjabbing(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if not Input.is_action_pressed("input_jump") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	# What can this transition to
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)
	if is_on_floor():
		if animation.get_current_animation_position() >= 0.1:
			if animation.get_current_animation_position() < 0.2:
				change_state(States.LANDINGAIRJAB)
			else:
				change_state(States.LANDING)

func chargekicking(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS * 0.3, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if Input.is_action_pressed("input_kick") == false:
		if animation.current_animation_position < 0.4 or animation.current_animation_position > 1.6:
			change_state(States.KICK)
		if animation.current_animation_position >= 0.4 and animation.current_animation_position < 1.2:
			change_state(States.CHARGEKICKWEAK)
		if animation.current_animation_position >= 1.2 and animation.current_animation_position <= 1.6:
			velocity.x += 300 * sprite.scale.x
			change_state(States.CHARGEKICKSTRONG)
	if animation.is_playing() == false:
		spontaniously_combust()
		change_state(States.CHARGEKICKEXPLODE)

func chargekickweak(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
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

func chargekickstrong(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
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

func chargekickexplode(delta: float) -> void:
	velocity.x = 0
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

func sexkick(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# Cut off jump when button released
	if not Input.is_action_pressed("input_jump") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	# What can this transition to
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)
	if animation.get_current_animation_position() >= 0.2 and is_on_floor():
		change_state(States.LANDINGSEXKICK)

func parryforwards(delta: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func parryfupwards(delta: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func parryupwards(delta: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func spiking(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# Cut off jump when button released
	if not Input.is_action_pressed("input_jump") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	# Transitions
	if is_on_floor() and animation.current_animation_position < 0.2:
		if INPUT_AXIS == 0:
			change_state(States.LANDING)
		else:
			change_state(States.LANDINGWALK)
	if animation.is_playing() == false:
		if not is_on_floor():
			change_state(States.FALLING)
		else:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)

func kick(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
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

var canEnzoStomp: bool

func airstompprep(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if not is_on_floor():
			change_state(States.AIRSTOMPHOLD)
		else:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)

func airstomphold(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if is_on_floor():
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
	elif not Input.is_action_pressed("input_kick"):
		change_state(States.AIRSTOMPREL)
		velocity.y =+ 200

func airstomping(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		canEnzoStomp = false
		if not is_on_floor():
			change_state(States.FALLING)
		else:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)

func hurt(delta: float) -> void:
	# What to do
	if $Spritesheet.scale.x == 1:
		velocity.x = -500
	elif $Spritesheet.scale.x == -1:
		velocity.x = 500
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false and state == States.HURT:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func hurtjump(delta: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What this can transition to
	await get_tree().physics_frame
	if state == States.HURTJUMP:
		if is_on_floor():
			change_state(States.IDLE)

func dead(delta: float) -> void:
	$Hurtbox/HurtboxShape.disabled = true
	velocity.x = move_toward(velocity.x, 0, 300 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)

func burnjumping(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What this can transition to
	if is_on_floor():
		change_state(States.BURNRUNNING)

func burnrunning(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * sprite.scale.x, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What this can transition to
	if Input.is_action_pressed("input_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	await get_tree().create_timer(1.0, false).timeout
	if state == States.BURNRUNNING:
		check_and_damage(1, false, true, 200)
	await get_tree().create_timer(0.5, false).timeout
	if state == States.BURNRUNNING:
		change_state(States.HALTING)

func crouchprep(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false or Input.is_action_just_released("ui_down"):
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

func crouching(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if Input.is_action_just_released("ui_down"):
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func blocking(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if Input.is_action_just_pressed("ui_left"):
		velocity.x = -500
		sprite.scale.x = 1
		change_state(States.DODGE)
	if Input.is_action_just_pressed("ui_right"):
		velocity.x = 500
		sprite.scale.x = -1
		change_state(States.DODGE)
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func blockhit(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		change_state(States.BLOCKACTIONABLE)

func blockactionable(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	actionable([States.BLOCKING])
	# What can this transition to
	if Input.is_action_just_pressed("ui_left"):
		velocity.x = -500
		sprite.scale.x = 1
		change_state(States.DODGE)
	if Input.is_action_just_pressed("ui_right"):
		velocity.x = 500
		sprite.scale.x = -1
		change_state(States.DODGE)
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func blockperfect(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if not is_on_floor():
		change_state(States.FALLING)
	actionable()
	if Input.is_action_just_pressed("ui_left"):
		velocity.x = -500
		sprite.scale.x = 1
		change_state(States.DODGE)
	if Input.is_action_just_pressed("ui_right"):
		velocity.x = 500
		sprite.scale.x = -1
		change_state(States.DODGE)
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func dodge(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
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
	await get_tree().create_timer(0.4, false).timeout
	if state == States.DODGE:
		actionable()

func gpoundprep(delta: float) -> void:
	velocity.y = -200
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if animation.is_playing() == false:
		if not is_on_floor():
			change_state(States.GROUNDPOUND)
		else:
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)

func groundpounding(delta: float) -> void:
	hitbox.Knockback = Vector2(200, velocity.y)
	if velocity.y > 300:
		hitbox.Damage = int(velocity.y / 120)
		hitbox.Strength = int(velocity.y / 120)
		hitbox.Damage = min(10, hitbox.Damage)
		hitbox.Strength = min(10, hitbox.Strength)
	else:
		hitbox.set_meta("dmg", 2)
		hitbox.set_meta("strength", 2)
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	# What can this transition to
	if is_on_floor():
		change_state(States.GROUNDPOUNDLAND)

func groundpoundland(delta: float) -> void:
	# What to do
	velocity.x = 0
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What this can transition to
	if animation.is_playing() == false:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func wallkicking(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What this can transition to
	if Input.is_action_pressed("ui_down"):
		if Input.is_action_just_pressed("input_jump"):
			change_state(States.GROUNDPOUNDPREP)
	if is_on_floor():
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

var isOnBoard: bool = false:
	set(value):
		if value == false:
			if skateboard:
				skateboard.get_parent().detachSkateboard.emit()
				skateboard = null

var skateboard: Area2D = null

func skating(_delta: float) -> void:
	# What to do
	velocity = Vector2(0, 0)
	attachToGrabBox(skateboard)
	# Transitions
	if Input.is_action_just_pressed("input_jump"):
		change_state(States.SKATEJUMPDETATCH)
		velocity.y = -400
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.SKATECROUCHPREP)

func skatecrouchprep(_delta: float) -> void:
	velocity = Vector2(0, 0)
	attachToGrabBox(skateboard)
	if Input.is_action_just_pressed("input_jump"):
		change_state(States.SKATEJUMP)
	if Input.is_action_just_released("ui_down"):
		change_state(States.SKATING)
	if animation.is_playing() == false:
		change_state(States.SKATECROUCHING)

func skatecrouching(_delta: float) -> void:
	velocity = Vector2(0, 0)
	attachToGrabBox(skateboard)
	if Input.is_action_just_pressed("input_jump"):
		change_state(States.SKATEJUMP)
	if Input.is_action_just_released("ui_down"):
		change_state(States.SKATING)

func skatejumping(_delta: float) -> void:
	velocity = Vector2(0, 0)
	attachToGrabBox(skateboard)
	if animation.is_playing() == false:
		if Input.is_action_pressed("ui_down"):
			change_state(States.SKATECROUCHING)
		else:
			change_state(States.SKATING)

func skatedetachjumping(delta: float) -> void:
	velocity.x = 330 * sprite.scale.x
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# Transitions
	actionable()
	if is_on_floor():
		if isOnBoard == true:
			change_state(States.SKATING)
		else:
			if INPUT_AXIS == 0:
				change_state(States.LANDING)
			else:
				change_state(States.LANDINGWALK)

func wallrunning(delta: float) -> void:
	print(str(velocity.y))
	velocity.x = 1000 * sprite.scale.x
	velocity.y += gravity / 2 * delta
	velocity.y = min(velocity.y, 500)
	if is_on_floor():
		if isOnBoard == true:
			change_state(States.SKATING)
		else:
			if INPUT_AXIS == 0:
				change_state(States.LANDING)
			else:
				change_state(States.LANDINGWALK)
	if not is_on_wall():
		velocity.y = -30
		change_state(States.FALLSPRINTING)
	if (sprite.scale.x == 1 and INPUT_AXIS == -1) or (sprite.scale.x == -1 and INPUT_AXIS == 1) or INPUT_AXIS == 0:
		change_state(States.FALLING)
	if is_on_ceiling():
		velocity.y = 30
		change_state(States.FALLING)
	if Input.is_action_just_pressed("input_jump"):
		velocity.x = 800 * $Spritesheet.scale.x * -1
		velocity.y = -400
		change_state(States.WALLKICKING)

func landing(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	actionable()
	if INPUT_AXIS != 0:
		change_state(States.WALKING)
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_pressed("input_run"):
		change_state(States.RUNNING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)
	await animation.animation_finished
	if state == States.LANDING:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func landingwalk(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	actionable()
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_pressed("input_run"):
		change_state(States.RUNNING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)
	await animation.animation_finished
	if state == States.LANDINGWALK:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func landingairjab(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	actionable()
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_pressed("input_run"):
		change_state(States.RUNNING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)
	await animation.animation_finished
	if state == States.LANDINGAIRJAB:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func landingsexkick(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	actionable()
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_pressed("input_run"):
		change_state(States.RUNNING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)
	await animation.animation_finished
	if state == States.LANDINGSEXKICK:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func actionable(exceptions: Array = []) -> void:
	if is_on_floor():
		if not state == States.SPRINTING and not \
		state == States.JUMPSPRINTING and not \
		state == States.FALLSPRINTING:
			if Input.is_action_just_pressed("input_jump"):
				change_state(States.JUMPING)
				velocity.y = JUMP_VELOCITY
			if Input.is_action_just_pressed("input_punch"):
				change_state(States.CHARGEPUNCHCHARGE)
			if Input.is_action_just_pressed("input_kick"):
				change_state(States.CHARGEKICKCHARGE)
			if Input.is_action_just_pressed("input_block"):
				if INPUT_AXIS == 0 and not Input.is_action_pressed("ui_up"):
					if not States.BLOCKING in exceptions:
						change_state(States.BLOCKING)
				elif INPUT_AXIS != 0 and not Input.is_action_pressed("ui_up"):
					$Spritesheet.scale.x = INPUT_AXIS
					change_state(States.PARRYFORWARDS)
				elif INPUT_AXIS != 0 and Input.is_action_pressed("ui_up"):
					$Spritesheet.scale.x = INPUT_AXIS
					change_state(States.PARRYFUPWARDS)
				elif INPUT_AXIS == 0 and Input.is_action_pressed("ui_up"):
					change_state(States.PARRYUPWARDS)
		else:
			if Input.is_action_pressed("input_jump"):
				change_state(States.JUMPSPRINTING)
			if Input.is_action_pressed("input_punch"):
				change_state(States.SPRINTPUNCHING)
			if Input.is_action_just_pressed("input_kick"):
				change_state(States.DROPKICKPREP)
				velocity.x += 150 * $Spritesheet.scale.x
				velocity.y = -300
	else:
		if not state == States.SPRINTING and not \
		state == States.JUMPSPRINTING and not \
		state == States.FALLSPRINTING:
			if Input.is_action_pressed("ui_down"):
				if Input.is_action_just_pressed("input_jump"):
					change_state(States.GROUNDPOUNDPREP)
			if Input.is_action_just_pressed("input_punch"):
				if INPUT_AXIS != 0:
					change_state(States.SPIKER)
				else:
					change_state(States.AIRJAB)
			if Input.is_action_just_pressed("input_kick"):
				if Input.is_action_pressed("ui_down") and canEnzoStomp == true:
					velocity.y = -200
					change_state(States.AIRSTOMPPREP)
				else:
					change_state(States.SEXKICK)
			if Input.is_action_just_pressed("input_block"):
				if INPUT_AXIS == 0 and not Input.is_action_pressed("ui_up"):
					pass
				elif INPUT_AXIS != 0 and not Input.is_action_pressed("ui_up"):
					$Spritesheet.scale.x = INPUT_AXIS
					change_state(States.PARRYFORWARDS)
				elif INPUT_AXIS != 0 and Input.is_action_pressed("ui_up"):
					$Spritesheet.scale.x = INPUT_AXIS
					change_state(States.PARRYFUPWARDS)
				elif INPUT_AXIS == 0 and Input.is_action_pressed("ui_up"):
					change_state(States.PARRYUPWARDS)
		else:
			if Input.is_action_just_pressed("input_jump"):
				if Input.is_action_pressed("ui_down"):
					change_state(States.GROUNDPOUNDPREP)
			if Input.is_action_pressed("input_punch"):
				change_state(States.SPRINTPUNCHING)
			if Input.is_action_pressed("input_kick"):
				if Input.is_action_pressed("ui_down") and canEnzoStomp == true:
					velocity.y = -200
					change_state(States.AIRSTOMPPREP)
				else:
					change_state(States.DROPKICKPREP)

# Handle Hit/Hurtboxes and damage

var collidingWithHurtbox: bool = false
var collidingWithLava: bool = false
var canWallJump: bool = false
var howToDie: String
var is_dead: bool = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Lava"):
		if lava_invincibility.time_left == 0:
			howToDie = "burn"
			change_state(States.BURNJUMPING)
			if area.global_position.y > global_position.y:
				velocity.y = -800
			else:
				velocity.y = 800
			lava_invincibility.start()
			check_and_damage(1, false, false, 200)
	if area.is_in_group("Heal"):
		if health + area.get_meta("heal") > 5:
			if regen + (area.get_meta("heal") - (5 - health)) > 5:
				regen_give(5 - regen)
				change_regen(regen + (5 - regen)) 
			else:
				regen_give(area.get_meta("heal") - (5 - health))
				change_regen(regen + (area.get_meta("heal") - (5 - health))) 
			heal(5 - health)
		else:
			heal(area.get_meta("heal"))
		$PaletteSwapAnims.play("Heal")
		Globalvars.EnzoHeal.emit()
	if area.is_in_group("Skateboard"):
		isOnBoard = false
		skateboard = area
		change_state(States.SKATING)
	if area.is_in_group("LevelExitJeep"):
		Globalvars.EnzoSavedData = {
			"Health": health,
			"Healtharr": healtharr,
			"Regen": regen,
			"Regenarr": regenarr}
		destroy()
		Globalvars.LevelEndSequence = 1
		Globalvars.stopwatchPlaying = false

func collides_with_hitbox(area: Area2D) -> bool:
	if area.is_in_group("EnemyHitbox"):
		return true
	else:
		return false

func _on_hurtbox_hurt(area: Area2D, _Damage: int, _Knockback: Vector2, DeathType: String) -> void:
	howToDie = DeathType
	check_and_damage(1, true, true, 200)
	$PaletteSwapAnims.play("Hurt")
	if health >= 1:
		if not area.is_in_group("Caltrop"):
			change_state(States.HURT)
			velocity.y = -300
		else:
			velocity.y = -600
			change_state(States.HURTJUMP)
	if health > 1:
		GlobalAudioManager.play_audio_2d("res://Sfx/Combat/EnzoHurt.ogg", global_position)
	elif health == 1:
		GlobalAudioManager.play_audio_2d("res://Sfx/Combat/EnzoHurtDanger.ogg", global_position)
	elif health == 0:
		GlobalAudioManager.play_audio_2d("res://Sfx/Combat/EnzoHurtDead.ogg", global_position)

func _on_hurtbox_block(_area: Area2D) -> void:
	change_state(States.BLOCKHIT)
	if state == States.BLOCKHIT:
		animation.stop(true)
		animation.play("blockhit")
	if $Spritesheet.scale.x == 1:
		velocity.x = -50
	elif $Spritesheet.scale.x == -1:
		velocity.x = 50
	hitStop(0.1)
	give_score(25, true)

func _on_hurtbox_perfect_block(_area: Area2D) -> void:
	change_state(States.BLOCKPERFECT)
	intangibility_timer.wait_time = 0.7
	intangibility_timer.start()
	give_score(50, true)

func _on_hitbox_hurt_something(area: Area2D) -> void:
	hitboxdisable()
	GlobalAudioManager.play_audio_2d(hitbox.ImpactSfx.resource_path , hitboxshape.global_position)
	if not (area.Parriable and hitbox.Parrybox):
		hitStop(min(0.1 * hitbox.Damage, 0.3))

func _on_hitbox_parry(_area: Area2D, _range: String) -> void:
	give_score(100, true)
	GlobalAudioManager.play_audio_2d("res://Sfx/Parry.ogg", hitboxshape.global_position)
	hitStop(0.25)
	pr_parry.set_emitting(true)

func _on_hitbox_clank(area: Area2D) -> void:
	if area.global_position.x >= position.x:
		sprite.scale.x = 1
		velocity.x = -200
	else:
		sprite.scale.x = -1
		velocity.x = 200
	pr_clank.position = hitboxshape.position
	pr_clank.set_emitting(true)

func _on_hitbox_clash_counter(_area: Area2D) -> void:
	pr_clashcounter.set_emitting(true)

func _on_hitbox_clash_countered(_area: Area2D) -> void:
	pr_clashcountered.set_emitting(true)

func _on_hitbox_rebound(_area: Area2D) -> void:
	pr_rebound.position = hitboxshape.position
	pr_rebound.set_emitting(true)

func _on_hitbox_blocked(_area: Area2D) -> void:
	pr_blocked.set_emitting(true)

func flip_hitboxes() -> void:
	hitbox.scale.x = sprite.scale.x
	hurtbox.scale.x = sprite.scale.x
	$Walljumpdetector.scale.x = sprite.scale.x

# Handle health/regen

func force_damage(amount: int) -> void:
	change_hp(health - amount)
	heart_hit(amount)
	if regentimer.time_left > 0:
		# If a regen is active, break it
		regenstate = "regenbroken"
		change_regen(regen - 1)
		regenarr[regen] = 0
		if regen != 0:
			regenarr[0] = 1
		# Make regen take a second longer to heal
		regentimer.wait_time = 6
		regentimer.start()
	if health > 0:
		Globalvars.EnzoHurt.emit()

func check_and_damage(amount: int, doHitStop: bool, makeInvincible: bool, scoreDeduction: int) -> void:
	if intangibility_timer.time_left == 0.0:
		force_damage(amount)
		if Globalvars.EnzoScore - scoreDeduction >= 0:
			Globalvars.EnzoScore -= scoreDeduction
		else:
			Globalvars.EnzoScore = 0
		if makeInvincible == true:
			if health >= 1:
				intangibility_timer.wait_time = 2
				intangibility_timer.start()
		if doHitStop == true and health >= 1:
			hitStop(0.3)

func heal(amount: int) -> void:
	await get_tree().physics_frame
	if not is_dead:
		heart_heal(amount)
		change_hp(health + amount)

func check_for_death() -> void:
	if health <= 0 and is_dead == false:
		health = 0
		healtharr = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
		Globalvars.EnzoDeath.emit()
		Globalvars.EnzoDeaths += 1
		change_state(States.DEAD)
		is_dead = true

func change_hp(new_health: int) -> void:
	health = new_health

func change_regen(new_regen: int) -> void:
	regen = new_regen

func heart_hit(amount: int) -> void:
	for i: int in range(amount):
		healtharr[health - i] = 1

func heart_heal(amount: int) -> void:
	for i: int in range(amount):
		healtharr[health + i] = 3

func regen_give(amount: int) -> void:
	for i: int in range(amount):
		regenarr[regen + i] = 1

func check_and_regen() -> void:
	# If not at full health and it has regen
	if health < 5 and regen > 0 and regenstate == "noregen":
		regentimer.wait_time = 5
		regenarr[0] = 2
		regentimer.start()
		regenstate = "regen"
	if regentimer.time_left <= 5 and regenstate == "regenbroken":
		regenstate = "regen"
		regentimer.wait_time = 5
		regenarr[0] = 2
	if regentimer.time_left == 0 and regenstate == "regen":
		heal(1)
		change_regen(regen - 1)
		regenarr[regen] = 0
		regenstate = "noregen"
		$PaletteSwapAnims.play("Heal")
	if health == 5 or regen == 0:
		if regen != 0:
			regenarr[0] = 1
		regentimer.stop()
		regenstate = "noregen"

# Misc functions

func update_animations() -> void:
	if state == States.IDLE:
		if Globalvars.EnzoCombo < 3:
			animation.play("idle")
		else:
			animation.play("idle2")
	if state == States.JUMPING:
		animation.play("jump")
		if INPUT_AXIS != 0:
			$Spritesheet.scale.x = INPUT_AXIS
	if state == States.FALLING:
		if INPUT_AXIS != 0:
			$Spritesheet.scale.x = INPUT_AXIS
		if velocity.y < -200:
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
		sprinting_sfx_manager()
	if state == States.JUMPSPRINTING:
		animation.play("sprint")
		sprinting_sfx_manager()
	if state == States.FALLSPRINTING:
		animation.play("sprint")
		sprinting_sfx_manager()
	if state == States.HALTING:
		animation.play("skid")
	if state == States.CHARGEPUNCHCHARGE:
		animation.play("chargepunchcharge")
	if state == States.PUNCHING:
		animation.play("punch")
	if state == States.PUNCH2:
		animation.play("punch2")
	if state == States.CHARGEPUNCHWEAK:
		animation.play("chargepunchweak")
	if state == States.CHARGEPUNCHSTRONG:
		animation.play("chargepunchstrong")
	if state == States.HURT:
		animation.play("hurt")
	if state == States.HURTJUMP:
		animation.play("hurtjump")
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
	if state == States.BLOCKACTIONABLE:
		animation.play("blockactionable")
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
		animation.play("parryforward")
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
	if state == States.SPIKER:
		animation.play("spiker")
		if animation.current_animation_position < 0.2:
			if INPUT_AXIS != 0:
				$Spritesheet.scale.x = INPUT_AXIS
	if state == States.AIRJAB:
		animation.play("airjab")
	if state == States.BLOCKPERFECT:
		animation.play("blockperfect")
	if state == States.SEXKICK:
		animation.play("sexkick")
	if state == States.CHARGEKICKCHARGE:
		animation.play("chargekickcharge")
		if INPUT_AXIS != 0:
			$Spritesheet.scale.x = INPUT_AXIS
	if state == States.CHARGEKICKWEAK:
		animation.play("chargekickweak")
	if state == States.CHARGEKICKSTRONG:
		animation.play("chargekickstrong")
	if state == States.CHARGEKICKEXPLODE:
		animation.play("chargekickexploded")
	if state == States.WALLRUN:
		if velocity.y < -100:
			animation.play("wallrun")
		else:
			animation.play("wallrunpanic")
	if state == States.DODGE:
		animation.play("dodge")
	if state == States.LANDING:
		animation.play("land")
	if state == States.LANDINGWALK:
		animation.play("landwalk")
	if state == States.LANDINGAIRJAB:
		animation.play("landairjab")
	if state == States.LANDINGSEXKICK:
		animation.play("landsexkick")
	if state == States.SHOULDERBASH:
		animation.play("shoulderbash")

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	$"Sound effects/RunningFootsteps".stop()
	$"Sound effects/ElectricityCrackling".stop()
	$"Sound effects/ChargeUp".stop()
	$"Sound effects/SwirlySwooshing".stop()
	$"Sound effects/ChargeUp".stop()
	
	# Special behavior
	
	if anim_name == "sprint":
		$"Sound effects/SprintingFootsteps".play()
		$"Sound effects/SprintingFootstepsMidair".play()
	if anim_name != "sprint" and anim_name != "sprintpunch":
		$"Sound effects/SprintingFootsteps".stop()
		$"Sound effects/SprintingFootstepsMidair".stop()
	if anim_name != "groundpound":
		$"Sound effects/PlaneDive".stop()

func sprinting_sfx_manager() -> void:
	if is_on_floor():
		$"Sound effects/SprintingFootsteps".volume_db = 0
		$"Sound effects/SprintingFootstepsMidair".volume_db = -80
	else:
		$"Sound effects/SprintingFootsteps".volume_db = -80
		$"Sound effects/SprintingFootstepsMidair".volume_db = 0

func hitStop(duration: float) -> void:
	hitstopper.stop()
	await get_tree().process_frame
	hitstopper.wait_time = duration
	hitstopper.start()

func destroy() -> void:
	queue_free()
	Globalvars.Enzo = null

func hitboxdisable() -> void:
	hitboxshape.disabled = true

func give_score(amount: int, accountForMultiplier: bool) -> void:
	if accountForMultiplier == true:
		Globalvars.EnzoScore += roundi(amount * Globalvars.EnzoScoreMultiplier)
	else:
		Globalvars.EnzoScore += amount

func attachToGrabBox(grabBox: Area2D) -> void:
	global_position = grabBox.get_child(1).global_position

func set_skating() -> void:
	if state != States.SKATING and state != States.SKATECROUCHPREP and state != States.SKATECROUCHING and state != States.SKATEJUMP:
		isOnBoard = false

@onready var explosion: PackedScene = preload("res://Scenes/Miscellaneous/explosion.tscn")
func spontaniously_combust() -> void:
	var exploded: bool = false
	if exploded == false:
		var explosion_instance: Node = explosion.instantiate()
		explosion_instance.spawnPosition = ExplosionMarker.global_position
		explosion_instance.explosionSize = 0.8
		explosion_instance.cantHurtEnzo = true
		get_parent().add_child(explosion_instance)
		exploded = true
