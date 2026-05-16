extends Node

func _physics_process(_delta: float) -> void:
	if not get_tree().paused:
		$Madman.volume_db = 0
		$MadmanPause.volume_db = -80
	else:
		$Madman.volume_db = -80
		$MadmanPause.volume_db = 0
