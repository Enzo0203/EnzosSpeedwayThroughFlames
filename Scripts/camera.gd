extends Camera2D

func _physics_process(delta):
	offset.x = move_toward(offset.x, Globalvars.EnzoVelocity / 4, delta * 200)
