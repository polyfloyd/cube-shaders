#pragma use "../libcube.glsl"
#pragma map noise=builtin:RGBA Noise Small

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	float t = iTime * 1.2;
	fragColor.rgb = vec3(0);

	for (int i = 0; i < 64; i++) {
		float rx = t * length(texture2D(noise, vec2(i / 64., 0.0)));
		float ry = t * length(texture2D(noise, vec2(i / 64., 0.1)));
		float rz = t * length(texture2D(noise, vec2(i / 64., 0.2)));
		mat3 mx = mat3(
			1.0, 0.0,      0.0,
			0.0, cos(rx),  sin(rx),
			0.0, -sin(rx), cos(rx)
		);
		mat3 my = mat3(
			cos(ry),  0.0, sin(ry),
			0.0,      1.0, 0.0,
			-sin(ry), 0.0, cos(ry)
		);
		mat3 mz = mat3(
			cos(rz),  sin(rz), 0.0,
			-sin(rz), cos(rz), 0.0,
			0.0,      0.0,     1.0
		);

		mat3 rotation = mx * my * mz;
		vec3 p = normalize(fragCoord * rotation);

		vec3 color;
		float j = mod(i, 3);
		if (j == 0) {
			color = vec3(1, 0, 0);
		} else if (j == 1) {
			color = vec3(0, 1, 0);
		} else {
			color = vec3(0, 0, 1);
		}

		vec3 anchor = vec3(1, 0, 0);
		fragColor.rgb += color * clamp(1 - length(anchor - p) * 3, 0, 1);
		fragColor.rgb += vec3(1) * clamp(1 - length(anchor - p) * 16, 0, 1);
	}
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
