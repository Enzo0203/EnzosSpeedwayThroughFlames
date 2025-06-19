extends CharacterBody2D

@onready var enzo_detector: Area2D = $SkateboardEnzoDetector
@onready var label: Label = $Label


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var EnzoIsOn = false

func _on_enzo_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerHurtbox"):
		EnzoIsOn = true
		set_collision_layer_value(6, true)
		velocity.x = Globalvars.EnzoVelocity

func _on_enzo_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerHurtbox"):
		EnzoIsOn = false
		set_collision_layer_value(6, false)
 
func _physics_process(delta):
	label.text = str(EnzoIsOn)
	move_and_slide()
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if EnzoIsOn == true:
		if velocity.x > -400 and velocity.x < 400:
			velocity.x = move_toward(velocity.x, 400 * Globalvars.EnzoDirection, 1000 * delta)
		if velocity.x < -800 or velocity.x > 800:
			velocity.x = move_toward(velocity.x, 800 * Globalvars.EnzoDirection, 1000 * delta)
		if (Globalvars.EnzoState == 26 or Globalvars.EnzoState == 27) and Input.is_action_just_pressed("character_z") and is_on_floor():
			velocity.y = -450
	else:
		velocity.x = move_toward(velocity.x, 0, 200 * delta)
