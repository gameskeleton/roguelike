shader_type canvas_item;

uniform vec4 rain_color : source_color = vec4(0.8, 0.8, 0.8, 0.5);
uniform float slant : hint_range(-1.0, 1.0) = -0.2;
uniform float rain_amount = 100.0;
uniform float base_rain_speed : hint_range(0.1, 1.0) = 1.0;
uniform float additional_rain_speed : hint_range(0.1, 1.0) = 1.0;
uniform float far_rain_length : hint_range(0.01, 1.0) = 0.1;
uniform float near_rain_length : hint_range(0.01, 1.0) = 0.2;
uniform float far_rain_width : hint_range(0.1, 1.0) = 0.1;
uniform float near_rain_width : hint_range(0.1, 1.0) = 0.2;
uniform float far_rain_transparency : hint_range(0.1, 1.0) = 0.75;
uniform float near_rain_transparency : hint_range(0.1, 1.0) = 0.5;

void fragment() {
	float time = 10000.0 + TIME;

	float col_edge = mod(UV.x - UV.y * slant, 1.0 / rain_amount);
	float slanted_uv = (UV.x - UV.y * slant) - col_edge;
	float random_noise = fract(sin(slanted_uv * rain_amount));

	float drop_speed = base_rain_speed + additional_rain_speed * random_noise;
	float animated_uv_y = fract(UV.y + random_noise - time * drop_speed);

	float drop_width = mix(far_rain_width, near_rain_width, random_noise);
	float drop_length = mix(far_rain_length, near_rain_length, random_noise);
	float drop_transparency = mix(far_rain_transparency, near_rain_transparency, random_noise);

	float width_mask = step(col_edge * rain_amount, drop_width);
	float streak_mask = smoothstep(1.0 - drop_length, 1.0, animated_uv_y);
	float rain_visibility_mask = streak_mask * drop_transparency * width_mask;

	COLOR = mix(COLOR, rain_color, rain_visibility_mask);
}
