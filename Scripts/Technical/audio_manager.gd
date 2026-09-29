extends Node

var audio_playing: Array:
	get():
		return get_children().map(func(node: Node) -> String: return node.name)

var _last_executed_frame: int = -1

func play_audio_2d(AudioSource: String, Position: Vector2, Volume: float = 0, Pitch: float = 1) -> void:
	if Engine.get_process_frames() == _last_executed_frame:
		if audio_playing.any(\
		func(audioname: String) -> bool: \
		return true if audioname.begins_with(AudioSource.get_file().replace(".", "_",)) \
		else false):
			return
	var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio.stream = load(AudioSource)
	audio.global_position = Position
	audio.volume_db = Volume
	audio.pitch_scale = Pitch
	add_child(audio)
	audio.name = AudioSource.get_file()
	audio.play()
	_last_executed_frame = Engine.get_process_frames()
	await audio.finished
	audio.queue_free()
