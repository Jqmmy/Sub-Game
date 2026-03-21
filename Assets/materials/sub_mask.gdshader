shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D SCREE_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = textureLod(SCREE_TEXTURE, SCREEN_UV, 0.0).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
