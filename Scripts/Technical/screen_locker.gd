extends Area2D

## Drops after defeating every enemy
@export var reward: PackedScene
@export var reward_position_offset: Vector2

@onready var deactivator: Area2D = $LockerDeactivator

@onready var reward_position: Marker2D = $RewardPosition


var checkingForEnemies: bool = false
signal unlockScreen


func _ready() -> void:
	reward_position.position = reward_position_offset
	await get_tree().process_frame
	await deactivator.area_entered
	checkingForEnemies = true
	await unlockScreen
	queue_free()

func _physics_process(_delta: float) -> void:
	if checkingForEnemies:
		if deactivator.has_overlapping_areas() == false or not deactivator.get_overlapping_areas().any(are_enemies):
			if reward:
				spawn_reward()
			checkingForEnemies = false
			unlockScreen.emit()

func are_enemies(area: Area2D) -> bool:
	if area.is_in_group("Enemy"):
		return true
	else:
		return false

func spawn_reward() -> void:
	var reward_instance: Node = reward.instantiate()
	reward_instance.spawnPosition = reward_position.global_position
	get_parent().add_child(reward_instance)
