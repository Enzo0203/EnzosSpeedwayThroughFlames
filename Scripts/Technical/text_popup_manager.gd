extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var popuptext_text: String
var popuptext_color: Color = Color.WHITE
var popuptext_animation: String = "Jump"
var popuptext_font: FontFile = load("res://Fonts/Small Feedback Text.png")
var popuptext_font_character_spacing: int = 0

func _ready() -> void:
	modulate = popuptext_color
	animation_player.play(popuptext_animation)
	var new_font: FontVariation = FontVariation.new()
	new_font.base_font = popuptext_font
	new_font.spacing_glyph = popuptext_font_character_spacing
	add_theme_font_override("Popup_Font", new_font)

func popup_text(\
display_text: String, \
popup_position: Vector2, \
color: Color = Color.WHITE, \
animation: String = "Jump", \
font: FontFile = load("res://Fonts/Small Feedback Text.png"), \
font_character_spacing: int = 0\
) -> void:
	var popuptext: PackedScene = load("res://Scenes/Miscellaneous/text_popup_manager.tscn")
	var popuptext_instance: Node = popuptext.instantiate()
	popuptext_instance.text = display_text
	popuptext_instance.global_position = popup_position
	popuptext_instance.popuptext_color = color
	popuptext_instance.popuptext_animation = animation
	popuptext_instance.popuptext_font = font
	popuptext_instance.popuptext_font_character_spacing = font_character_spacing
	get_parent().add_child(popuptext_instance)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("input_jump"):
		popup_text("JUMP!", Vector2(500, 500))
