shader_type canvas_item;

uniform float corner_radius : hint_range(0.0, 0.5) = 0.1;
uniform float border_width : hint_range(0.0, 0.1) = 0.0;
uniform vec4 border_color : source_color = vec4(1.0);
uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(2.0, 2.0, 0.5, 1.0);

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5);
    
    // Calculate distance from each corner
    vec2 top_left = uv;
    vec2 top_right = vec2(1.0 - uv.x, uv.y);
    vec2 bottom_left = vec2(uv.x, 1.0 - uv.y);
    vec2 bottom_right = vec2(1.0 - uv.x, 1.0 - uv.y);
    
    float dist = min(min(length(top_left), length(top_right)),
                    min(length(bottom_left), length(bottom_right)));
    
    // Get original color
    vec4 original = texture(TEXTURE, UV);
    
    // Calculate edge softness
    float radius = corner_radius;
    float alpha = 1.0;
    
    if (uv.x < radius && uv.y < radius) {
        float corner_dist = length(uv - vec2(radius));
        alpha = smoothstep(radius, radius - 0.01, corner_dist);
    }
    else if (uv.x > 1.0 - radius && uv.y < radius) {
        float corner_dist = length(vec2(1.0 - radius, radius) - uv);
        alpha = smoothstep(radius, radius - 0.01, corner_dist);
    }
    else if (uv.x < radius && uv.y > 1.0 - radius) {
        float corner_dist = length(vec2(radius, 1.0 - radius) - uv);
        alpha = smoothstep(radius, radius - 0.01, corner_dist);
    }
    else if (uv.x > 1.0 - radius && uv.y > 1.0 - radius) {
        float corner_dist = length(vec2(1.0) - vec2(radius) - uv);
        alpha = smoothstep(radius, radius - 0.01, corner_dist);
    }
    
    // Apply flash effect
    vec4 final_color = mix(original, flash_color, flash_intensity);
    
    // Apply the effect
    COLOR = final_color;
    COLOR.a *= alpha;
}