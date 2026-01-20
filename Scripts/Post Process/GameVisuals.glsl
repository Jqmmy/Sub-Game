#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba16f, binding = 0, set = 0) uniform readonly image2D screen_tex;
layout(rgba16f, binding = 0, set = 1) uniform writeonly image2D out_tex;


layout(push_constant, std430) uniform Params {
    vec2 screen_size;
	float edge_min;
	float edge_max;
} p;

void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	
	ivec2 size = ivec2(p.screen_size);
	
	if (pixel.x <= 0 || pixel.y <= 0 ||
		pixel.x >= size.x - 1 || pixel.y >= size.y - 1) {
		vec4 c = imageLoad(screen_tex, pixel);
		imageStore(out_tex, pixel, c);
		return;
	}
	
	float kernalX[9] = float[](
		-1, 0, 1,
		-2, 0, 2,
		-1, 0, 1
	);
	float kernalY[9] = float[](
		-1, -2, -1,
		0, 0, 0,
		1, 2, 1
	);
	
	ivec2 offsets[9] = ivec2[](
		ivec2(-1,  1), ivec2(0,  1), ivec2(1,  1),
		ivec2(-1,  0), ivec2(0,  0), ivec2(1,  0),
		ivec2(-1, -1), ivec2(0, -1), ivec2(1, -1)
    );

	float gx = 0.0;
	float gy = 0.0;
	
	
	for (int i = 0; i < 9; i++) {
		ivec2 samplePixel = pixel + offsets[i];
		
		vec3 col = imageLoad(screen_tex, samplePixel).rgb;
		col = pow(col, vec3(2.2));
		
		float lum = dot(col, vec3(0.299, 0.587, 0.114));
		
		gx += lum * kernalX[i];
		gy += lum * kernalY[i];
	}
	
	float edgeStrength = length(vec2(gx, gy));
	edgeStrength = edgeStrength / 32.0;
	edgeStrength = clamp(edgeStrength, 0.0, 1.0);

	edgeStrength = max(edgeStrength - p.edge_min, 0.0);

	float edge = smoothstep(0.0, p.edge_max - p.edge_min, edgeStrength);

	vec4 outColor = vec4(vec3(edge), 1.0) ;
	
	
	imageStore(out_tex, pixel, outColor);
}
