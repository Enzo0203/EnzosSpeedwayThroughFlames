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

var EnzoSavedData: Dictionary = {
	"Health": null,
	"Healtharr": null,
	"Regen": null,
	"Regenarr": null
}

var EnzoScore: int = 000000
var EnzoScoreMultiplier: float = 0
var EnzoCombo: int = 0
var EnzoMiniCombo: int = 0

var EnzoMaxCombo: int
var EnzoKills: int
var EnzoTime: float
var EnzoTimeString: String
var EnzoDeaths: int

func _physics_process(_delta: float) -> void:
	if Enzo:
		EnzoState = Enzo.state
		EnzoVelocity = Enzo.velocity.x
		EnzoPosition = Enzo.global_position
		EnzoHealth = Enzo.health
		EnzoHealthArr = Enzo.healtharr
		EnzoRegen = Enzo.regen
		EnzoRegenArr = Enzo.regenarr
	setLevelPars()

var stopwatchPlaying: bool

func stopwatch() -> void:
	if stopwatchPlaying:
		await get_tree().create_timer(1.0, false).timeout
		if stopwatchPlaying:
			EnzoTime += 1

func _process(delta: float) -> void:
	if stopwatchPlaying:
		EnzoTime += delta
	@warning_ignore("integer_division")
	var minutes: int = int(EnzoTime) / 60
	var seconds: int = int(fmod(EnzoTime, 60))
	EnzoTimeString = "%02d:%02d" % [minutes, seconds]

# Level Related

var LevelEndSequence: int = 0

var CurrentLevel: String = "1-1"

var LevelPars: Dictionary [String, int]

func setLevelPars() -> void:
	if CurrentLevel == "1-1":
		LevelPars = {
		"Score": 7500,
		"Kills": 52,
		"Time": 100, # In seconds
		"MaxCombo": 40
		}
