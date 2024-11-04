shader_type canvas_item;
uniform vec2 light_position = vec2(0.5, 0.5);
uniform float light_radius = 0.045;
uniform float edge_falloff = 0.01;

void fragment() {
    // Get the aspect ratio to correct the circle shape
    vec2 aspect_ratio = vec2(1.0, TEXTURE_PIXEL_SIZE.x/TEXTURE_PIXEL_SIZE.y);
    
    // Apply aspect ratio correction to UV coordinates
    vec2 uv_aspect = (UV - light_position) * aspect_ratio;
    
    // Calculate distance with aspect ratio correction
    float dist = length(uv_aspect);
    
    float alpha = 1.0 - smoothstep(light_radius, light_radius - edge_falloff, dist);
    vec4 darkness_color = vec4(0.0, 0.0, 0.0, alpha);
    COLOR = darkness_color;
}