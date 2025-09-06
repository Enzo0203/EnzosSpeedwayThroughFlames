extends Control

@onready var Heart1: AnimationPlayer = $Hearts/Heart1/AnimationPlayer
@onready var Heart2: AnimationPlayer = $Hearts/Heart2/AnimationPlayer
@onready var Heart3: AnimationPlayer = $Hearts/Heart3/AnimationPlayer
@onready var Heart4: AnimationPlayer = $Hearts/Heart4/AnimationPlayer
@onready var Heart5: AnimationPlayer = $Hearts/Heart5/AnimationPlayer
@onready var Heart6: AnimationPlayer = $Hearts/Heart6/AnimationPlayer
@onready var Heart7: AnimationPlayer = $Hearts/Heart7/AnimationPlayer
@onready var Heart8: AnimationPlayer = $Hearts/Heart8/AnimationPlayer
@onready var Heart9: AnimationPlayer = $Hearts/Heart9/AnimationPlayer
@onready var Heart10: AnimationPlayer = $Hearts/Heart10/AnimationPlayer
@onready var Regen1: AnimationPlayer = $Hearts/Regenoutline1/AnimationPlayer
@onready var Regen2: AnimationPlayer = $Hearts/Regenoutline2/AnimationPlayer
@onready var Regen3: AnimationPlayer = $Hearts/Regenoutline3/AnimationPlayer
@onready var Regen4: AnimationPlayer = $Hearts/Regenoutline4/AnimationPlayer
@onready var Regen5: AnimationPlayer = $Hearts/Regenoutline5/AnimationPlayer
@onready var Overlay: AnimationPlayer = $Overlay/AnimationPlayer
@onready var SpeechBubble: AnimationPlayer = $EnzoSpeechBubble/AnimationPlayer
@onready var SpubbleDelay: Timer = $SpeechBubbleDelay
@onready var score: Label = $ScoreLabel
@onready var Score1: AnimationPlayer = $Score/Score1/AnimationPlayer
@onready var Score2: AnimationPlayer = $Score/Score2/AnimationPlayer
@onready var Score3: AnimationPlayer = $Score/Score3/AnimationPlayer
@onready var Score4: AnimationPlayer = $Score/Score4/AnimationPlayer
@onready var Score5: AnimationPlayer = $Score/Score5/AnimationPlayer
@onready var Score6: AnimationPlayer = $Score/Score6/AnimationPlayer

@onready var ComboTimeBar: TextureProgressBar = $Combo/ComboTimeBar
@onready var ComboNumber1: AnimationPlayer = $Combo/ComboNumber1/AnimationPlayer
@onready var ComboNumber2: AnimationPlayer = $Combo/ComboNumber2/AnimationPlayer
@onready var ComboNumber3: AnimationPlayer = $Combo/ComboNumber3/AnimationPlayer
@onready var ComboTimer: Timer = $Combo/ComboTimer

@onready var MiniComboTimeBar: TextureProgressBar = $Combo/MiniComboTimeBar
@onready var MiniComboNumber1: AnimationPlayer = $Combo/MiniComboNumber1/AnimationPlayer
@onready var MiniComboNumber2: AnimationPlayer = $Combo/MiniComboNumber2/AnimationPlayer
@onready var MiniComboNumber3: AnimationPlayer = $Combo/MiniComboNumber3/AnimationPlayer
@onready var MiniComboTimer: Timer = $Combo/MiniComboTimer

@onready var MultiNumber1: AnimationPlayer = $Combo/MultiplierNumber1/AnimationPlayer
@onready var MultiNumber2: AnimationPlayer = $Combo/MultiplierNumber2/AnimationPlayer

var health: Array = Globalvars.EnzoHealthArr
var regen: Array = Globalvars.EnzoRegenArr
var miniComboMultiplier: float = 0
var comboMultiplier: float = 0

func _ready() -> void:
	Overlay.play("Idle")
	Globalvars.EnzoHurt.connect(_on_enzo_hurt)
	Globalvars.EnzoHeal.connect(_on_enzo_heal)
	Globalvars.EnzoComboUpdated.connect(_on_combo_update)
	Globalvars.EnzoMiniComboUpdated.connect(_on_minicombo_update)

func _physics_process(_delta: float) -> void:
	$ScoreLabel.text = str(Globalvars.Enzo)
	handleHealth()
	handleCombo()
	handleMiniCombo()
	handleMultiplier()
	handleScore()
	handlePortrait()

func handleHealth() -> void:
	if Globalvars.EnzoHealth == 0:
		Overlay.play("Black Screen of Death")
		if get_tree():
			await get_tree().create_timer(3.5).timeout
		if get_tree():
			Globalvars.EnzoScore = 000000
			Globalvars.EnzoHealth = 5
			Globalvars.EnzoHealthArr = [3, 3, 3, 3, 3, 0, 0, 0, 0, 0]
			get_tree().reload_current_scene()
	Heart1.play(str(health[0]))
	Heart2.play(str(health[1]))
	Heart3.play(str(health[2]))
	Heart4.play(str(health[3]))
	Heart5.play(str(health[4]))
	#Heart6.play(str(health[5]))
	#Heart7.play(str(health[6]))
	#Heart8.play(str(health[7]))
	#Heart9.play(str(health[8]))
	#Heart10.play(str(health[9]))
	Regen5.play(str(regen[0]))
	Regen4.play(str(regen[1]))
	Regen3.play(str(regen[2]))
	Regen2.play(str(regen[3]))
	Regen1.play(str(regen[4]))

func handleCombo() -> void:
	if Globalvars.EnzoCombo > 0:
		ComboTimeBar.value = ComboTimer.time_left
		ComboTimer.wait_time = Globalvars.EnzoCombo * 2
		ComboTimer.wait_time = max(ComboTimer.wait_time, 4)
		ComboTimer.wait_time = min(ComboTimer.wait_time, ComboTimeBar.max_value)
	if ComboTimer.time_left == 0:
		Globalvars.EnzoCombo = 0
	if Globalvars.EnzoCombo < 10:
		ComboNumber1.play(str(Globalvars.EnzoCombo).pad_zeros(3)[-1])
		$Combo/ComboNumber1.position = Vector2(776, 418)
		$Combo/ComboNumber2.visible = false
		$Combo/ComboNumber3.visible = false
		comboMultiplier = 0
	if Globalvars.EnzoCombo >= 10 and Globalvars.EnzoCombo < 100:
		ComboNumber1.play(str(Globalvars.EnzoCombo).pad_zeros(3)[-1])
		$Combo/ComboNumber1.position = Vector2(791, 418)
		ComboNumber2.play(str(Globalvars.EnzoCombo).pad_zeros(3)[-2])
		$Combo/ComboNumber2.position = Vector2(758, 418)
		$Combo/ComboNumber2.visible = true
		$Combo/ComboNumber3.visible = false
		comboMultiplier = 1
	if Globalvars.EnzoCombo >= 100:
		ComboNumber1.play(str(Globalvars.EnzoCombo).pad_zeros(3)[-1])
		$Combo/ComboNumber1.position = Vector2(804, 418)
		ComboNumber2.play(str(Globalvars.EnzoCombo).pad_zeros(3)[-2])
		$Combo/ComboNumber2.position = Vector2(776, 418)
		$Combo/ComboNumber2.visible = true
		ComboNumber3.play(str(Globalvars.EnzoCombo).pad_zeros(3)[-3])
		$Combo/ComboNumber3.position = Vector2(747, 418)
		$Combo/ComboNumber3.visible = true
		comboMultiplier = 1.5

func handleMiniCombo() -> void:
	if Globalvars.EnzoMiniCombo > 0:
		MiniComboTimeBar.value = MiniComboTimer.time_left
		MiniComboTimer.wait_time = Globalvars.EnzoMiniCombo * 1.2
		MiniComboTimer.wait_time = max(ComboTimer.wait_time, 3)
		MiniComboTimer.wait_time = min(ComboTimer.wait_time, MiniComboTimeBar.max_value)
	if MiniComboTimer.time_left == 0:
		Globalvars.EnzoMiniCombo = 0
	if Globalvars.EnzoMiniCombo == 0:
		$Combo/MiniComboBackground.self_modulate = Color(0, 0, 0, 1)
		miniComboMultiplier = 0
	if Globalvars.EnzoMiniCombo > 0 and Globalvars.EnzoMiniCombo < 10:
		$Combo/MiniComboBackground.self_modulate = Color(0, 0.9, 0.9, 1)
	if Globalvars.EnzoMiniCombo >= 10 and Globalvars.EnzoMiniCombo < 25:
		$Combo/MiniComboBackground.self_modulate = Color(0.9, 0.9, 0.4, 1)
		miniComboMultiplier = 0.1
	if Globalvars.EnzoMiniCombo >= 25 and Globalvars.EnzoMiniCombo < 50:
		$Combo/MiniComboBackground.self_modulate = Color(1, 1, 0, 1)
	if Globalvars.EnzoMiniCombo >= 50 and Globalvars.EnzoMiniCombo < 100:
		$Combo/MiniComboBackground.self_modulate = Color(1, 0.5, 0, 1)
		miniComboMultiplier = 0.3
	if Globalvars.EnzoMiniCombo >= 100 and Globalvars.EnzoMiniCombo < 150:
		$Combo/MiniComboBackground.self_modulate = Color(1, 0, 0, 1)
		miniComboMultiplier = 0.5
	if Globalvars.EnzoMiniCombo >= 150 and Globalvars.EnzoMiniCombo < 200:
		$Combo/MiniComboBackground.self_modulate = Color(0.6, 0, 0.3, 1)
		miniComboMultiplier = 0.7
	if Globalvars.EnzoMiniCombo >= 200 and Globalvars.EnzoMiniCombo < 300:
		$Combo/MiniComboBackground.self_modulate = Color(0.9, 0, 0.9, 1)
	if Globalvars.EnzoMiniCombo >= 300:
		$Combo/MiniComboBackground.self_modulate = Color(0.8, 0.6, 1, 1)
		miniComboMultiplier = 1
	if Globalvars.EnzoMiniCombo < 10:
		MiniComboNumber1.play(str(Globalvars.EnzoMiniCombo).pad_zeros(3)[-1])
		$Combo/MiniComboNumber1.position = Vector2(724, 265)
		$Combo/MiniComboNumber2.visible = false
		$Combo/MiniComboNumber3.visible = false
	if Globalvars.EnzoMiniCombo >= 10 and Globalvars.EnzoMiniCombo < 100:
		MiniComboNumber1.play(str(Globalvars.EnzoMiniCombo).pad_zeros(3)[-1])
		$Combo/MiniComboNumber1.position = Vector2(733, 265)
		MiniComboNumber2.play(str(Globalvars.EnzoMiniCombo).pad_zeros(3)[-2])
		$Combo/MiniComboNumber2.position = Vector2(715, 265)
		$Combo/MiniComboNumber2.visible = true
		$Combo/MiniComboNumber3.visible = false
	if Globalvars.EnzoMiniCombo >= 100:
		MiniComboNumber1.play(str(Globalvars.EnzoMiniCombo).pad_zeros(3)[-1])
		$Combo/MiniComboNumber1.position = Vector2(741, 265)
		MiniComboNumber2.play(str(Globalvars.EnzoMiniCombo).pad_zeros(3)[-2])
		$Combo/MiniComboNumber2.position = Vector2(724, 265)
		$Combo/MiniComboNumber2.visible = true
		MiniComboNumber3.play(str(Globalvars.EnzoMiniCombo).pad_zeros(3)[-3])
		$Combo/MiniComboNumber3.position = Vector2(707, 265)
		$Combo/MiniComboNumber3.visible = true

func handleMultiplier() -> void:
	Globalvars.EnzoScoreMultiplier = 1 + miniComboMultiplier + comboMultiplier
	MultiNumber1.play(str(Globalvars.EnzoScoreMultiplier).pad_decimals(1)[-1])
	MultiNumber2.play(str(Globalvars.EnzoScoreMultiplier).pad_decimals(1)[-3])

func handleScore() -> void:
	##.pad_zeros makes it so that the score says, for example, 000100 instead of 100
	Score1.play(str(Globalvars.EnzoScore).pad_zeros(6)[-1])
	Score2.play(str(Globalvars.EnzoScore).pad_zeros(6)[-2])
	Score3.play(str(Globalvars.EnzoScore).pad_zeros(6)[-3])
	Score4.play(str(Globalvars.EnzoScore).pad_zeros(6)[-4])
	Score5.play(str(Globalvars.EnzoScore).pad_zeros(6)[-5])
	Score6.play(str(Globalvars.EnzoScore).pad_zeros(6)[-6])

func handlePortrait() -> void:
	if Globalvars.EnzoState == 13 or Globalvars.EnzoState == 15 or Globalvars.EnzoState == 16:
		SpubbleDelay.start()
		SpeechBubble.play("Hurt")
	elif Globalvars.EnzoHealth <= 1: 
		if SpubbleDelay.time_left == 0:
			SpeechBubble.play("LowHP")
			SpubbleDelay.start()
	else:
		if SpubbleDelay.time_left == 0:
			if Globalvars.EnzoCombo < 3:
				SpeechBubble.play("Idle")
			else:
				SpeechBubble.play("Combo")

func _on_enzo_hurt() -> void:
	Overlay.play("Hurt")
func _on_enzo_heal() -> void:
	pass
func _on_combo_update() -> void:
	ComboTimer.start()
func _on_minicombo_update() -> void:
	MiniComboTimer.start()
