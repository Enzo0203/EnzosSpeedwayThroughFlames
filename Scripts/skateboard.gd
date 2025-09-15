extends CharacterBody2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

const MAX_SPEED: float = 600
const ACCELERATION: float = 10
const FRICTION: float = 5
const JUMP_HEIGHT: float = -500

@onready var grabbox: Area2D = $Grabbox

signal detachSkateboard

func _physics_process(delta: float) -> void:
	$Label.text = str(enzo)
	detachSkateboard.connect(_detach_skateboard)
	move_and_slide()
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if enzo:
		velocity.x = move_toward(velocity.x, MAX_SPEED * enzo.get_parent().get_parent().direction, ACCELERATION)
		if enzo.get_parent().get_parent().state == 28 and is_on_floor():
			velocity.y = JUMP_HEIGHT
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)

var enzo: Area2D

func _on_grabbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHurtbox"):
		enzo = area
		velocity.x = enzo.get_parent().get_parent().velocity.x

func _detach_skateboard() -> void:
	enzo = null
