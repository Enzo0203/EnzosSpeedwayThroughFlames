extends Node

func play_audio_2d(AudioSource: NodePath, Position: Vector2) -> void:
	var Audio: AudioStreamPlayer2D = get_node(AudioSource).duplicate()
	add_child(Audio)
	print(str(Audio, " ", Position))
	Audio.global_position = Position
	Audio.play()
	print(str(Audio.playing))
	await Audio.finished
	Audio.queue_free()
	print("bye")
