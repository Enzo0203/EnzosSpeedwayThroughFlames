## The main camera that does most of the camera work.
## Can be set to follow something (Mainly the player)
## and temporarily lock onto a spot.
class_name MainCamera extends Camera2D

var camera_target: Node2D = null
var camera_lock_in_target: bool = true

var offset_additional: Vector2

static var instance: MainCamera
func _enter_tree() -> void:
	instance = self
func _exit_tree() -> void:
	if instance == self:
		instance = null

func _ready() -> void:
	while Globalvars.Enzo == null:
		await get_tree().process_frame
	camera_target = Globalvars.Enzo

func _physics_process(delta: float) -> void:
	$Label.text = str(offset_additional.x)
	if camera_target:
		if camera_lock_in_target:
			global_position = camera_target.global_position + offset_additional
	if camera_target == Globalvars.Enzo:
		_camera_follow_enzo(delta)

## Camera's behavior when following Enzo, specifically.
func _camera_follow_enzo(delta: float) -> void:
	offset_additional.x = move_toward(offset_additional.x, Globalvars.EnzoVelocity / 4, delta * 200)
	offset_additional.y = move_toward(offset_additional.y, -25, delta * 2)
	zoom = Vector2(1, 1)

signal camera_finished_moving

## Nulls the current camera target and moves the camera towards a position.
func move_cam_to_position(target: Vector2, duration: float = 1.0) -> void:
	camera_target = null
	camera_lock_in_target = false
	toggle_vertical_drag(false)
	
	var offset_tween: Tween = create_tween()
	offset_tween.tween_property(self, "offset_additional", Vector2(0, 0), 1.0)
	
	var cam_pos_tween: Tween = create_tween()
	cam_pos_tween.tween_method(\
	func(progress: float) -> void: global_position = global_position.lerp(target, progress)\
	, 0.0, 1.0, duration) 
	cam_pos_tween.set_ease(Tween.EASE_IN_OUT)
	cam_pos_tween.set_trans(Tween.TRANS_CUBIC)
	await cam_pos_tween.finished
	
	camera_finished_moving.emit()
	cam_pos_tween.kill()

## Moves the camera towards a Node2D's global_position and sets it as the target. Unlike
## move_cam_to_target_position(), this will update the camera if the Node's position changes.
func move_cam_to_node2d(target: Node2D, duration: float = 1.0) -> void:
	camera_target = target
	camera_lock_in_target = false
	toggle_vertical_drag(true if target is Player else false)
	
	
	
	var cam_pos_tween: Tween = create_tween()
	cam_pos_tween.tween_method(\
	func(progress: float) -> void: global_position = global_position.lerp(target.global_position + offset_additional, progress)\
	, 0.0, 1.0, duration) 
	cam_pos_tween.set_ease(Tween.EASE_IN_OUT)
	cam_pos_tween.set_trans(Tween.TRANS_CUBIC)
	await cam_pos_tween.finished
	
	camera_lock_in_target = true
	camera_finished_moving.emit()
	cam_pos_tween.kill()
	


## Smoothly turns vertical drag on or off.
func toggle_vertical_drag(active: bool) -> void:
	var cam_drag_tween: Tween = null
	if cam_drag_tween and cam_drag_tween.is_valid():
		cam_drag_tween.kill()
	cam_drag_tween = create_tween().set_parallel(true)
	cam_drag_tween.tween_property(self, "drag_top_margin", 0.2 if active else 0.0, 0.2)
	cam_drag_tween.tween_property(self, "drag_bottom_margin", 0.2 if active else 0.0, 0.2)
