shader_type canvas_item;

uniform vec4 origin_color: source_color;
uniform vec4 new_color: source_color;

varying vec4 modulate_color;

void vertex() {
	modulate_color = COLOR;
}

void fragment() {
	//Palette swapper
	vec4 current_pixel_color = texture(TEXTURE, UV);
	if (current_pixel_color == origin_color) {
		COLOR = new_color;
	} else {
		COLOR = current_pixel_color * modulate_color;
	}
}
