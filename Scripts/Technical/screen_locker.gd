extends Area2D

@onready var deactivator: Area2D = $LockerDeactivator

var checkingForEnemies: bool = false
signal unlockScreen


func _ready() -> void:
	await get_tree().process_frame
	await deactivator.area_entered
	checkingForEnemies = true
	await unlockScreen
	queue_free()

func _physics_process(_delta: float) -> void:
	if checkingForEnemies:
		if deactivator.has_overlapping_areas() == false:
			checkingForEnemies = false
			unlockScreen.emit()
		elif not deactivator.get_overlapping_areas().any(are_enemies):
			checkingForEnemies = false
			unlockScreen.emit()

func are_enemies(area: Area2D) -> bool:
	if area.is_in_group("Enemy"):
		return true
	else:
		return false
