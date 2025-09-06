extends ParallaxBackground

func _physics_process(delta: float) -> void:
	$Ground.motion_offset.x -= 3
	if $Ground.motion_offset.x <= $Ground.motion_mirroring.x * -1:
		$Ground.motion_offset.x = 0
	$Background.motion_offset.x -= 1.5
	if $Background.motion_offset.x <= $Background.motion_mirroring.x * -1:
		$Background.motion_offset.x = 0
	$Clouds.motion_offset.x -= 1
	if $Clouds.motion_offset.x <= $Clouds.motion_mirroring.x * -1:
		$Clouds.motion_offset.x = 0
	$Farclouds.motion_offset.x -= 0.5
	if $Farclouds.motion_offset.x <= $Farclouds.motion_mirroring.x * -1:
		$Farclouds.motion_offset.x = 0
	$"../Jeep/AnimationPlayer".play("Drive")
	var jeepBacknForth = create_tween()
	jeepBacknForth.tween_property($"../Jeep", "position", Vector2(550, 369), 3.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
