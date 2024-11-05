shader_type canvas_item;
uniform float speed = 1.0; // Rotation speed
uniform float texture_scale = 1.0; // Adjusts the texture scaling
uniform float brightness = 1.0; // Adjusts the brightness
uniform float uv_offset_x = 0.0; // Fine-tune texture horizontal position
uniform float wrap_adjust = 1.5; // Adjust texture wrapping tightness
uniform float pole_stretch = 0.8; // Control pole stretching

void fragment() {
    // Center the UV coordinates (-1 to 1)
    vec2 uv = UV * 2.0 - 1.0;
    // Correct the aspect ratio
    uv.x *= TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
    
    // Calculate the length from the center
    float len = length(uv);
    
    // Discard pixels outside the circle
    if (len > 1.0) {
        discard;
    } else {
        // Calculate the z-coordinate of the sphere
        float z = sqrt(1.0 - uv.x * uv.x - uv.y * uv.y);
        
        // Rotate around the y-axis
        float angle = TIME * speed;
        mat3 rotation = mat3(
            vec3(cos(angle), 0.0, sin(angle)),
            vec3(0.0, 1.0, 0.0),
            vec3(-sin(angle), 0.0, cos(angle))
        );
        
        // Apply rotation
        vec3 sphere_pos = rotation * vec3(uv.x, uv.y * pole_stretch, z);
        
        // Compute spherical coordinates with adjustments
        float u = 0.5 + (atan(sphere_pos.x, sphere_pos.z) / (2.0 * PI * wrap_adjust)) + uv_offset_x;
        float v = 0.5 - (asin(sphere_pos.y) / PI);
        
        // Scale and wrap texture
        u = fract(u * texture_scale);
        v = clamp(v, 0.0, 1.0);
        
        // Sample texture
        vec4 color = texture(TEXTURE, vec2(u, v));
        
        // Add simple shading based on sphere normal
        float shading = 0.5 + 0.5 * z;
        
        // Combine color, shading, and brightness
        COLOR = vec4(color.rgb * brightness * shading, color.a);
    }
}