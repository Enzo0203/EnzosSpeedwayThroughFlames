shader_type canvas_item;

group_uniforms PaletteSwap;
uniform vec4 origin_colors[3]: source_color;
uniform vec4 new_colors[3]: source_color;
uniform int swap_count = 3;

group_uniforms Rimlight;
global uniform bool environmental_rimlight = false;
global uniform vec4 environmental_rimlight_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

group_uniforms Modulate;
global uniform vec4 environmental_modulate: source_color = vec4(1.0, 1.0, 1.0, 1.0);

varying vec4 modulate_color;
void vertex() {
	modulate_color = COLOR;
}

varying float is_rimlight;
varying vec3 pre_rimlight_rgb;

void fragment() {
	is_rimlight = 0.0;
	
	vec4 current_pixel_color = texture(TEXTURE, UV);
	
	// Palette swapper
	vec4 target_color = current_pixel_color;
	for (int i = 0; i < swap_count; i++) {
		if (distance(current_pixel_color, origin_colors[i]) < 0.01) {
			target_color = new_colors[i];
		}
	}
	
	// Modulate
	vec4 modulated_pixel = target_color * modulate_color * environmental_modulate;
	pre_rimlight_rgb = modulated_pixel.rgb;
	
	// Rimlight
	if (environmental_rimlight == true) {
		vec4 pixel_above = texture(TEXTURE, UV + vec2(0.0, -TEXTURE_PIXEL_SIZE.y));
		
		if (modulated_pixel.a != 0.0 && pixel_above.a == 0.0) {
			COLOR = vec4(environmental_rimlight_color.rgb, modulated_pixel.a);
			is_rimlight = 1.0;
		} else {
			COLOR = modulated_pixel;
		}
	} else {
		COLOR = modulated_pixel;
	}
}

void light() {
	vec3 original_color = COLOR.rgb / max(environmental_modulate.rgb, vec3(0.001));
	
	if (is_rimlight > 0.5) { 
		// If illuminated pixel is a rimlight, reverse the rimlight effect
		// And also reverse environmental_modulate
		vec3 unmodulated_pre_rimlight = pre_rimlight_rgb / max(environmental_modulate.rgb, vec3(0.001));
		LIGHT.rgb = unmodulated_pre_rimlight - (COLOR.rgb / max(LIGHT_COLOR.rgb, vec3(0.001)));
		
	} else {
		// If pixel is illuminated, reverse environmental_modulate
		LIGHT.rgb = original_color - COLOR.rgb; 
	}
	
	LIGHT.a = LIGHT_COLOR.a;
}
