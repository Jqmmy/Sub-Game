#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba16f, binding = 0, set = 0) uniform readonly image2D screen_tex;
layout(rgba16f, binding = 0, set = 1) uniform writeonly image2D out_tex;


layout(push_constant, std430) uniform Params {
    vec3 edge_color;
	float edge_min;
	float edge_max;
} p;

mat3 sx = mat3(
	1.0, 2.0, 1.0,
	0.0, 0.0, 0.0,
	-1.0, -2.0, -1.0
);
mat3 sy = mat3(
	1.0, 0.0, -1.0,
	2.0, 0.0, -2.0,
	1.0, 0.0, -1.0
);

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	vec3 diffuse = imageLoad(screen_tex, pixel).rgb;
	mat3 I;
	
	for (int i=0; i<3; i++) {
		for (int j=0; j<3; j++) {
			vec3 col = imageLoad(screen_tex, pixel + ivec2(i-1, j-1)).rgb;
			I[i][j] = length(col);
		};
	};

	float gx = dot(sx[0], I[0]) + dot(sx[1], I[1]) + dot(sx[2], I[2]);
	float gy = dot(sy[0], I[0]) + dot(sy[1], I[1]) + dot(sy[2], I[2]);

	float out_color = sqrt(pow(gx, 2.0) + pow(gy, 2.0));
	out_color = smoothstep(p.edge_min, p.edge_max, out_color);
	vec3 edgeColor = vec3(p.edge_color.r, p.edge_color.g, p.edge_color.b);
	imageStore(out_tex, pixel, vec4(mix(diffuse, edgeColor, out_color), 1.0));
}
