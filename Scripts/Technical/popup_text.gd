extends Node2D

@onready var popup_text: Label = $Text
@onready var animation_player: AnimationPlayer = $Text/AnimationPlayer

var popuptext_position: Vector2
var popuptext_text: String
var popuptext_size: int
var popuptext_color: Color = Color.WHITE
var popuptext_animation: String = "Jump"
var popuptext_anim_speed: float = 1.0
var popuptext_font: FontFile = load("res://Fonts/Small Feedback Text.png")
var popuptext_font_character_spacing: int = 0

func _ready() -> void:
	global_position = popuptext_position
	popup_text.text = popuptext_text
	popup_text.add_theme_font_size_override("font_size", popuptext_size)
	popup_text.modulate = popuptext_color
	animation_player.play(popuptext_animation, -1, popuptext_anim_speed)
	var new_font: FontVariation = FontVariation.new()
	new_font.base_font = popuptext_font
	new_font.spacing_glyph = popuptext_font_character_spacing
	popup_text.add_theme_font_override("font", new_font)
	animation_player.animation_finished.connect(queue_free)
