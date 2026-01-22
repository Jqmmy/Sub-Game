#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba16f, binding = 0, set = 0) uniform readonly image2D screen_tex;
layout(rgba16f, binding = 0, set = 1) uniform writeonly image2D out_tex;


void main() {
    ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);

    vec3 c00 = imageLoad(screen_tex, pixel).rgb;
    vec3 c10 = imageLoad(screen_tex, pixel + ivec2(1, 0)).rgb;
    vec3 c01 = imageLoad(screen_tex, pixel + ivec2(0, 1)).rgb;
    vec3 c11 = imageLoad(screen_tex, pixel + ivec2(1, 1)).rgb;

    float gx = c00 - c11;
    float gy = c10 - c01;

    float edgeStrength = length(vec2(gx,gy));

    vec4 outColor = vec4(vec3(edgeStrength), 1.0)
    imageStore(out_tex, pixel, outColor)
}
