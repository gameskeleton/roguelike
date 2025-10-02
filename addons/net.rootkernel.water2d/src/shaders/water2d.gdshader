shader_type canvas_item;

uniform sampler2D wave_heights : hint_default_black, filter_linear;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform vec4 water_color : source_color = vec4(0.5, 0.5, 0.82, 0.59);
uniform float depth_fade : hint_range(0.0, 1.0) = 0.4;
uniform float smoothness : hint_range(1.0, 10.0) = 5.0;
uniform float foam_height : hint_range(0.0, 1.0) = 0.03;
uniform float surface_brightness : hint_range(0.0, 2.0) = 1.2;
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.03;

float noise(vec2 uv_coordinate) {
    return fract(sin(dot(uv_coordinate, vec2(12.9898, 78.233))) * 43758.5453);
}

float wave_height(vec2 uv_coordinate, vec2 pixel_offset) {
    float wave_sample_left = texture(wave_heights, vec2(max(0.0, uv_coordinate.x - pixel_offset.x), 0.0)).r;
    float wave_sample_right = texture(wave_heights, vec2(min(1.0, uv_coordinate.x + pixel_offset.x), 0.0)).r;
    float wave_sample_center = texture(wave_heights, vec2(uv_coordinate.x, 0.0)).r;
    return (wave_sample_left + wave_sample_center * 2.0 + wave_sample_right) * 0.25;
}

float edge_dampening(vec2 uv_coordinate) {
    return smoothstep(0.0, 0.1, min(min(uv_coordinate.x, 1.0 - uv_coordinate.x), min(uv_coordinate.y, 1.0 - uv_coordinate.y)));
}

float foam_intensity(vec2 uv_coordinate, vec2 pixel_offset, float surface_proximity, float wave_height) {
    float wave_sample_left = texture(wave_heights, vec2(max(0.0, uv_coordinate.x - pixel_offset.x), 0.0)).r;
    float wave_sample_right = texture(wave_heights, vec2(min(1.0, uv_coordinate.x + pixel_offset.x), 0.0)).r;
    float wave_activity = abs(wave_sample_right - wave_sample_left) * 10.0 + abs(wave_height - 0.5) * 4.0;
    return smoothstep(0.2, 1.0, max(surface_proximity, smoothstep(0.3, 1.5, wave_activity) * surface_proximity));
}

vec2 distortion_offset(vec2 uv_coordinate, vec2 pixel_offset, float wave_height, float edge_dampening_factor) {
    float wave_sample_left = texture(wave_heights, vec2(max(0.0, uv_coordinate.x - pixel_offset.x), 0.0)).r;
    float wave_sample_right = texture(wave_heights, vec2(min(1.0, uv_coordinate.x + pixel_offset.x), 0.0)).r;
    vec2 distortion_offset = vec2((wave_sample_right - wave_sample_left), (wave_height - 0.5) * 0.6) * distortion_strength * edge_dampening_factor;
    distortion_offset += vec2(sin(uv_coordinate.y * 10.0 + TIME), cos(uv_coordinate.x * 8.0 + TIME * 0.8)) * distortion_strength * 0.1 * edge_dampening_factor;
    return distortion_offset;
}

vec3 add_surface_effects(vec2 uv_coordinate, vec3 base_color, float surface_proximity, float foam_intensity_factor) {
    vec3 enhanced_color = base_color;
    enhanced_color += surface_proximity * (surface_brightness - 1.0) * 0.15;

    float sparkle_noise = noise(uv_coordinate * 30.0 + TIME * 0.5);
    enhanced_color += sparkle_noise * 0.05 * (1.0 - foam_intensity_factor);

    float shimmer = sin(uv_coordinate.x * 20.0 + TIME * 1.2) * cos(uv_coordinate.x * 14.0 + TIME * 0.9) * 0.03;
    enhanced_color += shimmer * surface_proximity * (1.0 - foam_intensity_factor) * vec3(0.8, 0.9, 1.0);

    return enhanced_color;
}

void fragment() {
    vec2 size = vec2(textureSize(wave_heights, 0));
    vec2 pixel_offset = 1.0 / size;
    float wave_height = wave_height(UV, pixel_offset);

    if (UV.y > wave_height) discard;

    vec3 water_tint = water_color.rgb * water_color.a;
    vec2 distortion = distortion_offset(UV, pixel_offset, wave_height, edge_dampening(UV));
    vec4 background_color = texture(SCREEN_TEXTURE, clamp(SCREEN_UV + distortion, vec2(0.0), vec2(1.0)));

    float surface = wave_height - UV.y;
    float depth_factor = clamp(surface * smoothness, 0.0, 1.0);
    float foam_proximity = 1.0 - smoothstep(0.0, foam_height, surface);
    float foam_intensity_factor = foam_intensity(UV, pixel_offset, foam_proximity, wave_height);

    background_color.rgb = mix(background_color.rgb, water_tint, depth_factor * depth_fade + water_color.a * 0.3);
    background_color.rgb = mix(background_color.rgb, foam_color.rgb, foam_intensity_factor * 0.6);
    background_color.rgb = add_surface_effects(UV, background_color.rgb, foam_proximity, foam_intensity_factor);

    COLOR = vec4(background_color.rgb, 1.0);
}