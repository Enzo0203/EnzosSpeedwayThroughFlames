extends Node

var EnzoState: int
var EnzoMovement: int
var EnzoDirection: int
var EnzoVelocity: float
var EnzoPositionX: float
var EnzoPositionY: float

var EnzoHealth: int = 5
var EnzoHealthArr: Array = [3, 3, 3, 3, 3, 0, 0, 0, 0, 0]
var EnzoRegen: int = 0
var EnzoRegenArr: Array = [0, 0, 0, 0, 0]
var EnzoRegenState: String

var EnzoScore: int = 000000
var EnzoScoreMultiplier: float = 0
var EnzoCombo: int = 0
var EnzoMiniCombo: int = 0

signal EnzoHurt
signal EnzoHeal
signal EnzoComboUpdated
signal EnzoMiniComboUpdated
