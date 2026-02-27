extends CharacterBody2D

@export var type:String # "enter" or "exit"

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animation: AnimationPlayer = $AnimationPlayer

var crashed: bool = false
var enzoGotInCar: bool = false

func _ready() -> void:
	if type == "Enter":
		crashed = false
		animation.play("Drive")
		velocity.x = 500
		$EnzoDetectorNodes.queue_free()
		$OnScreenNotifier.rect = Rect2(-2500, -1250, 5000, 2500)
	if type == "Exit":
		enzoGotInCar = false
		animation.play("Wait")
		$OnScreenNotifier.rect = Rect2(-100, -100, 200, 200)

func _physics_process(delta: float) -> void:
	move_and_slide()
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, 500)
	if type == "Enter":
		if is_on_wall() and !crashed:
			crashed = true
			launch_enzo()
			velocity.x = -200
			animation.play("Crash")
			await animation.animation_finished
			animation.play("AfterCrash")
		if crashed:
			velocity.x = move_toward(velocity.x, 0, 5)
	if type == "Exit":
		if enzoGotInCar == true:
			if animation.get_current_animation() == "Drive":
				velocity.x = move_toward(velocity.x, 500, 10)

@onready var enzo: PackedScene = preload("res://Scenes/Player/player_enzo.tscn")
func launch_enzo() -> void:
	var enzo_instance: Node = enzo.instantiate()
	enzo_instance.instanceSpawnPosition = $EnzoLauncherPosition.global_position
	enzo_instance.instanceInitVelocity.x = 500
	enzo_instance.instanceInitVelocity.y = -500
	enzo_instance.instanceReason = "JeepEntrance"
	get_parent().add_child(enzo_instance)

func _on_on_screen_notifier_screen_exited() -> void:
	if type == "Enter":
		queue_free()
	if type == "Exit" and enzoGotInCar == true:
		Globalvars.LevelEndSequence = 2

func _on_special_grabbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hurtbox") and type == "Exit":
		animation.play("Leave")
		enzoGotInCar = true
		await get_tree().create_timer(2.0).timeout
		velocity.x = move_toward(velocity.x, -10, 5)
		await animation.animation_finished
		animation.play("Drive")
