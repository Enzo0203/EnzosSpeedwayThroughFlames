class_name Entity extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

## The entity's hurtbox.
@export var hurtbox: Hurtbox

## The entity's Health Manager. If left empty, it'll be immortal.
@export var health_manager: Hurtbox

@export var hitstopper: Timer

func hurt(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 2000)
	velocity.x = move_toward(velocity.x, 0, 600 * delta)
	var bounceSpeed: Variant
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

func _on_hurtbox_hurt(_area: Area2D, Damage: int, Knockback: Vector2) -> void:
	if health_manager:
		$".".damage(Damage)
	$".".change_state($".".States.HURT)
	await get_tree().process_frame
	velocity = Knockback
	$".".hitStop(min(0.1 * Damage, 0.3))

func hitStop(duration: float) -> void:
	hitstopper.stop()
	await get_tree().process_frame
	hitstopper.wait_time = duration
	hitstopper.start()

func give_score(amount: int, accountForMultiplier: bool) -> void:
	if accountForMultiplier == true:
		Globalvars.EnzoScore += roundi(amount * Globalvars.EnzoScoreMultiplier)
	else:
		Globalvars.EnzoScore += amount

func damage(amount: int) -> void:
	health_manager.deal_damage(amount)
	give_score(10 * amount, true)
	Globalvars.EnzoMiniCombo += amount
	Globalvars.EnzoMiniComboUpdated.emit()
