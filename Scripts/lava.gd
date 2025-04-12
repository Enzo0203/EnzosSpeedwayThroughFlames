extends StaticBody2D
@onready var animation: AnimationPlayer = $AnimationPlayer

func _physics_process(_delta):
	animation.play("Idle")
