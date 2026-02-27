@icon("a")

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
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var intangibility_timer: Timer = $Intangibility
@onready var lava_invincibility: Timer = $LavaInvincibility
@onready var punchcooldown: Timer = $Punchcooldown
@onready var regentimer: Timer = $Regentimer
@onready var blocktimer: Timer = $Blocktimer
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
BLOCKPREP, BLOCKPERFECT, BLOCKREL, SEXKICK, CHARGEKICKCHARGE, 
CHARGEKICKWEAK, CHARGEKICKSTRONG, CHARGEKICKEXPLODE, WALLRUN, DODGE, 
LANDING, LANDINGWALK, LANDINGAIRJAB, LANDINGSEXKICK, SHOULDERBASH
}

var state: int

var instanceSpawnPosition: Vector2
var instanceInitVelocity: Vector2
var instanceReason: String

# Main functions

func _ready() -> void:
	Globalvars.EnzoKills = 0
	Globalvars.EnzoScore = 000000
	Globalvars.EnzoMaxCombo = 0
	isDead = false
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
	# Update global vars
	#Globalvars.EnzoState = state
	#Globalvars.EnzoVelocity = velocity.x
	#Globalvars.EnzoPosition = global_position
	#Globalvars.EnzoHealth = health
	#Globalvars.EnzoHealthArr = healtharr
	#Globalvars.EnzoRegen = regen
	#Globalvars.EnzoRegenArr = regenarr
	direction = $Spritesheet.scale.x
	# Debug labels
	labelstate.text = str(Globalvars.EnzoKills)
	if skateboard:
		labelspeed.text = str(skateboard.get_child(1).global_position)
		labelthird.text = str(global_position == skateboard.get_child(1).global_position)
	# Input axis
	var INPUT_AXIS: float = Input.get_axis("ui_left", "ui_right")
	# The State Machine
	match state:
		States.IDLE:
			idle(delta, INPUT_AXIS)
		States.JUMPING:
			jumping(delta, INPUT_AXIS)
		States.FALLING:
			falling(delta, INPUT_AXIS)
		States.WALKING:
			walking(delta, INPUT_AXIS)
		States.RUNNING:
			running(delta, INPUT_AXIS)
		States.SPRINTING:
			sprinting(delta, INPUT_AXIS)
		States.JUMPSPRINTING:
			jumpsprinting(delta, INPUT_AXIS)
		States.FALLSPRINTING:
			fallsprinting(delta, INPUT_AXIS)
		States.HALTING:
			halting(delta, INPUT_AXIS)
		States.CHARGEPUNCHCHARGE:
			chargepunching(delta, INPUT_AXIS)
		States.PUNCHING:
			punchingweak(delta, INPUT_AXIS)
		States.CHARGEPUNCHWEAK:
			punchingmid(delta, INPUT_AXIS)
		States.CHARGEPUNCHSTRONG:
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
		States.SPIKER:
			spiking(delta, INPUT_AXIS)
		States.AIRJAB:
			airjabbing(delta, INPUT_AXIS)
		States.BLOCKPREP:
			blockprep(delta, INPUT_AXIS)
		States.BLOCKPERFECT:
			blockperfect(delta, INPUT_AXIS)
		States.BLOCKREL:
			blockrelease(delta, INPUT_AXIS)
		States.SEXKICK:
			sexkick(delta, INPUT_AXIS)
		States.CHARGEKICKCHARGE:
			chargekicking(delta, INPUT_AXIS)
		States.CHARGEKICKWEAK:
			chargekickweak(delta, INPUT_AXIS)
		States.CHARGEKICKSTRONG:
			chargekickstrong(delta, INPUT_AXIS)
		States.CHARGEKICKEXPLODE:
			chargekickexplode(delta, INPUT_AXIS)
		States.WALLRUN:
			wallrunning(delta, INPUT_AXIS)
		States.DODGE:
			dodge(delta, INPUT_AXIS)
		States.LANDING:
			landing(delta, INPUT_AXIS)
		States.LANDINGWALK:
			landingwalk(delta, INPUT_AXIS)
		States.LANDINGAIRJAB:
			landingairjab(delta, INPUT_AXIS)
		States.LANDINGSEXKICK:
			landingsexkick(delta, INPUT_AXIS)
		States.SHOULDERBASH:
			shoulderbashing(delta, INPUT_AXIS)
	# Constant functions
	update_animations(INPUT_AXIS)
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

func idle(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	# What can this transition to
	actionable(INPUT_AXIS)
	if INPUT_AXIS != 0:
		change_state(States.WALKING)
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)

func jumping(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if Input.is_action_just_released("character_z") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	randomizeAudioPitch($"Spritesheet/Sound effects/Jump", 0.3)
	# Transitions
	actionable(INPUT_AXIS)
	# What this can transition to
	if animation.is_playing() == false:
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
	# Cut off jump when button released
	if not Input.is_action_pressed("character_z") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	# Fastfall
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	actionable(INPUT_AXIS)
	if is_on_floor():
		if INPUT_AXIS == 0:
			if INPUT_AXIS == 0:
				change_state(States.LANDING)
			else:
				change_state(States.LANDINGWALK)
		else:
			change_state(States.LANDINGWALK)
	if Input.is_action_just_pressed("character_z"):
		if coyote_jump_timer.time_left > 0.0 and not Input.is_action_pressed("ui_down"):
			velocity.y = JUMP_VELOCITY
			coyote_jump_timer.stop()
			change_state(States.JUMPING)
	if Input.is_action_just_pressed("character_z"):
		if canWallJump and is_on_wall() and INPUT_AXIS != 0:
			velocity.x = 700 * $Spritesheet.scale.x * -1
			velocity.y = -300
			change_state(States.WALLKICKING)

func walking(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	actionable(INPUT_AXIS)
	if INPUT_AXIS == 0:
		change_state(States.IDLE)
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_pressed("character_a"):
		change_state(States.RUNNING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)

func running(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * INPUT_AXIS, RUNNING_ACCELERATION * delta)
	# What can this transition to
	if INPUT_AXIS == 0:
		change_state(States.IDLE)
	if abs(velocity.x) > RUNNING_SPEED - 100:
		change_state(States.SPRINTING)
	if not is_on_floor():
		change_state(States.FALLING)
	if not Input.is_action_pressed("character_a"):
		change_state(States.WALKING)
	if is_on_floor():
		if Input.is_action_just_pressed("character_z") and not Input.is_action_just_pressed("character_x") and not Input.is_action_just_pressed("character_s") and not Input.is_action_just_pressed("character_c"):
			change_state(States.JUMPING)
			velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("character_x"):
		change_state(States.SHOULDERBASH)
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
	if not is_on_floor():
		change_state(States.FALLSPRINTING)
	if not Input.is_action_pressed("character_a"):
		change_state(States.HALTING)
	if velocity.x < 600 and velocity.x > -600:
		change_state(States.HALTING)
	if velocity.x > 0 and INPUT_AXIS != 1:
		change_state(States.HALTING)
	if velocity.x < 0 and INPUT_AXIS != -1:
		change_state(States.HALTING)
	if Input.is_action_pressed("character_z"):
		change_state(States.JUMPSPRINTING)
	if is_on_wall() and (roundi(acos(get_floor_normal().dot(Vector2.UP)) * rad_to_deg(1)) >= 42) and (roundi(acos(get_floor_normal().dot(Vector2.UP)) * rad_to_deg(1)) <= 48) and ((velocity.x > 0 and INPUT_AXIS == 1) or (velocity.x < 0 and INPUT_AXIS == -1)):
		velocity.y = abs(RUNNING_SPEED / 2) * -1
		change_state(States.WALLRUN)
	if Input.is_action_pressed("character_x"):
		change_state(States.SPRINTPUNCHING)
	if Input.is_action_just_pressed("character_s"):
		change_state(States.DROPKICKPREP)
		velocity.x += 150 * $Spritesheet.scale.x
		velocity.y = -300

func jumpsprinting(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * sprite.scale.x, RUNNING_ACCELERATION * delta)
	velocity.y = RUNNING_JUMP_VELOCITY
	if Input.is_action_just_released("character_z") and velocity.y < RUNNING_JUMP_VELOCITY / 2:
		velocity.y = RUNNING_JUMP_VELOCITY / 2
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
	if not is_on_floor():
		change_state(States.FALLSPRINTING)
	if is_on_wall_only() and ((velocity.x > 0 and INPUT_AXIS == 1) or (velocity.x < 0 and INPUT_AXIS == -1)):
		velocity.y = abs(RUNNING_SPEED / 2) * -1
		change_state(States.WALLRUN)
	if Input.is_action_pressed("character_x"):
		change_state(States.SPRINTPUNCHING)
	if Input.is_action_just_pressed("character_s"):
		if Input.is_action_pressed("ui_down") and canEnzoStomp == true:
			velocity.y = -200
			change_state(States.AIRSTOMPPREP)
		else:
			change_state(States.DROPKICKPREP)
	if Input.is_action_just_pressed("character_z"):
		if Input.is_action_pressed("ui_down"):
			change_state(States.GROUNDPOUNDPREP)

func fallsprinting(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * sprite.scale.x, RUNNING_ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if Input.is_action_just_released("character_z") and velocity.y < RUNNING_JUMP_VELOCITY / 2:
		velocity.y = RUNNING_JUMP_VELOCITY / 2
	if not Input.is_action_pressed("character_z") and velocity.y < RUNNING_JUMP_VELOCITY / 2:
		velocity.y = RUNNING_JUMP_VELOCITY / 2
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	if (velocity.x > 0 and INPUT_AXIS == -1) or (velocity.x < 0 and INPUT_AXIS == 1):
		change_state(States.FALLING)
	if not Input.is_action_pressed("character_a"):
		change_state(States.FALLING)
	# What can this transition to
	if is_on_floor():
		if velocity.x > 600 or velocity.x < -600:
			change_state(States.SPRINTING)
		if (velocity.x > 0 and INPUT_AXIS == -1) or (velocity.x < 0 and INPUT_AXIS == 1):
			change_state(States.HALTING)
	if velocity.x < 600 and velocity.x > -600:
		change_state(States.FALLING)
	if coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("character_z") and not Input.is_action_pressed("ui_down"):
			change_state(States.JUMPSPRINTING)
			coyote_jump_timer.stop()
	if is_on_wall_only() and ((velocity.x > 0 and INPUT_AXIS == 1) or (velocity.x < 0 and INPUT_AXIS == -1)):
		velocity.y = abs(RUNNING_SPEED / 2) * -1
		change_state(States.WALLRUN)
	if Input.is_action_pressed("character_x"):
		change_state(States.SPRINTPUNCHING)
	if Input.is_action_just_pressed("character_s"):
		if Input.is_action_pressed("ui_down") and canEnzoStomp == true:
			velocity.y = -200
			change_state(States.AIRSTOMPPREP)
		else:
			change_state(States.DROPKICKPREP)
	if Input.is_action_just_pressed("character_z"):
		if Input.is_action_pressed("ui_down"):
			change_state(States.GROUNDPOUNDPREP)

func shoulderbashing(delta: float, INPUT_AXIS: float) -> void:
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
				if Input.is_action_pressed("character_a"):
					change_state(States.RUNNING)
				else:
					change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func sprintpunch(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, RUNNING_SPEED * INPUT_AXIS, RUNNING_ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	#Transitions
	if animation.is_playing() == false:
		if INPUT_AXIS == 0:
			change_state(States.HALTING)
		if not Input.is_action_pressed("character_a"):
			change_state(States.HALTING)
		if not is_on_floor():
			change_state(States.FALLSPRINTING)
		else:
			change_state(States.SPRINTING)
	if velocity.x < 600 and velocity.x > -600:
		change_state(States.HALTING)
	if (velocity.x > 0 and INPUT_AXIS == -1) or (velocity.x < 0 and INPUT_AXIS == 1):
		change_state(States.HALTING)
	if is_on_floor():
		if Input.is_action_just_pressed("character_z"):
			change_state(States.JUMPSPRINTING)
	if is_on_wall_only() and ((velocity.x > 0 and INPUT_AXIS == 1) or (velocity.x < 0 and INPUT_AXIS == -1)):
		velocity.y = abs(RUNNING_SPEED / 2) * -1
		change_state(States.WALLRUN)

func dropkickprep(delta: float, INPUT_AXIS: float) -> void:
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

func dropkickhold(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, 800 * delta)
	velocity.y += gravity / 2 * delta
	velocity.y = min(velocity.y, 500)
	if Input.is_action_just_pressed("ui_down"):
		velocity.y = velocity.y + 500
	# What can this transition to
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

func halting(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	if ($Spritesheet.scale.x == 1 and INPUT_AXIS == -1) or ($Spritesheet.scale.x == -1 and INPUT_AXIS == 1):
		velocity.x = move_toward(velocity.x, RUNNING_SPEED * INPUT_AXIS, HALTING_FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, 1600 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	actionable(INPUT_AXIS)
	if ($Spritesheet.scale.x == 1 and velocity.x <= -600) or ($Spritesheet.scale.x == -1 and velocity.x >= 600):
		change_state(States.SPRINTING)
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
			change_state(States.PUNCHING)
			punchcooldown.start()
		if animation.current_animation_position >= 0.4 and animation.current_animation_position < 0.6:
			change_state(States.CHARGEPUNCHWEAK)
		if animation.current_animation_position >= 0.6 and animation.current_animation_position <= 0.7:
			hitStop(0.1)
			change_state(States.CHARGEPUNCHSTRONG)
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
	# What can this transition to
	if animation.is_playing() == false:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)
	if Input.is_action_just_pressed("character_x") and is_on_floor():
		if punchcooldown.time_left > 0:
			await get_tree().create_timer(punchcooldown.time_left, false).timeout
		punchcooldown.start()
		if state == States.PUNCHING:
			change_state(States.PUNCH2)

func punch2(delta: float, INPUT_AXIS: float) -> void:
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
	if Input.is_action_just_pressed("character_x") and is_on_floor():
		if punchcooldown.time_left > 0:
			await get_tree().create_timer(punchcooldown.time_left, false).timeout
		punchcooldown.start()
		if state == States.PUNCH2:
			change_state(States.PUNCHING)

func punchingmid(delta: float, INPUT_AXIS: float) -> void:
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

func punchingstrong(delta: float, INPUT_AXIS: float) -> void:
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

func airjabbing(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
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
	if is_on_floor():
		if animation.get_current_animation_position() >= 0.1:
			if animation.get_current_animation_position() < 0.2:
				change_state(States.LANDINGAIRJAB)
			else:
				change_state(States.LANDING)

func chargekicking(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS * 0.3, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if Input.is_action_pressed("character_s") == false:
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

func chargekickweak(delta: float, INPUT_AXIS: float) -> void:
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

func chargekickstrong(delta: float, INPUT_AXIS: float) -> void:
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

func chargekickexplode(delta: float, INPUT_AXIS: float) -> void:
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

func sexkick(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# Cut off jump when button released
	if not Input.is_action_pressed("character_z") and velocity.y < JUMP_VELOCITY / 2:
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

func parryforwards(delta: float, INPUT_AXIS: float) -> void:
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

func parryfupwards(delta: float, INPUT_AXIS: float) -> void:
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

func parryupwards(delta: float, INPUT_AXIS: float) -> void:
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

func spiking(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# Cut off jump when button released
	if not Input.is_action_pressed("character_z") and velocity.y < JUMP_VELOCITY / 2:
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

func kick(delta: float, INPUT_AXIS: float) -> void:
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

func airstompprep(delta: float, INPUT_AXIS: float) -> void:
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

func hurt(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	if $Spritesheet.scale.x == 1:
		velocity.x = -500
	elif $Spritesheet.scale.x == -1:
		velocity.x = 500
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	await get_tree().create_timer(0.45, false).timeout
	if state == States.HURT:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func dead(delta: float) -> void:
	$Hurtbox/HurtboxShape.disabled = true
	velocity.x = move_toward(velocity.x, 0, 300 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)

func burnjumping(delta: float, INPUT_AXIS: float) -> void:
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
	if Input.is_action_just_pressed("ui_left"):
		velocity.x = -500
		sprite.scale.x = 1
		change_state(States.DODGE)
	if Input.is_action_just_pressed("ui_right"):
		velocity.x = 500
		sprite.scale.x = -1
		change_state(States.DODGE)
	await blocktimer.timeout
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
	await get_tree().create_timer(0.2).timeout
	if state == States.BLOCKHIT:
		change_state(States.BLOCKING)

func blockprep(delta: float, _INPUT_AXIS: float) -> void:
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
		change_state(States.BLOCKING)

func blockperfect(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What can this transition to
	if not is_on_floor():
		change_state(States.FALLING)
	actionable(INPUT_AXIS)
	if Input.is_action_just_pressed("ui_left"):
		velocity.x = -500
		sprite.scale.x = 1
		change_state(States.DODGE)
	if Input.is_action_just_pressed("ui_right"):
		velocity.x = 500
		sprite.scale.x = -1
		change_state(States.DODGE)
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
	await get_tree().create_timer(0.4).timeout
	if state == States.BLOCKREL:
		if is_on_floor():
			if INPUT_AXIS == 0:
				change_state(States.IDLE)
			else:
				change_state(States.WALKING)
		else:
			change_state(States.FALLING)

func dodge(delta: float, INPUT_AXIS: float) -> void:
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
	await get_tree().create_timer(0.4).timeout
	if state == States.DODGE:
		actionable(INPUT_AXIS)

func gpoundprep(delta: float, INPUT_AXIS: float) -> void:
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

func groundpounding(delta: float, INPUT_AXIS: float) -> void:
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

func groundpoundland(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = 0
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# What this can transition to
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

var isOnBoard: bool = false:
	set(value):
		if value == false:
			if skateboard:
				skateboard.get_parent().detachSkateboard.emit()
				skateboard = null

var skateboard: Area2D = null

func skating(_delta: float, _INPUT_AXIS: float) -> void:
	# What to do
	velocity = Vector2(0, 0)
	attachToGrabBox(skateboard)
	# Transitions
	if Input.is_action_just_pressed("character_z"):
		change_state(States.SKATEJUMPDETATCH)
		velocity.y = -400
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.SKATECROUCHPREP)

func skatecrouchprep(_delta: float, _INPUT_AXIS: float) -> void:
	velocity = Vector2(0, 0)
	attachToGrabBox(skateboard)
	if Input.is_action_just_pressed("character_z"):
		change_state(States.SKATEJUMP)
	if Input.is_action_just_released("ui_down"):
		change_state(States.SKATING)
	if animation.is_playing() == false:
		change_state(States.SKATECROUCHING)

func skatecrouching(_delta: float, _INPUT_AXIS: float) -> void:
	velocity = Vector2(0, 0)
	attachToGrabBox(skateboard)
	if Input.is_action_just_pressed("character_z"):
		change_state(States.SKATEJUMP)
	if Input.is_action_just_released("ui_down"):
		change_state(States.SKATING)

func skatejumping(_delta: float, _INPUT_AXIS: float) -> void:
	velocity = Vector2(0, 0)
	attachToGrabBox(skateboard)
	if animation.is_playing() == false:
		if Input.is_action_pressed("ui_down"):
			change_state(States.SKATECROUCHING)
		else:
			change_state(States.SKATING)

func skatedetachjumping(delta: float, INPUT_AXIS: float) -> void:
	velocity.x = 330 * sprite.scale.x
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	# Transitions
	actionable(INPUT_AXIS)
	if is_on_floor():
		if isOnBoard == true:
			change_state(States.SKATING)
		else:
			if INPUT_AXIS == 0:
				change_state(States.LANDING)
			else:
				change_state(States.LANDINGWALK)

func wallrunning(delta: float, INPUT_AXIS: float) -> void:
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
	if Input.is_action_just_pressed("character_z"):
		velocity.x = 800 * $Spritesheet.scale.x * -1
		velocity.y = -400
		change_state(States.WALLKICKING)

func landing(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	actionable(INPUT_AXIS)
	if INPUT_AXIS != 0:
		change_state(States.WALKING)
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_pressed("character_a"):
		change_state(States.RUNNING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)
	if animation.is_playing() == false:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func landingwalk(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	actionable(INPUT_AXIS)
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_pressed("character_a"):
		change_state(States.RUNNING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)
	if animation.is_playing() == false:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func landingairjab(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	actionable(INPUT_AXIS)
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_pressed("character_a"):
		change_state(States.RUNNING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)
	if animation.is_playing() == false:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func landingsexkick(delta: float, INPUT_AXIS: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, SPEED * INPUT_AXIS, ACCELERATION * delta)
	# What can this transition to
	actionable(INPUT_AXIS)
	if not is_on_floor():
		change_state(States.FALLING)
	if Input.is_action_pressed("character_a"):
		change_state(States.RUNNING)
	if Input.is_action_just_pressed("ui_down"):
		change_state(States.CROUCHPREP)
	if animation.is_playing() == false:
		if INPUT_AXIS == 0:
			change_state(States.IDLE)
		else:
			change_state(States.WALKING)
		if not is_on_floor():
			change_state(States.FALLING)

func actionable(INPUT_AXIS: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("character_z") and not Input.is_action_just_pressed("character_x") and not Input.is_action_just_pressed("character_s") and not Input.is_action_just_pressed("character_c"):
			change_state(States.JUMPING)
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("character_x"):
			change_state(States.CHARGEPUNCHCHARGE)
		if Input.is_action_just_pressed("character_s"):
			change_state(States.CHARGEKICKCHARGE)
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
	if not is_on_floor():
		if Input.is_action_pressed("ui_down"):
			if Input.is_action_just_pressed("character_z"):
				change_state(States.GROUNDPOUNDPREP)
		if Input.is_action_just_pressed("character_x"):
			if INPUT_AXIS != 0:
				change_state(States.SPIKER)
			else:
				change_state(States.AIRJAB)
		if Input.is_action_just_pressed("character_s"):
			if Input.is_action_pressed("ui_down") and canEnzoStomp == true:
				velocity.y = -200
				change_state(States.AIRSTOMPPREP)
			else:
				change_state(States.SEXKICK)
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

# Handle Hit/Hurtboxes and damage

var collidingWithHurtbox: bool = false
var collidingWithLava: bool = false
var canWallJump: bool = false
var howToDie: String
var isDead: bool = false

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
			check_and_damage(false, false, 200)
	if area.is_in_group("Heal"):
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

func _on_hurtbox_hurt(_area: Area2D, _Damage: int, _Knockback: Vector2, DeathType: String) -> void:
	howToDie = DeathType
	change_state(States.HURT)
	$PaletteSwapAnims.play("Hurt")
	check_and_damage(true, true, 200)
	if health >= 1:
		velocity.y = -300
	if health > 1:
		$"Spritesheet/Sound effects/EnzoHurt".play()
	elif health == 1:
		$"Spritesheet/Sound effects/EnzoHurtDanger".play()
	elif health == 0:
		$"Spritesheet/Sound effects/EnzoHurtDead".play()

func _on_hurtbox_block(_area: Area2D) -> void:
	change_state(States.BLOCKHIT)
	blocktimer.start()
	give_score(25, true)

func _on_hurtbox_perfect_block(_area: Area2D) -> void:
	change_state(States.BLOCKPERFECT)
	intangibility_timer.wait_time = 0.6
	intangibility_timer.start()
	blocktimer.stop()
	give_score(50, true)

func _on_hitbox_hurt_something(_area: Area2D) -> void:
	randomizeAudioPitch(get_node(str("Spritesheet/Sound effects/",hitbox.ImpactSfx)), 0.2)
	get_node(str("Spritesheet/Sound effects/",hitbox.ImpactSfx)).play()
	hitStop(min(0.1 * hitbox.Damage, 0.3))

func _on_hitbox_parry(_area: Area2D) -> void:
	give_score(100, true)
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
		Globalvars.EnzoHurt.emit()

func check_and_damage(doHitStop: bool, makeInvincible: bool, scoreDeduction: int) -> void:
	if intangibility_timer.time_left == 0.0:
		force_damage()
		if Globalvars.EnzoScore - scoreDeduction >= 0:
			Globalvars.EnzoScore -= scoreDeduction
		else:
			Globalvars.EnzoScore = 0
		if makeInvincible == true:
			if health >= 1:
				intangibility_timer.wait_time = 2
				intangibility_timer.start()
		if doHitStop == true:
			hitStop(0.3)

func check_for_death() -> void:
	if health <= 0 and isDead == false:
		health = 0
		healtharr = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
		Globalvars.EnzoDeath.emit()
		Globalvars.EnzoDeaths += 1
		change_state(States.DEAD)
		isDead = true

# Handle health/regen

func change_state(newState: int) -> void:
	state = newState

func change_hp(new_health: int) -> void:
	health = new_health

func change_regen(new_regen: int) -> void:
	regen = new_regen

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
		regenstate = "regen"
		regentimer.wait_time = 5
		regenarr[0] = 2
	if regentimer.time_left == 0 and regenstate == "regen":
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

# Misc functions

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
	if state == States.JUMPSPRINTING:
		animation.play("sprint")
	if state == States.FALLSPRINTING:
		animation.play("sprint")
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
	if state == States.BLOCKPREP:
		animation.play("blockprep")
	if state == States.BLOCKREL:
		animation.play("blockrelease")
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

var hitStopped: bool = false

func hitStop(duration: float) -> void:
	#disable_mode = CollisionObject2D.DISABLE_MODE_MAKE_STATIC
	#process_mode = Node.PROCESS_MODE_DISABLED
	Engine.time_scale = 0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1
	#process_mode = Node.PROCESS_MODE_PAUSABLE
	#disable_mode = CollisionObject2D.DISABLE_MODE_REMOVE

func destroy() -> void:
	queue_free()
	Globalvars.Enzo = null

func randomizeAudioPitch(audio: AudioStreamPlayer2D, pitchRange: float) -> void:
	audio.pitch_scale = randf_range(1 - pitchRange, 1 + pitchRange)

func hurtboxstun(_duration: float) -> void:
	pass

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

# Explode for no fucking reason
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
