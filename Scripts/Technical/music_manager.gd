extends Node

@onready var audio_player: AudioStreamPlayer = get_child(0)
@onready var stream: AudioStreamInteractive = audio_player.stream
@onready var stream_playback: AudioStreamPlaybackInteractive = audio_player.get_stream_playback()

func _ready() -> void:
	Globalvars.EnzoDeath.connect(_on_enzo_dead)

func _physics_process(_delta: float) -> void:
	switch_on_pause()

func _on_enzo_dead() -> void:
	var pitch_tween: Tween = create_tween()
	pitch_tween.tween_property(audio_player, "pitch_scale", 0.01, 3.5)
	var pause_pitch_tween: Tween = create_tween()
	pause_pitch_tween.tween_property(audio_player, "pitch_scale", 0.01, 3.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

var playingPauseMusic:bool
func switch_on_pause() -> void:
	if not get_tree().paused and playingPauseMusic:
		stream_playback.switch_to_clip_by_name(str(get_current_clip_name().trim_suffix("Pause")))
		playingPauseMusic = false
	elif get_tree().paused and not playingPauseMusic:
		if has_pause_counterpart(str(get_current_clip_name(), "Pause")):
			stream_playback.switch_to_clip_by_name(str(get_current_clip_name(), "Pause"))
		playingPauseMusic = true

func has_pause_counterpart(clipName: String) -> bool:
	for i: int in range(stream.clip_count):
		if stream.get_clip_name(i) == clipName:
			return true
	return false

func get_current_clip_name() -> String:
	return stream.get_clip_name(stream_playback.get_current_clip_index())
