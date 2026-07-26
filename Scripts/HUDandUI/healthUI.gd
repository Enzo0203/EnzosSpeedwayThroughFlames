extends Control

@onready var Overlay: AnimationPlayer = $Overlay/AnimationPlayer
@onready var SpubbleDelay: Timer = $SpeechBubbleDelay
@onready var Score1: AnimationPlayer = $Score/Score1/AnimationPlayer
@onready var Score2: AnimationPlayer = $Score/Score2/AnimationPlayer
@onready var Score3: AnimationPlayer = $Score/Score3/AnimationPlayer
@onready var Score4: AnimationPlayer = $Score/Score4/AnimationPlayer
@onready var Score5: AnimationPlayer = $Score/Score5/AnimationPlayer
@onready var Score6: AnimationPlayer = $Score/Score6/AnimationPlayer

@onready var ComboTimeBar: TextureProgressBar = $Combo/ComboTimeBar
@onready var ComboNumbers: Label = $Combo/ComboNumbers
@onready var ComboTimer: Timer = $Combo/ComboTimer

@onready var MiniComboTimeBar: TextureProgressBar = $Combo/MiniComboTimeBar
@onready var MiniComboNumbers: Label = $Combo/MiniComboNumbers
@onready var MiniComboTimer: Timer = $Combo/MiniComboTimer

var miniComboMultiplier: float = 0
var comboMultiplier: float = 0

func _ready() -> void:
	visible = true
	$"..".visible = true
	Overlay.play("SceneTransition")
	Globalvars.EnzoHurt.connect(_on_enzo_hurt)
	Globalvars.EnzoHeal.connect(_on_enzo_heal)
	Globalvars.EnzoDeath.connect(_on_enzo_death)
	Globalvars.EnzoComboUpdated.connect(_on_combo_update)
	Globalvars.EnzoMiniComboUpdated.connect(_on_minicombo_update)

func _physics_process(_delta: float) -> void:
	if Globalvars.Enzo:
		Globalvars.Enzo.health_manager.reparent($Hearts)
		Globalvars.Enzo.health_manager.visible = true
		Globalvars.Enzo.health_manager.global_position = $Hearts/LeftHealthbarLocation.global_position
		if Overlay.is_playing() == false or Overlay.current_animation == "SceneTransition":
			$Overlay.visible = true
			Overlay.play("Idle")
		#handlePortrait()
		handleCombo()
		handleMiniCombo()
		handleMultiplier()
		handleScore()
	if get_tree().paused:
		visible = false
	elif Globalvars.Enzo and Globalvars.LevelEndSequence == 0:
		visible = true
	if Globalvars.LevelEndSequence == 1:
		visible = false

func handleCombo() -> void:
	ComboNumbers.text = str(Globalvars.EnzoCombo)
	if Globalvars.EnzoCombo > 0:
		ComboTimeBar.value = ComboTimer.time_left
		ComboTimer.wait_time = Globalvars.EnzoCombo * 2
		ComboTimer.wait_time = max(ComboTimer.wait_time, 4)
		ComboTimer.wait_time = min(ComboTimer.wait_time, ComboTimeBar.max_value)
	if ComboTimer.time_left == 0:
		Globalvars.EnzoCombo = 0
	if Globalvars.EnzoCombo < 10:
		comboMultiplier = 0
	if Globalvars.EnzoCombo >= 10 and Globalvars.EnzoCombo < 100:
		comboMultiplier = 1
	if Globalvars.EnzoCombo >= 100:
		comboMultiplier = 1.5
	if Globalvars.EnzoCombo > Globalvars.EnzoMaxCombo:
		Globalvars.EnzoMaxCombo = Globalvars.EnzoCombo

func handleMiniCombo() -> void:
	MiniComboNumbers.text = str(Globalvars.EnzoMiniCombo)
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

func handleMultiplier() -> void:
	Globalvars.EnzoScoreMultiplier = 1 + miniComboMultiplier + comboMultiplier
	$Combo/MultiplierNumbers.text = str(Globalvars.EnzoScoreMultiplier).pad_decimals(1)

func handleScore() -> void:
	##.pad_zeros makes it so that the score says, for example, 000100 instead of 100
	Score1.play(str(Globalvars.EnzoScore).pad_zeros(6)[-1])
	Score2.play(str(Globalvars.EnzoScore).pad_zeros(6)[-2])
	Score3.play(str(Globalvars.EnzoScore).pad_zeros(6)[-3])
	Score4.play(str(Globalvars.EnzoScore).pad_zeros(6)[-4])
	Score5.play(str(Globalvars.EnzoScore).pad_zeros(6)[-5])
	Score6.play(str(Globalvars.EnzoScore).pad_zeros(6)[-6])

#func handlePortrait() -> void:
	#if Globalvars.EnzoState == 13 or Globalvars.EnzoState == 15 or Globalvars.EnzoState == 16:
		#SpubbleDelay.start()
		#SpeechBubble.play("Hurt")
	#elif Globalvars.EnzoHealth <= 1: 
		#if SpubbleDelay.time_left == 0:
			#SpeechBubble.play("LowHP")
			#SpubbleDelay.start()
	#else:
		#if SpubbleDelay.time_left == 0:
			#if Globalvars.EnzoCombo < 3:
				#SpeechBubble.play("Idle")
			#else:
				#SpeechBubble.play("Combo")

func _on_enzo_hurt() -> void:
	Overlay.play("Hurt")

func _on_enzo_heal() -> void:
	pass

func _on_enzo_death() -> void:
	Overlay.play("Death")
	if get_tree():
		await get_tree().create_timer(3.5, false).timeout
	if get_tree():
		Globalvars.EnzoKills = 0
		Globalvars.EnzoScore = 000000
		Globalvars.EnzoHealth = 5
		Globalvars.EnzoHealthArr = [3, 3, 3, 3, 3, 0, 0, 0, 0, 0]
		await get_tree().process_frame
		if get_tree():
			get_tree().reload_current_scene()

func _on_combo_update() -> void:
	ComboTimer.start()

func _on_minicombo_update() -> void:
	MiniComboTimer.start()
