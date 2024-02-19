shader_type canvas_item;

uniform bool active = false;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 black_color = vec4(0.25, 0.25, 0.25, previous_color.a);
	vec4 new_color = previous_color;
	
	if (active == true) {
		new_color = black_color;
	}
	
	COLOR = new_color;
}
