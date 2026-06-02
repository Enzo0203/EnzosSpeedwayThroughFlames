extends Node

func _ready() -> void:
	Globalvars.EnzoDeath.connect(_on_enzo_dead)

func _physics_process(_delta: float) -> void:
	if not get_tree().paused:
		$Madman.volume_db = 0
		$MadmanPause.volume_db = -80
	else:
		$Madman.volume_db = -80
		$MadmanPause.volume_db = 0

func _on_enzo_dead() -> void:
	
	var pitch_tween: Tween = create_tween()
	pitch_tween.tween_property($Madman, "pitch_scale", 0.01, 3.5)
	var pause_pitch_tween: Tween = create_tween()
	pause_pitch_tween.tween_property($MadmanPause, "pitch_scale", 0.01, 3.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
