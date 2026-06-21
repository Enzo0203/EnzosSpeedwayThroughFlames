extends Node2D

func popup_text(\
display_text: String, \
popup_position: Vector2, \
color: Color = Color.WHITE, \
animation: String = "Jump", \
animation_speed: float = 1.0, \
font: FontFile = load("res://Fonts/Small Feedback Text.png"), \
font_character_spacing: int = 0\
) -> void:
	var popuptext_instance: Node = load("res://Scenes/Miscellaneous/popup_text_scene.tscn").instantiate()
	popuptext_instance.popuptext_text = display_text
	popuptext_instance.popuptext_position = popup_position
	popuptext_instance.popuptext_color = color
	popuptext_instance.popuptext_animation = animation
	popuptext_instance.popuptext_anim_speed = animation_speed
	popuptext_instance.popuptext_font = font
	popuptext_instance.popuptext_font_character_spacing = font_character_spacing
	get_parent().add_child(popuptext_instance)
