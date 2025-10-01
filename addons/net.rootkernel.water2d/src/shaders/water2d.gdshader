shader_type canvas_item;

uniform sampler2D wave_heights : hint_default_black, filter_linear;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 water_color : source_color = vec4(0.5, 0.5, 0.82, 0.59);
uniform float depth_fade : hint_range(0.0, 1.0) = 0.4;
uniform float smoothness : hint_range(1.0, 10.0) = 5.0;
uniform float surface_brightness : hint_range(0.0, 2.0) = 1.2;
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.03;

void fragment() {
    // Sample wave with smoothing
    float sample_l = texture(wave_heights, vec2(max(0.0, UV.x - 1.0 / TEXTURE_PIXEL_SIZE.x), 0.0)).r;
    float sample_c = texture(wave_heights, vec2(UV.x, 0.0)).r;
    float sample_r = texture(wave_heights, vec2(min(1.0, UV.x + 1.0 / TEXTURE_PIXEL_SIZE.x), 0.0)).r;
    float wave = (sample_l + sample_c * 2.0 + sample_r) * 0.25;

    // Surface check
    if (UV.y > wave) discard;

    // Distortion with edge dampening
    float edge = smoothstep(0.0, 0.1, min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
    vec2 distort = vec2((sample_r - sample_l), (wave - 0.5) * 0.6) * distortion_strength * edge;
    distort += vec2(sin(UV.y * 10.0 + TIME), cos(UV.x * 8.0 + TIME * 0.8)) * distortion_strength * 0.1 * edge;

    // Sample background
    vec4 bg = texture(SCREEN_TEXTURE, clamp(SCREEN_UV + distort, vec2(0.0), vec2(1.0)));

    // Effects
    float surf_dist = wave - UV.y;
    float depth = clamp(surf_dist * smoothness, 0.0, 1.0);
    float surf = 1.0 - smoothstep(0.0, 0.08, surf_dist);
    float foam = smoothstep(0.2, 1.0, max(surf, smoothstep(0.3, 1.5, abs(sample_r - sample_l) * 10.0 + abs(wave - 0.5) * 4.0) * surf));

    // Final color
    vec3 tint = water_color.rgb * water_color.a;
    bg.rgb = mix(bg.rgb, tint, depth * depth_fade + water_color.a * 0.3);
    bg.rgb = mix(bg.rgb, vec3(0.9, 0.95, 1.0), foam * 0.6);
    bg.rgb += surf * (surface_brightness - 1.0) * 0.15;
    bg.rgb += fract(sin(dot(UV * 30.0 + TIME * 0.5, vec2(12.9898, 78.233))) * 43758.5453) * 0.05 * (1.0 - foam);
    bg.rgb += sin(UV.x * 20.0 + TIME * 1.2) * cos(UV.x * 14.0 + TIME * 0.9) * 0.03 * surf * (1.0 - foam) * vec3(0.8, 0.9, 1.0);

    COLOR = vec4(bg.rgb, 1.0);
}