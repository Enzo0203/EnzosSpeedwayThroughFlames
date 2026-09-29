extends Entity

@onready var raycast: RayCast2D = $Sprite/Hurtbox/HitDetector

enum States {IDLE, HURT}

var state: int = States.IDLE

func change_state(newState: int) -> void:
	state = newState

var hitboxInSight: bool = false

func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			idle(delta)
		States.HURT:
			hurt(delta)
	move_and_slide()

func idle(delta: float) -> void:
	# What to do
	velocity.x = move_toward(velocity.x, 0, 500 * delta)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 2000)
	# What can this transition to

func hurt(delta: float) -> void:
	super(delta)

#func _on_area_entered(area: Area2D) -> void:
	#if area.is_in_group("PlayerHitbox") or area.is_in_group("EnvironmentalHitbox"):
		## Shoot raycast and Check for wall
		#raycast.global_position = hurtbox.global_position
		#raycast.target_position = (raycast.global_position - area.global_position) * -1
		#raycast.force_raycast_update()
		#if not raycast.is_colliding():
			## There's no wall, Hurt enemy
			#change_state(States.HURT)
			#velocity = area.get_meta("kbdirection")
			#$Label.text = "hurt"
		#elif raycast.get_collider().is_in_group("EnvironmentalCollision"):
			##There's a wall
			#print("test dummy saved by wall")
			#$Label.text = "saved by wall"
