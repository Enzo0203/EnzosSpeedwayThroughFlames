extends Node

# Enzo Related

var Enzo: CharacterBody2D = null

@warning_ignore("unused_signal")
signal EnzoHurt
@warning_ignore("unused_signal")
signal EnzoDeath
@warning_ignore("unused_signal")
signal EnzoHeal
@warning_ignore("unused_signal")
signal EnzoComboUpdated
@warning_ignore("unused_signal")
signal EnzoMiniComboUpdated

var EnzoState: int
var EnzoVelocity: float
var EnzoPosition: Vector2

var EnzoHealth: int
var EnzoHealthArr: Array
var EnzoRegen: int
var EnzoRegenArr: Array

var EnzoScore: int = 000000
var EnzoScoreMultiplier: float = 0
var EnzoCombo: int = 0
var EnzoMiniCombo: int = 0

func _physics_process(_delta: float) -> void:
	if Enzo:
		EnzoState = Enzo.state
		EnzoVelocity = Enzo.velocity.x
		EnzoPosition = Enzo.global_position
		EnzoHealth = Enzo.health
		EnzoHealthArr = Enzo.healtharr
		EnzoRegen = Enzo.regen
		EnzoRegenArr = Enzo.regenarr

# Level Related

var CurrentLevel: String = "1-1"

var LevelEndSequence: int = 0
