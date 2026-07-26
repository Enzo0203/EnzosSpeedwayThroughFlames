class_name HealthManager extends Node2D

@onready var RegenOutlineTimer: Timer = $RegenOutlineTimer
@onready var healthbar: TextureProgressBar = $Visuals/Regular/Healthbar

@onready var heart1: Sprite2D = $Visuals/Segmented/Heart1
@onready var heartOutline1: Sprite2D = $Visuals/Segmented/HeartOutline1

# ------------------------------General------------------------------

@export_category("General")

enum HealthTypes {
	## Takes varied damage. Represented by a bar.
	REGULAR,
	## Takes 1 damage at a time, with certain exceptions. Represented by Hearts.
	## Used by Enzo.
	SEGMENTED
}

## What type of health this is.
@export var HealthType: HealthTypes

## Emit [signal dead] when health is zero or all hearts are empty.
@export var ZeroHealthMeansDeath: bool = true

## Emitted when health is zero or all hearts are empty.
@warning_ignore("unused_signal")
signal zeroHealth

## Emitted when health is zero or all hearts are empty and [member DieOnZeroHealth]
## is [code]true[/code].
@warning_ignore("unused_signal")
signal dead

func _ready() -> void:
	$Visuals/Dmg.button_down.connect(deal_damage.bind(2, 2))
	$Visuals/Heal.button_down.connect(heal.bind(2, 2))
	$Visuals/Blue.button_down.connect(give_blue_heart.bind(2))
	$Visuals/Regen.button_down.connect(give_regen_outline.bind(1))
	
	_build_segmented_hearts()
	_build_segmented_heart_outlines()

func _build_segmented_hearts() -> void:
	# Clone the first heart and move each clone in a grid pattern
	var current_pos: Vector2 = heart1.position
	
	for x: int in range(hearts.size() - 1):
		# Move down once every heartSpriteRowAmount loops
		if x % heartSpriteRowAmount == heartSpriteRowAmount - 1:
			current_pos.x = heart1.position.x
			current_pos.y += heartSpriteSeparation.y
		else:
			current_pos.x += heartSpriteSeparation.x

		var new_heart: Sprite2D = heart1.duplicate()
		new_heart.name = "Heart" + str(x + 2)
		$Visuals/Segmented.add_child(new_heart)
		new_heart.position = current_pos

	# Assign starting animations
	for x : int in range(hearts.size()):
		match hearts[x]:
			HeartTypes.EMPTY:
				play_heart_animation(x, "Empty")
			HeartTypes.RED:
				play_heart_animation(x, "Red")
			HeartTypes.REDEMPTY:
				play_heart_animation(x, "RedEmpty")
			HeartTypes.BLUE:
				play_heart_animation(x, "Blue")

func _build_segmented_heart_outlines() -> void:
	# Make sure there aren't more outlines than hearts
	if heartOutlines.size() > hearts.size():
		heartOutlines.resize(hearts.size())
	
	# Clone the first heart and move each clone in a grid pattern
	var current_pos: Vector2 = heartOutline1.position
	
	for x: int in range(heartOutlines.size() - 1):
		# Move down once every heartSpriteRowAmount loops
		if x % heartSpriteRowAmount == heartSpriteRowAmount - 1:
			current_pos.x = heartOutline1.position.x
			current_pos.y += heartSpriteSeparation.y
		else:
			current_pos.x += heartSpriteSeparation.x

		var new_outline: Sprite2D = heartOutline1.duplicate()
		new_outline.name = "HeartOutline" + str(x + 2)
		$Visuals/Segmented.add_child(new_outline)
		new_outline.position = current_pos

	# Assign starting animations
	for x : int in range(heartOutlines.size()):
		match heartOutlines[x]:
			OutlineTypes.EMPTY:
				play_heart_outline_animation(x, "Empty")
			OutlineTypes.REGEN:
				play_heart_outline_animation(x, "Regen")

func _update_healthbar() -> void:
	healthbar.value = health
	healthbar.max_value = maxHealth
	healthbar.size.x = max(24, 12 * maxHealth)

func _show_healthtype() -> void:
	if HealthType == HealthTypes.REGULAR:
		$Visuals/Regular.show()
		$Visuals/Segmented.hide()
	if HealthType == HealthTypes.SEGMENTED:
		$Visuals/Regular.hide()
		$Visuals/Segmented.show()

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	_regen_outline_check()
	_check_if_dead()
	_update_healthbar()
	_show_healthtype()

func deal_damage(regularDmg: int, segmentedDmg: int) -> void:
	if HealthType == HealthTypes.REGULAR:
		health -= min(regularDmg, health)
	if HealthType == HealthTypes.SEGMENTED:
		if RegenOutlineTimer.is_stopped() == false:
			regenJustBroke = true
		for amount: int in range(min(totalHeartAmount, segmentedDmg)):
			if hearts.filter(is_not_empty_heart)[-1] == HeartTypes.BLUE:
				play_heart_animation(hearts.rfind(HeartTypes.BLUE), "BlueHurt")
				hearts[hearts.rfind(HeartTypes.BLUE)] = HeartTypes.EMPTY
			elif hearts.filter(is_not_empty_heart)[-1] == HeartTypes.RED:
				play_heart_animation(hearts.rfind(HeartTypes.RED), "RedHurt")
				hearts[hearts.rfind(HeartTypes.RED)] = HeartTypes.REDEMPTY

func heal(regularHeal: int, segmentedHeal: int) -> void:
	if is_dead:
		return
	if HealthType == HealthTypes.REGULAR:
		health += min(regularHeal, maxHealth - health)
	if HealthType == HealthTypes.SEGMENTED:
		for amount: int in segmentedHeal:
			if hearts.has(HeartTypes.REDEMPTY):
				play_heart_animation(hearts.find(HeartTypes.REDEMPTY), "RedHeal")
				hearts[hearts.find(HeartTypes.REDEMPTY)] = HeartTypes.RED
			elif heartOutlines.has(OutlineTypes.EMPTY) and overhealBecomesRegen:
				give_regen_outline(1)
			else:
				pass

var is_dead:bool = false

func _check_if_dead() -> void:
	if health <= 0 or hearts.all(is_empty_heart):
		if ZeroHealthMeansDeath and not is_dead:
			heartOutlines.fill(OutlineTypes.EMPTY)
			dead.emit()
			is_dead = true

# -------------------------------Regular------------------------------

@export_category("Regular")

@export var maxHealth: int = 5
@export var health: int = 5

# ------------------------------Segmented------------------------------

@export_category("Segmented")

enum HeartTypes {EMPTY, REDEMPTY, RED, BLUE}
@export var hearts: Array[HeartTypes] = [
	HeartTypes.RED, HeartTypes.RED, HeartTypes.RED, HeartTypes.RED, HeartTypes.RED]

enum OutlineTypes {EMPTY, REGEN}
@export var heartOutlines: Array[OutlineTypes] = [
	OutlineTypes.EMPTY, OutlineTypes.EMPTY, OutlineTypes.EMPTY, \
	OutlineTypes.EMPTY, OutlineTypes.EMPTY]

@export var overhealBecomesRegen: bool = false
@export var heartSpriteSeparation: Vector2 = Vector2(48, 50)
@export var heartSpriteRowAmount: int = 5

# Returns the amount of hearts that aren't empty
var totalHeartAmount: int:
	get:
		return hearts.filter(is_not_empty_heart).size()

# Returns the amount of red hearts
var redHeartAmount: int:
	get:
		return hearts.filter(\
		func(value: HeartTypes) -> bool: return value == HeartTypes.RED\
		).size()

# Returns the amount of empty red heart containers
var redHeartContainerAmount: int:
	get:
		return hearts.filter(is_empty_red_heart_container).size()

# Returns the amount of empty slots
var emptyAmount: int:
	get:
		return hearts.filter(\
		func(value: HeartTypes) -> bool: return value == HeartTypes.EMPTY\
		).size()

# Returns the amount of empty heart outline slots
var emptyOutlineAmount: int:
	get:
		return heartOutlines.filter(\
		func(value: OutlineTypes) -> bool: return value == OutlineTypes.EMPTY\
		).size()

func is_empty_heart(value: HeartTypes) -> bool:
	return value == HeartTypes.REDEMPTY or value == HeartTypes.EMPTY

func is_not_empty_heart(value: HeartTypes) -> bool:
	return value != HeartTypes.REDEMPTY and value != HeartTypes.EMPTY

func is_empty_red_heart_container(value: HeartTypes) -> bool:
	return value == HeartTypes.REDEMPTY

func is_red_heart_container(value: HeartTypes) -> bool:
	return value == HeartTypes.RED or value == HeartTypes.REDEMPTY

func give_blue_heart(heartAmount: int) -> void:
	if is_dead:
		return
	if HealthType == HealthTypes.SEGMENTED:
		for amount: int in range(min(emptyAmount, heartAmount)):
			play_heart_animation(hearts.find(HeartTypes.EMPTY), "BlueHeal")
			hearts[hearts.find(HeartTypes.EMPTY)] = HeartTypes.BLUE

func give_regen_outline(outlineAmount: int) -> void:
	if is_dead:
		return
	if HealthType == HealthTypes.SEGMENTED:
		for amount: int in range(outlineAmount):
			if rfind_container_without_outline() != -1:
				play_heart_outline_animation(\
				rfind_container_without_outline(),\
				"Regen")
				heartOutlines[rfind_container_without_outline()] = OutlineTypes.REGEN

var regenJustBroke: bool = false

func _regen_outline_check() -> void:
	# Remember: If RegenOutlineTimer times out, it heals 1.
	if heartOutlines.has(OutlineTypes.REGEN):
		# If there's an empty container without an outline, move the leftmost
		# regen outline to it. Otherwise, move every regen outline to the right
		if find_empty_container_without_outline() != -1:
			heartOutlines[heartOutlines.find(OutlineTypes.REGEN)] = OutlineTypes.EMPTY
			heartOutlines[find_empty_container_without_outline()] = OutlineTypes.REGEN
		else:
			move_regens_right()
		if redHeartContainerAmount > 0:
			if RegenOutlineTimer.is_stopped(): # Start healing
				RegenOutlineTimer.start()
			if regenJustBroke: # Took damage while trying to regen
				play_heart_outline_animation(heartOutlines.find(OutlineTypes.REGEN), "RegenHurt")
				heartOutlines[heartOutlines.find(OutlineTypes.REGEN)] = OutlineTypes.EMPTY
				RegenOutlineTimer.stop()
				regenJustBroke = false
		elif not RegenOutlineTimer.is_stopped(): # No containers are empty
			RegenOutlineTimer.stop()
	elif not RegenOutlineTimer.is_stopped(): # No more outlines
		RegenOutlineTimer.stop()

	for x: int in range(heartOutlines.size()):
		if heartOutlines[x] == OutlineTypes.REGEN:
			if hearts[x] == HeartTypes.REDEMPTY and x == hearts.find(HeartTypes.REDEMPTY):
				play_heart_outline_animation(x, "RegenHealing")
			else:
				play_heart_outline_animation(x, "Regen")
		elif heartOutlines[x] == OutlineTypes.EMPTY:
			play_heart_outline_animation(x, "Empty 2")

func _on_regen_outline_timer_timeout() -> void:
	heartOutlines[hearts.find(HeartTypes.REDEMPTY)] = OutlineTypes.EMPTY
	heal(0, 1)

func move_regens_right() -> void:
	for i: int in range(heartOutlines.size()):
		if heartOutlines[i] == OutlineTypes.REGEN:
			heartOutlines[i] = OutlineTypes.EMPTY
			heartOutlines[rfind_container_without_outline()] = OutlineTypes.REGEN

func find_empty_container_without_outline() -> int:
	for i: int in range(min(hearts.size(), heartOutlines.size())):
		if hearts[i] == HeartTypes.REDEMPTY and \
		heartOutlines[i] == OutlineTypes.EMPTY:
			return i
	return -1

func rfind_container_without_outline() -> int:
	for i: int in range(min(hearts.size(), heartOutlines.size()) - 1, -1, -1):
		if (hearts[i] == HeartTypes.RED or hearts[i] == HeartTypes.REDEMPTY) and \
		heartOutlines[i] == OutlineTypes.EMPTY:
			return i
	return -1


# ------------------------------Visuals------------------------------

func play_heart_animation(index: int, animation: String) -> void:
	get_node(str("Visuals/Segmented/Heart", \
	index + 1, #Because heart sprite names start at 1 instead of 0 \
	"/AnimationPlayer/AnimationTree"))["parameters/playback"].travel(str(animation))

func play_heart_outline_animation(index: int, animation: String) -> void:
	get_node(str("Visuals/Segmented/HeartOutline", \
	index + 1, #Because heart sprite names start at 1 instead of 0 \
	"/AnimationPlayer/AnimationTree"))["parameters/playback"].travel(str(animation))
