extends Node

## Sprite to duplicate.
@export var sprite: Sprite2D

## Hitstopper, if any
@export var hitstopper: Timer

@export_category("Afterimage Properties")

## Whether the afterimager is active or not.
@export var active: bool = false

## How often afterimages spawn.
@export var interval: float = 0.05

## Color of the afterimages.
@export var afterimage_modulate: Gradient = Gradient.new()

## Afterimage duration.
@export var duration: float = 0.5

var after_image_counter: float = 0.0

func _process(delta: float) -> void:
	if active:
		after_image_counter += delta
		if after_image_counter >= interval:
			spawn_afterimage()
			after_image_counter = 0.0

func spawn_afterimage() -> void:
	# If Hitstopped, don't
	if hitstopper.time_left > 0:
		return
	
	# Make the duplicate
	var afterimage: Sprite2D = Sprite2D.new()
	get_tree().current_scene.add_child(afterimage)
	
	# Execute order 66
	for child: Node in afterimage.get_children():
		child.queue_free()
	
	# Match properties
	afterimage.texture = sprite.texture
	afterimage.hframes = sprite.hframes
	afterimage.vframes = sprite.vframes
	afterimage.frame = sprite.frame
	afterimage.scale = sprite.scale
	afterimage.z_index = -1
	afterimage.global_position = sprite.global_position
	afterimage.scale = sprite.scale
	
	# Make colors follow gradient
	var tween: Tween = create_tween()
	tween.tween_method(
		func(offset: float) -> void: afterimage.modulate = afterimage_modulate.sample(offset), 0.0, 1.0, duration)
	
	# Delete when gradient finishes or when this node stops existing
	tween.finished.connect(afterimage.queue_free)
	tree_exiting.connect(afterimage.queue_free)
