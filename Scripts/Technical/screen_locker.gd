extends Area2D

var checkingForEnemies: bool = false
signal unlockScreen

var hasEnemies:bool:
	set(value):
		hasEnemies = value
		if value == false:
			unlockScreen.emit()

func _ready() -> void:
	await area_entered
	checkingForEnemies = true
	await unlockScreen
	$"..".queue_free()

func _physics_process(_delta: float) -> void:
	if checkingForEnemies:
		if has_overlapping_areas() == false:
			checkingForEnemies = false
			hasEnemies = false
		elif not get_overlapping_areas().any(are_enemies):
			checkingForEnemies = false
			hasEnemies = false

func are_enemies(area: Area2D) -> bool:
	if area.is_in_group("Enemy"):
		return true
	else:
		return false
