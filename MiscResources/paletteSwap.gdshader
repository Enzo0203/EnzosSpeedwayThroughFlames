shader_type canvas_item;

group_uniforms PaletteSwap;
// Palette Swapper origins and targets
uniform vec4 origin_colors[3]: source_color;
uniform vec4 new_colors[3]: source_color;
uniform int swap_count = 3;

group_uniforms Rimlight;
// Rimlight
uniform bool rimlight = false;
uniform vec4 rimlight_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

group_uniforms Modulate;
uniform vec4 extra_modulate: source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Make sure modulate still works
varying vec4 modulate_color;
void vertex() {
	modulate_color = COLOR;
}

void fragment() {
	vec4 current_pixel_color = texture(TEXTURE, UV);
	
	// Palette swapper
	vec4 target_color = current_pixel_color;
	for (int i = 0; i < swap_count; i++) {
		if (distance(current_pixel_color, origin_colors[i]) < 0.01) {
			target_color = new_colors[i];
		}
	}
	
	// Modulate
	vec4 modulated_pixel = target_color * modulate_color * extra_modulate;
	
	// Rimlight
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	vec2 uv_above = UV + vec2(0.0, -pixel_size.y);
	vec4 pixel_above = texture(TEXTURE, uv_above);
	if (modulated_pixel.a > 0.0 && rimlight == true && pixel_above.a == 0.0) {
		COLOR = vec4(rimlight_color.r, rimlight_color.g, rimlight_color.b, modulated_pixel.a);
	} else {
		COLOR = modulated_pixel;
	}
	
}

void light() {
	
}