extends CharacterBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer

var crashed: bool = false

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		crashed = false
		animation.play("Drive")
		velocity.x = 500
	move_and_slide()
	if is_on_wall() and !crashed:
		crashed = true
		launch_enzo()
		velocity.x = -200
		animation.play("Crash")
		await animation.animation_finished
		animation.play("AfterCrash")
	if crashed:
		velocity.x = move_toward(velocity.x, 0, 5)

@onready var enzo = preload("res://Scenes/Player/player_enzo.tscn")
func launch_enzo():
	var enzo_instance = enzo.instantiate()
	enzo_instance.instanceSpawnPosition = $EnzoLauncherPosition.global_position
	enzo_instance.instanceInitVelocity.x = 500
	enzo_instance.instanceInitVelocity.y = -500
	enzo_instance.instanceReason = "JeepEntrance"
	get_parent().add_child(enzo_instance)
