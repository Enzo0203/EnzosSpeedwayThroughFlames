extends Camera2D

@onready var attractor_detector: Area2D = $"../Enzo/AttractorDetector"

var followingEnzo: bool = true

func _physics_process(delta: float) -> void:
	if followingEnzo:
		offset.x = move_toward(offset.x, Globalvars.EnzoVelocity / 4, delta * 200)
		drag_top_margin = 0.2
		drag_bottom_margin = 0.2
		global_position = Vector2(Globalvars.EnzoPosition.x, Globalvars.EnzoPosition.y - 25)
		zoom = Vector2(1, 1)
	if attractor_detector.get_overlapping_areas().filter(isCameraAttractor):
		followingEnzo = false
		offset.x = move_toward(offset.x, 0, 5)
		drag_top_margin = move_toward(drag_top_margin, 0, 0.07)
		drag_bottom_margin = move_toward(drag_bottom_margin, 0, 0.07)
		global_position.x = move_toward(global_position.x, attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].global_position.x, 15)
		global_position.y = move_toward(global_position.y, attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].global_position.y, 7)
		zoom.x = move_toward(zoom.x, attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].get_meta("zoom").x, 0.01)
		zoom.y = move_toward(zoom.y, attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].get_meta("zoom").y, 0.01)
	else:
		followingEnzo = true

func isCameraAttractor(area: Area2D) -> bool:
	if area.is_in_group("CameraAttractor"):
		return true
	else:
		return false
