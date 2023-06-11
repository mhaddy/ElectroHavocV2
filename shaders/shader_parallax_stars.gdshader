// Starfield shader v3 by Brian Smith (steampunkdemon.itch.io)
// MIT licence

shader_type canvas_item;

// Comment out the following line if you are not applying the shader to a ColorRect:
uniform vec2 dimensions = vec2(1024.0, 600.0); // Resolution of ColorRect in pixels

uniform float small_stars = 50.0; // Number of small stars. Rows for horizontally scrolling stars or columns for vertically scrolling stars.
uniform float small_star_far_size : hint_range(0.1, 1.0, 0.1) = 0.5;
uniform float small_star_near_size : hint_range(0.1, 1.0, 0.1) = 1.0;
uniform float large_stars = 8.0; // Number of large stars. Rows for horizontally scrolling stars or columns for vertically scrolling stars.
uniform float large_star_far_size : hint_range(0.1, 1.0, 0.1) = 0.5;
uniform float large_star_near_size : hint_range(0.1, 1.0, 0.1) = 1.0;
uniform vec4 far_star_color : source_color = vec4(0.50, 0.0, 1.0, 1.0);
uniform vec4 near_star_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float base_scroll_speed : hint_range(0.0, 1.0, 0.01) = 0.05;
uniform float additional_scroll_speed : hint_range(0.01, 1.0, 0.01) = 0.05;

float greater_than(float x, float y) {
	return max(sign(x - y), 0.0);
}

void fragment() {
// The below line will scroll the stars from right to left or from bottom to top.
// To make the stars scroll in the opposite direction change the line to:
//	float time = 10000.0 - TIME;
// Alternativly you can comment out the below line and add a new uniform above as:
// uniform float time = 10000.0;
// You can then update the time uniform from your _physics_process function by adding or subtracting delta. You can also pause the scrolling by not changing the time uniform.
	float time = 10000.0 + TIME;

// Comment out the following two lines if you are not applying the shader to a TextureRect:
//	COLOR = texture(TEXTURE,UV);
//	vec2 dimensions = 1.0 / TEXTURE_PIXEL_SIZE;

// Horizontal scrolling:
	float small_stars_rn = fract(sin(floor(UV.y * small_stars)) * dimensions.y);
	float large_stars_rn = fract(sin(floor(UV.y * large_stars)) * dimensions.y);
	vec2 small_stars_uv = vec2(fract(UV.x + (base_scroll_speed + small_stars_rn * additional_scroll_speed) * time) * small_stars * dimensions.x / dimensions.y, fract(UV.y * small_stars)) * 2.0 - 1.0;
	vec2 large_stars_uv = vec2(fract(UV.x + (base_scroll_speed + large_stars_rn * additional_scroll_speed) * time) * large_stars * dimensions.x / dimensions.y, fract(UV.y * large_stars)) * 2.0 - 1.0;

// Vertical scrolling:
//	float small_stars_rn = fract(sin(floor(UV.x * small_stars)) * dimensions.x);
//	float large_stars_rn = fract(sin(floor(UV.x * large_stars)) * dimensions.x);
//	vec2 small_stars_uv = vec2(fract(UV.x * small_stars), fract(UV.y + (base_scroll_speed + small_stars_rn * additional_scroll_speed) * time) * small_stars * dimensions.y / dimensions.x) * 2.0 - 1.0;
//	vec2 large_stars_uv = vec2(fract(UV.x * large_stars), fract(UV.y + (base_scroll_speed + large_stars_rn * additional_scroll_speed) * time) * large_stars * dimensions.y / dimensions.x) * 2.0 - 1.0;

	vec4 star_color = mix(far_star_color, near_star_color, small_stars_rn);
	float star_size = small_star_far_size + (small_star_near_size - small_star_far_size) * small_stars_rn;

// Render small stars as circles with soft edges:
	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, max((star_size - length(small_stars_uv)) / star_size, 0.0) * star_color.a);

// Render small stars as circles with hard edges:
//	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, greater_than(star_size, length(small_stars_uv)) * star_color.a);

// Render small stars as crosses with soft edges:
//	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, max((star_size - length(small_stars_uv)) / star_size, 0.0) * (max(greater_than(star_size / 10.0, abs(small_stars_uv.x)), greater_than(star_size / 10.0, abs(small_stars_uv.y)))) * star_color.a);

// Render small stars as crosses with hard edges:
//	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, max(greater_than(star_size / 5.0, abs(small_stars_uv.x)) * greater_than(star_size, abs(small_stars_uv.y)), greater_than(star_size / 5.0, abs(small_stars_uv.y)) * greater_than(star_size, abs(small_stars_uv.x))) * star_color.a);

// Render small stars as squares:
//	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, greater_than(star_size, abs(small_stars_uv.x)) * greater_than(star_size, abs(small_stars_uv.y)) * star_color.a);

// Render small stars as diamonds:
//	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, greater_than(star_size, abs(small_stars_uv.y) + abs(small_stars_uv.x)) * star_color.a);

	star_color = mix(far_star_color, near_star_color, large_stars_rn);
	star_size = large_star_far_size + (large_star_near_size - large_star_far_size) * large_stars_rn;

// Render large stars with circles and crosses with smooth edges:
	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, (max((star_size / 1.7 - length(large_stars_uv)) / star_size, 0.0) + max((star_size - length(large_stars_uv)) / star_size / 2.0, 0.0) * (max(greater_than(star_size / 10.0, abs(large_stars_uv.x)), greater_than(star_size / 10.0, abs(large_stars_uv.y))))) * star_color.a);

// Render large stars as circles with hard edges:
//	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, greater_than(star_size, length(large_stars_uv)) * star_color.a);

// Render large stars as crosses with soft edges:
//	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, max((star_size - length(large_stars_uv)) / star_size, 0.0) * (max(greater_than(star_size / 10.0, abs(large_stars_uv.x)), greater_than(star_size / 10.0, abs(large_stars_uv.y)))) * star_color.a);

// Render large stars as crosses with hard edges:
//	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, max(greater_than(star_size / 5.0, abs(large_stars_uv.x)) * greater_than(star_size, abs(large_stars_uv.y)), greater_than(star_size / 5.0, abs(large_stars_uv.y)) * greater_than(star_size, abs(large_stars_uv.x))) * star_color.a);

// Render large stars as squares:
//	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, greater_than(star_size, abs(large_stars_uv.x)) * greater_than(star_size, abs(large_stars_uv.y)) * star_color.a);

// Render large stars as diamonds:
//	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, greater_than(star_size, abs(large_stars_uv.y) + abs(large_stars_uv.x)) * star_color.a);
}