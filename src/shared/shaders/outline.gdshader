shader_type canvas_item;

uniform bool fill = true;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float thickness : hint_range(0, 2) = 1.0;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * thickness;
	vec4 sample = texture(TEXTURE, UV);
	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;

	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = clamp(outline, 0.0, 1.0);
	
	COLOR = mix(fill ? sample : vec4(0), color, outline - sample.a);
}