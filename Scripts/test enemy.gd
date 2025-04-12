extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var hurtbox: Area2D = $Sprite/Hurtbox
@onready var raycast: RayCast2D = $Sprite/Hurtbox/RayCast2D


enum States {IDLE, HURT}

var state = States.IDLE

func change_state(newState):
	state = newState

var hitboxInSight = false

func _physics_process(delta):
	match state:
		States.IDLE:
			idle(delta)
		States.HURT:
			hurt(delta)
	move_and_slide()

func idle(delta):
	# What to do
	velocity.x = move_toward(velocity.x, 0, 500 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 2000)
	# What can this transition to

var bounceSpeed

func hurt(delta):
	velocity.x = move_toward(velocity.x, 0, 500 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 2000)
	# What to do
	if not is_on_floor() and velocity.y >= 500:
		bounceSpeed = velocity.y
	if velocity.y >= 500:
		if is_on_floor():
			velocity.y = velocity.y / 2 * -1
	if is_on_floor():
		if bounceSpeed:
			velocity.y = bounceSpeed / 2 * -1
			bounceSpeed = null
	await get_tree().create_timer(0.2).timeout
	# What can this transition to
	change_state(States.IDLE)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnzoHitbox"):
		raycast.global_position = hurtbox.global_position
		raycast.target_position = (raycast.global_position - area.global_position) * -1
		await get_tree().process_frame
		if not raycast.is_colliding():
			change_state(States.HURT)
			velocity = area.get_meta("kbdirection")
			print("test dummy hurt")
			$Label.text = "hurt"
		elif raycast.get_collider().is_in_group("tileset"):
			print("test dummy saved by wall")
			$Label.text = "saved by wall"
