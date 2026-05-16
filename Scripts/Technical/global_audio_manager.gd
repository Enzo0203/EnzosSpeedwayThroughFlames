extends Node

@warning_ignore("unused_signal")
signal play_audio_2d(Audio: StringName, Position: Vector2)

func _on_play_audio_2d(AudioSource: NodePath, Position: Vector2) -> void:
	var Audio: AudioStreamPlayer2D = get_node(AudioSource).duplicate()
	add_child(Audio)
	print(str(Audio, " ", Position))
	Audio.global_position = Position
	Audio.play()
	print(str(Audio.playing))
	await Audio.finished
	Audio.queue_free()
	print("bye")
