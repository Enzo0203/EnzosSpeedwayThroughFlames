extends Node

func play_audio_2d(AudioSource: String, Position: Vector2, Volume: float = 0, Pitch: float = 1) -> void:
	var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio.stream = load(AudioSource)
	audio.global_position = Position
	audio.volume_db = Volume
	audio.pitch_scale = Pitch
	add_child(audio)
	audio.play()
	await audio.finished
	audio.queue_free()
