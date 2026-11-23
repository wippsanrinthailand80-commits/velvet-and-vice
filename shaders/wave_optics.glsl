#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(set = 0, binding = 0, std140) uniform Params {
    ivec2 resolution;
    float wavelength_nm;
    float slit_separation;
    float screen_distance;
    uint num_slits;
    float time;
} params;

layout(set = 0, binding = 1, rgba8) uniform writeonly image2D output_image;

float single_slit_diffraction(float x, float slit_width, float wavelength, float distance) {
    float k = 2.0 * 3.14159265359 / (wavelength * 1e-9);
    float beta = k * slit_width * sin(x / distance) * 0.5;
    if (abs(beta) < 1e-6) return 1.0;
    float sinc = sin(beta) / beta;
    return sinc * sinc;
}

float multi_slit_interference(float x, uint n, float slit_sep, float wavelength, float distance) {
    float k = 2.0 * 3.14159265359 / (wavelength * 1e-9);
    float delta = k * slit_sep * sin(x / distance);
    if (abs(delta) < 1e-6) return float(n * n);
    float numerator = sin(n * delta * 0.5);
    float denominator = sin(delta * 0.5);
    return (numerator / denominator) * (numerator / denominator);
}

vec3 wavelength_to_color(float wavelength) {
    vec3 color = vec3(0.0);
    if (wavelength >= 380.0 && wavelength < 440.0) {
        color = vec3(-(wavelength - 440.0) / 60.0, 0.0, 1.0);
    } else if (wavelength >= 440.0 && wavelength < 490.0) {
        color = vec3(0.0, (wavelength - 440.0) / 50.0, 1.0);
    } else if (wavelength >= 490.0 && wavelength < 510.0) {
        color = vec3(0.0, 1.0, -(wavelength - 510.0) / 20.0);
    } else if (wavelength >= 510.0 && wavelength < 580.0) {
        color = vec3((wavelength - 510.0) / 70.0, 1.0, 0.0);
    } else if (wavelength >= 580.0 && wavelength < 645.0) {
        color = vec3(1.0, -(wavelength - 645.0) / 65.0, 0.0);
    } else if (wavelength >= 645.0 && wavelength <= 780.0) {
        color = vec3(1.0, 0.0, 0.0);
    }
    return color;
}

void main() {
    ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
    if (pixel.x >= params.resolution.x || pixel.y >= params.resolution.y) return;
    
    vec2 screen_pos = (vec2(pixel) - vec2(params.resolution) * 0.5) * 1e-6;
    float wavelength = params.wavelength_nm;
    
    vec3 field = vec3(0.0);
    for (int i = 0; i < int(params.num_slits); i++) {
        float slit_x = (float(i) - float(params.num_slits - 1) * 0.5) * params.slit_separation;
        float dx = screen_pos.x - slit_x;
        float k = 2.0 * 3.14159265359 / (wavelength * 1e-9);
        float phase = k * dx * dx / (2.0 * params.screen_distance);
        field += vec3(cos(phase), sin(phase), 0.0);
    }
    
    float intensity = dot(field.xy, field.xy);
    float single = single_slit_diffraction(screen_pos.x, 50e-6, wavelength, params.screen_distance);
    float multi = multi_slit_interference(screen_pos.x, params.num_slits, params.slit_separation, wavelength, params.screen_distance);
    
    intensity *= single * multi;
    
    vec3 color = wavelength_to_color(wavelength) * intensity;
    color = pow(clamp(color, 0.0, 1.0), vec3(1.0 / 2.2));
    
    imageStore(output_image, pixel, vec4(color, 1.0));
}