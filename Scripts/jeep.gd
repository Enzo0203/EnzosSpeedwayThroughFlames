extends CharacterBody2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animation: AnimationPlayer = $AnimationPlayer

var crashed: bool = false

func _ready() -> void:
	crashed = false
	animation.play("Drive")
	velocity.x = 500

func _physics_process(delta: float) -> void:
	move_and_slide()
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if is_on_wall() and !crashed:
		crashed = true
		launch_enzo()
		velocity.x = -200
		animation.play("Crash")
		await animation.animation_finished
		animation.play("AfterCrash")
	if crashed:
		velocity.x = move_toward(velocity.x, 0, 5)

@onready var enzo: PackedScene = preload("res://Scenes/Player/player_enzo.tscn")
func launch_enzo() -> void:
	var enzo_instance: Node = enzo.instantiate()
	enzo_instance.instanceSpawnPosition = $EnzoLauncherPosition.global_position
	enzo_instance.instanceInitVelocity.x = 500
	enzo_instance.instanceInitVelocity.y = -500
	enzo_instance.instanceReason = "JeepEntrance"
	get_parent().add_child(enzo_instance)
