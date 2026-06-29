extends Camera2D

@onready var attractor_detector: Area2D

var followingEnzo: bool = true
var headingTowardsEnzo: bool = false

var startingPosition: Vector2

var enzoMovementOffset: float

func _ready() -> void:
	startingPosition = global_position

func _physics_process(delta: float) -> void:
	if attractor_detector and \
	attractor_detector.area_entered.is_connected(attractor_entered_detector) == false and \
	attractor_detector.area_exited.is_connected(attractor_exited_detector) == false: 
		attractor_detector.area_entered.connect(attractor_entered_detector)
		attractor_detector.area_exited.connect(attractor_exited_detector)

	if Globalvars.Enzo:
		attractor_detector = Globalvars.Enzo.get_node("CamAttractorDetector")
		if followingEnzo:
			global_position = Vector2(Globalvars.EnzoPosition.x + enzoMovementOffset, Globalvars.EnzoPosition.y - 25)
			enzoMovementOffset = move_toward(enzoMovementOffset, Globalvars.EnzoVelocity / 4, delta * 200)
			drag_top_margin = 0.2
			drag_bottom_margin = 0.2
			
			zoom = Vector2(1, 1)
		if headingTowardsEnzo:
			if Globalvars.EnzoVelocity < 200 and Globalvars.EnzoVelocity > -200:
				enzoMovementOffset = move_toward(enzoMovementOffset, Globalvars.EnzoVelocity / 4, delta * 100)
			else:
				enzoMovementOffset = move_toward(enzoMovementOffset, Globalvars.EnzoVelocity / 4, delta * 200)

func isCameraAttractor(area: Area2D) -> bool:
	if area.is_in_group("CameraAttractor"):
		return true
	else:
		return false

func attractor_entered_detector(area: Area2D) -> void:
	if area.is_in_group("CameraAttractor"):
		followingEnzo = false
		
		enzoMovementOffset = 0
		
		var cam_pos_tween: Tween = create_tween()
		cam_pos_tween.tween_property(self, "global_position", attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].global_position, 1.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

		var cam_top_margin_tween: Tween = create_tween()
		cam_top_margin_tween.tween_property(self, "drag_top_margin", 0, 0.2)
		
		var cam_bottom_margin_tween: Tween = create_tween()
		cam_bottom_margin_tween.tween_property(self, "drag_bottom_margin", 0, 0.2)
		
		var zoom_tween: Tween = create_tween()
		zoom_tween.tween_property(self, "zoom", attractor_detector.get_overlapping_areas().filter(isCameraAttractor)[-1].get_meta("zoom").x, 0.5)
	
func attractor_exited_detector(area: Area2D) -> void:
	if area.is_in_group("CameraAttractor"):
		headingTowardsEnzo = true
		
		var cam_pos_tween: Tween = create_tween()
		cam_pos_tween.tween_method(_tween_move_towards_enzo, 0.0, 1.0, 1.0) 
		cam_pos_tween.set_ease(Tween.EASE_IN_OUT)
		cam_pos_tween.set_trans(Tween.TRANS_CUBIC)

		var cam_top_margin_tween: Tween = create_tween()
		cam_top_margin_tween.tween_property(self, "drag_top_margin", 0.2, 0.2)
		
		var cam_bottom_margin_tween: Tween = create_tween()
		cam_bottom_margin_tween.tween_property(self, "drag_bottom_margin", 0.2, 0.2)
		
		var zoom_tween: Tween = create_tween()
		zoom_tween.tween_property(self, "zoom", Vector2(1, 1), 0.5)
		
		await cam_pos_tween.finished
		headingTowardsEnzo = false
		if not attractor_detector.has_overlapping_areas():
			followingEnzo = true
		elif not attractor_detector.get_overlapping_areas().any(isCameraAttractor):
			followingEnzo = true

func _tween_move_towards_enzo(progress: float) -> void:
	global_position = global_position.lerp(Vector2(Globalvars.EnzoPosition.x + enzoMovementOffset, Globalvars.EnzoPosition.y - 25), progress)
