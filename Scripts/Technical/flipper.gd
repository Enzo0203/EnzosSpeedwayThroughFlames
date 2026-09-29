## Flips stuff.
class_name Flipper extends Node

## Thing that flips everything in ThingsToFlip according to its scale.x
@export var FlipReference: Sprite2D

@export var ThingsToFlip: Array[Node2D]

func _physics_process(_delta: float) -> void:
	flip()

func flip() -> void:
	for i: int in range(ThingsToFlip.size()):
		ThingsToFlip[i].scale.x = FlipReference.scale.x
