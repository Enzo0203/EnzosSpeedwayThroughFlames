extends Node2D

## Drops after defeating every enemy
@export var reward: PackedScene
@export var reward_position_offset: Vector2

@onready var enemy_checker: Area2D = $EnemyChecker
@onready var player_checker: Area2D = $PlayerChecker

@onready var reward_position: Marker2D = $RewardPosition

var checkingForEnemies: bool = false
signal unlockScreen

func _ready() -> void:
	reward_position.position = reward_position_offset

func _physics_process(_delta: float) -> void:
	if enemy_checker.has_overlapping_areas() and checkingForEnemies:
		if enemy_checker.get_overlapping_areas().any(_are_enemies) == false:
			if reward:
				spawn_reward()
			checkingForEnemies = false
			unlockScreen.emit()
			MainCamera.instance.move_cam_to_node2d(\
			enemy_checker.get_overlapping_areas().filter(_is_player)[0].owner)
			queue_free()

func _are_enemies(area: Area2D) -> bool:
	if area.is_in_group("Enemy"):
		return true
	else:
		return false

func _is_player(area: Area2D) -> bool:
	if area.owner is Player:
		return true
	else:
		return false

func spawn_reward() -> void:
	var reward_instance: Node = reward.instantiate()
	reward_instance.spawnPosition = reward_position.global_position
	get_parent().add_child(reward_instance)

func _on_player_checker_body_exited(body: Node2D) -> void:
	if body is Player:
		if enemy_checker.has_overlapping_bodies():
			if enemy_checker.get_overlapping_bodies().has(body):
				MainCamera.instance.move_cam_to_position(global_position)
				checkingForEnemies = true
