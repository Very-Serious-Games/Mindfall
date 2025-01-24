shader_type canvas_item;

uniform float fill_amount : hint_range(0.0, 1.0) = 1.0;
uniform bool split_enabled = false;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    
    // Create half circle mask
    float circle = step(radius, 0.5);
    float half_circle = circle * float(angle > -PI/2.0 && angle < PI/2.0);
    
    // Split into sections if enabled
    if (split_enabled) {
        float section = float(angle > 0.0 ? fill_amount > 0.5 : fill_amount > 0.0);
        COLOR.a = half_circle * section;
    } else {
        COLOR.a = half_circle * float(fill_amount > 0.0);
    }
}