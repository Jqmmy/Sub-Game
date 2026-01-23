#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;

void main() {
    ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
    vec3 diffuse = imageLoad(screen_tex, pixel).rgb;

    vec3 c00 = imageLoad(screen_tex, pixel).rgb;
    vec3 c10 = imageLoad(screen_tex, pixel + ivec2(1, 0)).rgb;
    vec3 c01 = imageLoad(screen_tex, pixel + ivec2(0, 1)).rgb;
    vec3 c11 = imageLoad(screen_tex, pixel + ivec2(1, 1)).rgb;

    float i00 = dot(c00, vec3(0.299, 0.587, 0.114));
    float i10 = dot(c10, vec3(0.299, 0.587, 0.114));
    float i01 = dot(c01, vec3(0.299, 0.587, 0.114));
    float i11 = dot(c11, vec3(0.299, 0.587, 0.114));

    float gx = i00 - i11;
    float gy = i10 - i01;

    float edgeStrength = length(vec2(gx,gy));

    vec4 color = vec4(diffuse - vec3(edgeStrength), 1.0);
    imageStore(screen_tex, pixel, color);
}
