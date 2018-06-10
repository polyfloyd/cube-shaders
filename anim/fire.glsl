#pragma use "../libcube.glsl"
#pragma map rand=builtin:RGBA Noise Small
#pragma map gyros=perip_mat4:/dev/ttyUSB0;230400?

vec3 gradient(float n) {
	float c = 1 - clamp(n, 0, 1);
	return clamp(vec3(c-.1, c * 1.1 - 0.5, c - 0.8), 0, 1);
}

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	fragColor.rgb = vec3(0);
	fragCoord *= mat3(gyros);
	vec2 uv = vec2(0, 1) - map_to_sphere_uv(fragCoord);
	float t = iTime * 0.1;

	const int N = 3;
	for (int i = 0; i < N; i++) {
		vec4 r = texture(rand, vec2(
			uv.x + sin(uv.y*2 + t*8 + float(i)*.3)*.15,
			uv.y * float(i+2)*.2 - t * float(i+1)
		));
		fragColor.rgb += gradient(uv.y + r.x * 0.6 - .4) / float(N);
	}
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
