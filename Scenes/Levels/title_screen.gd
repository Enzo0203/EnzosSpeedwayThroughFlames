extends Control

var loadSceneTransition: bool



func _ready() -> void:
	loadSceneTransition = false
	$BlackFade.position.x = 1510

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("character_z"):
		loadSceneTransition = true
		await get_tree().create_timer(1.0).timeout
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://Scenes/Levels/world.tscn")
	if loadSceneTransition:
		if $BlackFade.position.x > 410:
			$BlackFade.position.x -= 20
		else:
			$BlackFade.position.x = 410
