extends Node

var Enzo: CharacterBody2D = null

signal EnzoHurt
signal EnzoDeath
signal EnzoHeal
signal EnzoComboUpdated
signal EnzoMiniComboUpdated

var EnzoState: int
var EnzoDirection: int
var EnzoVelocity: float
var EnzoPosition: Vector2
var EnzoHealth: int
var EnzoHealthArr: Array
var EnzoRegen: int
var EnzoRegenArr: Array
var EnzoRegenState: String

var EnzoScore: int = 000000
var EnzoScoreMultiplier: float = 0
var EnzoCombo: int = 0
var EnzoMiniCombo: int = 0

func _physics_process(delta: float) -> void:
	if Enzo:
		EnzoState = Enzo.state
		EnzoDirection = Enzo.direction
		EnzoVelocity = Enzo.velocity.x
		EnzoPosition = Enzo.global_position
		EnzoHealth = Enzo.health
		EnzoHealthArr = Enzo.healtharr
		EnzoRegen = Enzo.regen
		EnzoRegenArr = Enzo.regenarr
		EnzoRegenState = Enzo.regenstate
