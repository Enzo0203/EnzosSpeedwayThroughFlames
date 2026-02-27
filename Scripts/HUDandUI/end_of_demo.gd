extends Node2D

var transitioningScene: bool = false

func _ready() -> void:
	$PressButton.visible = false
	await get_tree().create_timer(2.5).timeout
	$PressButton.visible = true

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("character_z") and transitioningScene == false and $PressButton.visible == true:
		Globalvars.EnzoDeaths = 0
		transitioningScene = true
		get_tree().change_scene_to_file("res://Scenes/Levels/titlescreen.tscn")
