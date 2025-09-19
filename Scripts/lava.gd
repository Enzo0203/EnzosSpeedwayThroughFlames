extends StaticBody2D
@onready var animation: AnimationPlayer = $AnimationPlayer

func _physics_process(_delta: float) -> void:
	animation.play("Idle")
