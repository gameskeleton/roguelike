shader_type canvas_item;

uniform vec2 fog_direction = vec2(1.0, 0.2);
uniform float fog_speed : hint_range(0.0, 0.1) = 0.05;
uniform float fog_density : hint_range(0.0, 1.0) = 0.85;

uniform float noise_scale_1 : hint_range(0.1, 10.0) = 2.0;
uniform float noise_scale_2 : hint_range(0.1, 10.0) = 4.0;
uniform float noise_scale_3 : hint_range(0.1, 10.0) = 8.0;

vec2 hash22(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    
    float a = dot(hash22(i), f);
    float b = dot(hash22(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(hash22(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(hash22(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
    
    float noise_val = mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
    return noise_val * 0.5 + 0.5;
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for(int i = 0; i < 5; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.07;
        amplitude *= 0.5;
    }
    
    return value;
}

void fragment() {
    vec2 uv = UV;
    vec2 offset = normalize(fog_direction) * TIME * fog_speed;
    
    float fog_noise_1 = fbm((uv + offset) * noise_scale_1);
    float fog_noise_2 = fbm((uv + offset * 1.3 + vec2(0.5, 0.2)) * noise_scale_2);
    float fog_noise_3 = fbm((uv + offset * 0.7 - vec2(0.3, 0.5)) * noise_scale_3);
    
    float cloud_base = fog_noise_1 * 0.5 + fog_noise_2 * 0.3 + fog_noise_3 * 0.2;
    
    float cloud_threshold = 0.45;
    float cloud_softness = 0.15;
    float clouds = smoothstep(cloud_threshold - cloud_softness, cloud_threshold + cloud_softness, cloud_base);
    
    float edge_detail = fbm((uv + offset * 0.8) * 6.0) * 0.3;
    clouds *= smoothstep(0.3, 0.7, cloud_base + edge_detail);
    
    vec2 warp = vec2(
        fbm(uv * 2.5 + offset * 0.4),
        fbm(uv * 2.5 - offset * 0.4 + vec2(5.2, 1.3))
    ) * 0.08;
    float warped_clouds = fbm((uv + warp + offset * 0.6) * 2.0);
    
    clouds = mix(clouds, warped_clouds, 0.3);
    
    float vertical_gradient = smoothstep(0.0, 1.0, 1.0 - UV.y);
    clouds *= vertical_gradient * 0.6 + 0.4;
    
    clouds = pow(clouds, 1.5);
    
    float alpha = clouds * fog_density;
    alpha *= 0.93 + 0.07 * sin(TIME * 0.5 + uv.x * 2.0);
    
    COLOR.a *= alpha;
}