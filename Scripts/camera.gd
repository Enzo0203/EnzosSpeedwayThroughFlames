extends Camera2D

@onready var attractor_detector: Area2D

var followingEnzo: bool

var startingPosition: Vector2

var enzoMovementOffset: float

func _ready() -> void:
	startingPosition = global_position

func _physics_process(delta: float) -> void:
	if Globalvars.Enzo:
		attractor_detector = Globalvars.Enzo.get_node("CamAttractorDetector")
		if followingEnzo:
			enzoMovementOffset = move_toward(enzoMovementOffset, Globalvars.EnzoVelocity / 4, delta * 200)
			drag_top_margin = 0.2
			drag_bottom_margin = 0.2
			global_position = Vector2(Globalvars.EnzoPosition.x + enzoMovementOffset, Globalvars.EnzoPosition.y - 25)
			zoom = Vector2(1, 1)
		if attractor_detector.get_overlapping_areas().filter(isCameraAttractor):
			followingEnzo = false
			drag_top_margin = move_toward(drag_top_margin, 0, 0.07)
			drag_bottom_margin = move_toward(drag_bottom_margin, 0, 0.07)
			global_position.x = move_toward(global_position.x, attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].global_position.x, 15)
			global_position.y = move_toward(global_position.y, attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].global_position.y, 7)
			zoom.x = move_toward(zoom.x, attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].get_meta("zoom").x, 0.01)
			zoom.y = move_toward(zoom.y, attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].get_meta("zoom").y, 0.01)
			#limit_right = attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].get_node("CamAttractBottomRight").global_position.x
		else:
			followingEnzo = true

func isCameraAttractor(area: Area2D) -> bool:
	if area.is_in_group("CameraAttractor"):
		return true
	else:
		return false
