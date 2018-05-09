#pragma use "../libcube.glsl"
#pragma map noise=builtin:RGBA Noise Small
// Pulled from Minecraft.jar, not incuded because I don't own the copyright.
#pragma map blocks=image:../img/terrain.png

vec2 pos[18];

float transition(vec2 uv, float n) {
	float r = 4;
	float perimiter = mod(n, 1) - length(uv - .5) * sqrt(2) * 1/(1+1/r);
	float jitter = texture2D(noise, uv * .5 + n).x / r - 1/r;
	return perimiter + jitter;
}

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	pos[0] = vec2(0, 3);
	pos[1] = vec2(1, 1);
	pos[2] = vec2(7, 0);
	pos[3] = vec2(0, 10);
	pos[4] = vec2(4, 0);
	pos[5] = vec2(4, 2);
	pos[6] = vec2(3, 2);
	pos[7] = vec2(1, 2);
	pos[8] = vec2(5, 2);
	pos[9] = vec2(1, 3);
	pos[10] = vec2(3, 3);
	pos[11] = vec2(2, 3);
	pos[12] = vec2(8, 0);
	pos[13] = vec2(0, 2);
	pos[14] = vec2(9, 6);
	pos[15] = vec2(2, 2);
	pos[16] = vec2(0, 1);
	pos[17] = vec2(2, 0);

	vec2 uv = cube_map_to_side(fragCoord) + .5;
	uv = vec2(uv.x, 1 - uv.y);
	float n = iTime * 1.5;

	int bi = int(mod(n, pos.length()));
	int ai = int(mod(n + 1, pos.length()));
	vec4 a = texture2D(blocks, (uv + pos[ai]) / 16);
	vec4 b = texture2D(blocks, (uv + pos[bi]) / 16);

	float trans = transition(uv, n);
	fragColor = mix(a, b, step(trans, 0));
	fragColor.rgb += max((1 - abs(trans) * 32) * vec3(1), 0);
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
