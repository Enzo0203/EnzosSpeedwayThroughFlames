extends CanvasLayer

@onready var dialogue: RichTextLabel = $RichTextLabel
@onready var press_button_cue: AnimatedSprite2D = $PressButton

@export var text_speed: float = 0.03
@export var text_speed_comma: float = 0.07
@export var text_speed_full_stops: float = 0.2
@export var text_is_skippable: bool = true

var dialogue_script: Array = [
"You dumb bitches! ", speed.bind(0.01), "You", delay.bind(0.2), speed.bind(0.06),
" stupid ", delay.bind(0.2), speed.bind(0.01), "fucking ", delay.bind(0.3), "bitches! ", end_line,
speed.bind(0.03),
"My ", delay.bind(0.3), "ass ", delay.bind(0.3), "itches!", end_line,
"""Scratch my ass... PERMANENTLY!""", end_line,
"""This is MY Speedway Through Flames, motherfucker!""", end_line
]

func _ready() -> void:
	press_button_cue.hide()
	reset()
	proceed_script()

var waiting_for_press: bool

func _physics_process(_delta: float) -> void:
	$Label.text = str(dialogue_script)

signal input_skip_dialogue
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("input_jump"):
		input_skip_dialogue.emit()
	if event.is_action_pressed("input_punch"):
		input_force_skip()

func input_force_skip() -> void:
	pass

func proceed_script() -> void:
	if not dialogue_script.is_empty():
		if dialogue_script[0] is String:
			type(dialogue_script.pop_front())
		elif dialogue_script[0] is Callable:
			dialogue_script.pop_front().call()

func end_line(force_skip: bool = false) -> void:
	if force_skip == false:
		press_button_cue.show()
		await input_skip_dialogue
		press_button_cue.hide()
	reset()
	proceed_script()

func delay(time: float) -> void:
	await get_tree().create_timer(time).timeout
	proceed_script()

func speed(time: float) -> void:
	text_speed = time
	proceed_script()

func reset() -> void:
	dialogue.text = ""
	dialogue.visible_characters = 0

signal line_ended
func type(text: String) -> void:
	dialogue.text += text
	for letter: int in text.length():
		dialogue.visible_characters += 1
		if dialogue.text[dialogue.visible_characters - 1] in ",":
			$Portrait/AnimationPlayer.seek(0.0, true)
			await get_tree().create_timer(text_speed_comma).timeout
		elif dialogue.text[dialogue.visible_characters - 1] in ".!?-":
			$Portrait/AnimationPlayer.seek(0.0, true)
			await get_tree().create_timer(text_speed_full_stops).timeout
		else:
			$Portrait/AnimationPlayer.advance(0.05)
			await get_tree().create_timer(text_speed).timeout
	$Portrait/AnimationPlayer.seek(0.0, true)
	line_ended.emit()
	proceed_script()
