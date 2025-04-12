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
@onready var ComboNumbers: AnimationPlayer = $Combo/ComboNumbers/AnimationPlayer
@onready var ComboTimer: Timer = $Combo/ComboTimer

var health = Globalvars.EnzoHealthArr
var regen = Globalvars.EnzoRegenArr

func _ready() -> void:
	Overlay.play("Idle")

func _physics_process(_delta: float) -> void:
	$ScoreLabel.text = str(Overlay.current_animation)
	set_health()
	# Hearts
	if Globalvars.EnzoHurt:
		Overlay.play("Hurt")
	if Globalvars.EnzoHealth == 0:
		Overlay.play("Black Screen of Death")
		if get_tree():
			await get_tree().create_timer(3.5).timeout
		if get_tree():
			Globalvars.EnzoScore = 000000
			Globalvars.EnzoHealth = 5
			Globalvars.EnzoHealthArr = [3, 3, 3, 3, 3, 0, 0, 0, 0, 0]
			get_tree().reload_current_scene()
	# Speech bubble
	## States. in order
	## 0-4 IDLE, JUMPING, FALLING, WALKING, RUNNING, 
	## 5-9 SPRINTING, JUMPSPRINTING, FALLSPRINTING, HALTING, CHARGEPUNCHING, 
	## 10-14 PUNCHINGWEAK, PUNCHINGMID, PUNCHINGSTRONG, HURT, DEAD, 
	## 15-19 BURNJUMPING, BURNRUNNING, CROUCHPREP, CROUCHING, BLOCKPREP, 
	## 20 BLOCKING
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
	#Score
	##.pad_zeros makes it so that the score says, for example, 000100 instead of 100
	Score1.play(str(Globalvars.EnzoScore).pad_zeros(6)[5])
	Score2.play(str(Globalvars.EnzoScore).pad_zeros(6)[4])
	Score3.play(str(Globalvars.EnzoScore).pad_zeros(6)[3])
	Score4.play(str(Globalvars.EnzoScore).pad_zeros(6)[2])
	Score5.play(str(Globalvars.EnzoScore).pad_zeros(6)[1])
	Score6.play(str(Globalvars.EnzoScore).pad_zeros(6)[0])
	#Combo
	ComboNumbers.play(str(Globalvars.EnzoCombo))
	ComboTimeBar.value = ComboTimer.time_left
	if Globalvars.EnzoCombo > 5:
		ComboTimer.wait_time = Globalvars.EnzoCombo * 1.3
	else:
		ComboTimer.wait_time = 5
	if Globalvars.EnemyKilledRecently == true:
		ComboTimer.start()
	if ComboTimer.time_left == 0:
		Globalvars.EnzoCombo = 0

func set_health():
	Heart1.play(str(health[0]))
	Heart2.play(str(health[1]))
	Heart3.play(str(health[2]))
	Heart4.play(str(health[3]))
	Heart5.play(str(health[4]))
	Heart6.play(str(health[5]))
	Heart7.play(str(health[6]))
	Heart8.play(str(health[7]))
	Heart9.play(str(health[8]))
	Heart10.play(str(health[9]))
	Regen5.play(str(regen[0]))
	Regen4.play(str(regen[1]))
	Regen3.play(str(regen[2]))
	Regen2.play(str(regen[3]))
	Regen1.play(str(regen[4]))
