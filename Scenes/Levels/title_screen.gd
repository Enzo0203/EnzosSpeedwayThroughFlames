extends Control

var loadSceneTransition: bool

func _ready() -> void:
	$Start.frame = 1
	loadSceneTransition = false
	$BlackFade.position.x = 1510

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("character_z"):
		$Start.frame = 0
		loadSceneTransition = true
		await get_tree().create_timer(1.0).timeout
		$"../Title Theme".stop()
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://Scenes/Levels/level1-1.tscn")
	if loadSceneTransition:
		if $BlackFade.position.x > 410:
			$BlackFade.position.x -= 20
		else:
			$BlackFade.position.x = 410
