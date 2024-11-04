shader_type canvas_item;
uniform vec2 light_position = vec2(0.5, 0.5);
uniform float light_radius = 0.05;

void fragment() {
    // Get screen dimensions for aspect ratio
    vec2 resolution = 0.8 / SCREEN_PIXEL_SIZE;
    float aspect = resolution.x / (resolution.y/0.9);
    
    // Create aspect-corrected UV coordinates
    vec2 uv = UV - light_position;
    uv.x *= aspect;
    
    // Calculate circular distance
    float dist = length(uv);
    
    // Create sharp circle
    float alpha = dist > light_radius ? 0.99 : 0.0;
    
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}