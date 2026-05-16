shader_type canvas_item;

uniform vec4 origin_colors[3]: source_color;
uniform vec4 new_colors[3]: source_color;
uniform int swap_count : hint_range(0, 3) = 3;
varying vec4 modulate_color;

void vertex() {
	modulate_color = COLOR;
}

void fragment() {
	vec4 current_pixel_color = texture(TEXTURE, UV);
	vec4 target_color = current_pixel_color * modulate_color;
	for (int i = 0; i < swap_count; i++) {
		if (distance(current_pixel_color, origin_colors[i]) < 0.01) {
			target_color = new_colors[i];
		}
	}
	
	COLOR = target_color;
}
