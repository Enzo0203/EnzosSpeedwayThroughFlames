extends Control

@onready var Rank: Sprite2D = $RanksSheet

var ScoreFactor: String = "Z"
var KillsFactor: String = "Z"
var TimeFactor: String = "Z"
var MaxComboFactor: String = "Z"
var DeathsFactor: String = "Z"

var RankScore: int

@onready var animation: AnimationPlayer = $LevelEndAnimations
@onready var animation_tree: AnimationTree = $LevelEndAnimations/AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

func _ready() -> void:
	Globalvars.LevelEndSequence = 0
	animation_tree.active = false

func _physics_process(_delta: float) -> void:
	if Globalvars.LevelEndSequence == 2:
		if animation_tree.active == false:
			setRankFactors()
			setRankScore()
			setRank()
			setText()
			animation_tree.active = true
		if Input.is_action_just_pressed("character_z"):
			anim_state.next()
		if anim_state.get_current_node() == "Done":
			if Input.is_action_just_pressed("character_z") and transitioningScene == false:
				transitioningScene = true
				get_tree().change_scene_to_file("res://Scenes/Miscellaneous/end_of_demo.tscn")

var transitioningScene: bool = false

func setRankFactors() -> void:
	setScoreFactor()
	setKillsFactor()
	setTimefactor()
	setMaxComboFactor()
	setDeathsfactor()
	$Text/Factors.text = str(ScoreFactor,KillsFactor,TimeFactor,MaxComboFactor,DeathsFactor)

func setScoreFactor() -> void:
	if Globalvars.EnzoScore <= Globalvars.LevelPars["Score"] * 0.10:
		ScoreFactor = "Z"
	elif Globalvars.EnzoScore <= Globalvars.LevelPars["Score"] * 0.30:
		ScoreFactor = "G"
	elif Globalvars.EnzoScore <= Globalvars.LevelPars["Score"] * 0.40:
		ScoreFactor = "F"
	elif Globalvars.EnzoScore <= Globalvars.LevelPars["Score"] * 0.50:
		ScoreFactor = "D"
	elif Globalvars.EnzoScore <= Globalvars.LevelPars["Score"] * 0.60:
		ScoreFactor = "C"
	elif Globalvars.EnzoScore <= Globalvars.LevelPars["Score"] * 0.70:
		ScoreFactor = "B"
	elif Globalvars.EnzoScore <= Globalvars.LevelPars["Score"] * 0.99:
		ScoreFactor = "A"
	elif Globalvars.EnzoScore <= Globalvars.LevelPars["Score"] * 1.10:
		ScoreFactor = "S"
	elif Globalvars.EnzoScore >= Globalvars.LevelPars["Score"] * 1.11:
		ScoreFactor = "X"

func setKillsFactor() -> void:
	if Globalvars.EnzoKills <= Globalvars.LevelPars["Kills"] * 0.60:
		KillsFactor = "Z"
	elif Globalvars.EnzoKills <= Globalvars.LevelPars["Kills"] * 0.65:
		KillsFactor = "G"
	elif Globalvars.EnzoKills <= Globalvars.LevelPars["Kills"] * 0.70:
		KillsFactor = "F"
	elif Globalvars.EnzoKills <= Globalvars.LevelPars["Kills"] * 0.75:
		KillsFactor = "D"
	elif Globalvars.EnzoKills <= Globalvars.LevelPars["Kills"] * 0.80:
		KillsFactor = "C"
	elif Globalvars.EnzoKills <= Globalvars.LevelPars["Kills"] * 0.85:
		KillsFactor = "B"
	elif Globalvars.EnzoKills <= Globalvars.LevelPars["Kills"] * 0.90:
		KillsFactor = "A"
	elif Globalvars.EnzoKills < Globalvars.LevelPars["Kills"] * 1.00:
		KillsFactor = "S"
	elif Globalvars.EnzoKills >= Globalvars.LevelPars["Kills"] * 1.00:
		KillsFactor = "X"

func setTimefactor() -> void:
	if Globalvars.EnzoTime >= Globalvars.LevelPars["Time"] * 10.00:
		TimeFactor = "Z"
	elif Globalvars.EnzoTime >= Globalvars.LevelPars["Time"] * 7.00:
		TimeFactor = "G"
	elif Globalvars.EnzoTime >= Globalvars.LevelPars["Time"] * 5.00:
		TimeFactor = "F"
	elif Globalvars.EnzoTime >= Globalvars.LevelPars["Time"] * 4.00:
		TimeFactor = "D"
	elif Globalvars.EnzoTime >= Globalvars.LevelPars["Time"] * 3.00:
		TimeFactor = "C"
	elif Globalvars.EnzoTime >= Globalvars.LevelPars["Time"] * 2.00:
		TimeFactor = "B"
	elif Globalvars.EnzoTime >= Globalvars.LevelPars["Time"] * 1.01:
		TimeFactor = "A"
	elif Globalvars.EnzoTime >= Globalvars.LevelPars["Time"] * 0.90:
		TimeFactor = "S"
	elif Globalvars.EnzoTime <= Globalvars.LevelPars["Time"] * 0.89:
		TimeFactor = "X"

func setMaxComboFactor() -> void:
	if Globalvars.EnzoMaxCombo <= Globalvars.LevelPars["MaxCombo"] * 0.20:
		MaxComboFactor = "Z"
	elif Globalvars.EnzoMaxCombo <= Globalvars.LevelPars["MaxCombo"] * 0.30:
		MaxComboFactor = "G"
	elif Globalvars.EnzoMaxCombo <= Globalvars.LevelPars["MaxCombo"] * 0.40:
		MaxComboFactor = "F"
	elif Globalvars.EnzoMaxCombo <= Globalvars.LevelPars["MaxCombo"] * 0.50:
		MaxComboFactor = "D"
	elif Globalvars.EnzoMaxCombo <= Globalvars.LevelPars["MaxCombo"] * 0.60:
		MaxComboFactor = "C"
	elif Globalvars.EnzoMaxCombo <= Globalvars.LevelPars["MaxCombo"] * 0.70:
		MaxComboFactor = "B"
	elif Globalvars.EnzoMaxCombo <= Globalvars.LevelPars["MaxCombo"] * 0.99:
		MaxComboFactor = "A"
	elif Globalvars.EnzoMaxCombo <= Globalvars.LevelPars["MaxCombo"] * 1.10:
		MaxComboFactor = "S"
	elif Globalvars.EnzoMaxCombo >= Globalvars.LevelPars["MaxCombo"] * 1.11:
		MaxComboFactor = "X"

func setDeathsfactor() -> void:
	if Globalvars.EnzoDeaths >= 6:
		DeathsFactor = "Z"
	elif Globalvars.EnzoDeaths >= 5:
		DeathsFactor = "G"
	elif Globalvars.EnzoDeaths >= 4:
		DeathsFactor = "F"
	elif Globalvars.EnzoDeaths >= 3:
		DeathsFactor = "D"
	elif Globalvars.EnzoDeaths >= 2:
		DeathsFactor = "C"
	elif Globalvars.EnzoDeaths >= 1:
		DeathsFactor = "B"
	elif Globalvars.EnzoDeaths >= 0:
		if Globalvars.EnzoSavedData["Health"] <= 2:
			DeathsFactor = "A"
		elif Globalvars.EnzoSavedData["Health"] <= 4:
			DeathsFactor = "S"
		elif Globalvars.EnzoSavedData["Health"] >= 5:
			DeathsFactor = "X"

func setRankScore() -> void:
	RankScore += str(ScoreFactor,KillsFactor,TimeFactor,MaxComboFactor,DeathsFactor).count("Z") * -4
	RankScore += str(ScoreFactor,KillsFactor,TimeFactor,MaxComboFactor,DeathsFactor).count("G") * -3
	RankScore += str(ScoreFactor,KillsFactor,TimeFactor,MaxComboFactor,DeathsFactor).count("F") * -2
	RankScore += str(ScoreFactor,KillsFactor,TimeFactor,MaxComboFactor,DeathsFactor).count("D") * -1
	RankScore += str(ScoreFactor,KillsFactor,TimeFactor,MaxComboFactor,DeathsFactor).count("C") * 0
	RankScore += str(ScoreFactor,KillsFactor,TimeFactor,MaxComboFactor,DeathsFactor).count("B") * 1
	RankScore += str(ScoreFactor,KillsFactor,TimeFactor,MaxComboFactor,DeathsFactor).count("A") * 2
	RankScore += str(ScoreFactor,KillsFactor,TimeFactor,MaxComboFactor,DeathsFactor).count("S") * 3
	RankScore += str(ScoreFactor,KillsFactor,TimeFactor,MaxComboFactor,DeathsFactor).count("X") * 4

func setRank() -> void:
	if RankScore == -20:
		Rank.frame = 0
	elif RankScore <= -15:
		Rank.frame = 1
	elif RankScore <= -10:
		Rank.frame = 2
	elif RankScore <= -5:
		Rank.frame = 3
	elif RankScore <= 0:
		Rank.frame = 4
	elif RankScore <= 5:
		Rank.frame = 5
	elif RankScore <= 10:
		Rank.frame = 6
	elif RankScore <= 15:
		Rank.frame = 7
	elif RankScore <= 19:
		Rank.frame = 8
	elif RankScore == 20:
		Rank.frame = 9

func setText() -> void:
	$Text/Score.text = str(Globalvars.EnzoScore).pad_zeros(6)
	$Text/Kills.text = str(Globalvars.EnzoKills)
	$Text/Time.text = str(Globalvars.EnzoTimeString)
	$Text/MaxCombo.text = str(Globalvars.EnzoMaxCombo)
	$Text/Deaths.text = str(Globalvars.EnzoDeaths)
