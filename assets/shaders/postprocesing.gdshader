shader_type canvas_item;

// Grain uniforms
uniform float grain_amount : hint_range(0.0, 1.0) = 0.05;
uniform float grain_size : hint_range(0.1, 10.0) = 1.0;

// Fisheye uniforms
uniform float effect_amount : hint_range(-2.5, 2.5) = 1.0;

// Pixel sorting uniforms
uniform float mask_softness = 1.4;
uniform float mask_threshold = 0.6;
uniform float sort :hint_range(0.0, 2.0)= 0.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Fisheye distortion first
    vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec4 fragCoord = FRAGCOORD;
    vec2 p = fragCoord.xy / iResolution.x;
    float prop = iResolution.x / iResolution.y;
    vec2 m = vec2(0.5, 0.5 / prop);
    vec2 d = p - m;
    float r = sqrt(dot(d, d));
    float power = effect_amount;
    float bind;

    if (power > 0.0)
        bind = sqrt(dot(m, m));
    else {
        if (prop < 1.0)
            bind = m.x;
        else
            bind = m.y;
    }

    vec2 uv;
    if (power > 0.0)
        uv = m + normalize(d) * tan(r * power) * bind / tan(bind * power);
    else if (power < 0.0)
        uv = m + normalize(d) * atan(r * -power * 10.0) * bind / atan(-power * bind * 10.0);
    else
        uv = p;
    uv.y *= prop;

    // Sample texture with fisheye distortion
    vec4 distorted_color = texture(SCREEN_TEXTURE, uv);

    // Pixel sorting
    vec2 sort_uv = uv;
    float f = mask_softness / 2.0;
    float a = mask_threshold - f;
    float b = mask_threshold + f;
    float average = (distorted_color.x + distorted_color.y + distorted_color.z) / 3.0;
    float mask = smoothstep(a, b, average);

    float sort_threshold = 1.0 - clamp(sort / 2.6, 0.0, 1.0);
    vec2 transition_uv = sort_uv;
    float turbulance = fract(sin(dot(vec2(transition_uv.x), vec2(12.9, 78.2)))* 437.5);
    transition_uv.y += pow(sort, 2.0 + (sort * 2.0)) * mask * turbulance;

    if(transition_uv.y > 1.){
        distorted_color = texture(SCREEN_TEXTURE, vec2(sort_uv.x, sort_threshold));
    }

    // Apply grain effect
    float noise = (fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;
    distorted_color.rgb += noise * grain_amount * grain_size;

    // Output final color
    COLOR = clamp(distorted_color, 0.0, 1.0);
}