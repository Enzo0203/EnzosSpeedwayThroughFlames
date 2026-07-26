extends Sprite2D

@onready var animationTree: AnimationTree = $AnimationPlayer/AnimationTree

func _ready() -> void:
	animationTree.animation_started.connect(_on_animation_changed)

func _on_animation_changed(anim_name: StringName) -> void:
	if anim_name == "RegenHealing":
		animationTree.advance(5 - $"../../../RegenOutlineTimer".time_left)
