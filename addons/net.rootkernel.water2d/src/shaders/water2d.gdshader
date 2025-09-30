shader_type canvas_item;

uniform sampler2D wave_heights : hint_default_black, filter_linear;

uniform vec4 water_color : source_color = vec4(0.5, 0.5, 0.82, 0.59);
uniform float smoothness : hint_range(1.0, 10.0) = 3.0;
uniform float depth_fade : hint_range(0.0, 1.0) = 0.3;
uniform float water_height : hint_range(0.0, 1.0) = 0.5;
uniform float wave_amplitude : hint_range(0.0, 100.0) = 50.0;
uniform float surface_brightness : hint_range(0.0, 2.0) = 1.2;

varying vec2 world_position;

void vertex() {
    world_position = VERTEX;
}

// Simple noise function for surface effects
float noise(vec2 pos) {
    return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    // Sample the wave height from the 1D texture with some smoothing
    float wave_sample = texture(wave_heights, vec2(uv.x, 0.0)).r;
    // Add some horizontal smoothing by sampling neighboring pixels
    float sample_left = texture(wave_heights, vec2(max(0.0, uv.x - 1.0 / TEXTURE_PIXEL_SIZE.x), 0.0)).r;
    float sample_right = texture(wave_heights, vec2(min(1.0, uv.x + 1.0 / TEXTURE_PIXEL_SIZE.x), 0.0)).r;
    wave_sample = (sample_left + wave_sample * 2.0 + sample_right) * 0.25;
    // Convert to world space height (0.0 = bottom, 1.0 = top)
    float wave_uv_height = wave_sample;
    // Create smooth transition based on distance from wave surface
    float distance_from_surface = uv.y - wave_uv_height;
    // Only render pixels below the wave surface
    if (distance_from_surface > 0.0) {
        discard;
    }
    // Calculate depth and surface effects
    float depth = clamp(-distance_from_surface * smoothness, 0.0, 1.0);
    // Surface highlighting effect
    float surface_distance = abs(distance_from_surface);
    float surface_effect = 1.0 - smoothstep(0.0, 0.1, surface_distance);
    // Apply color effects
    vec4 final_color = water_color;
    // Depth darkening
    final_color.rgb = mix(final_color.rgb, final_color.rgb * (1.0 - depth_fade), depth);
    // Surface brightness
    final_color.rgb += surface_effect * (surface_brightness - 1.0) * final_color.rgb;
    // Subtle surface noise for texture
    float surface_noise = noise(uv * 50.0) * 0.1 * surface_effect;
    final_color.rgb += surface_noise;
    // Ensure alpha is preserved
    final_color.a = water_color.a;
	// Output
    COLOR = final_color;
}