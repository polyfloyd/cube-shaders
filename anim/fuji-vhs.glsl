#pragma use "../libcube.glsl"
#pragma map random=builtin:RGBA Noise Medium

vec3 cubeNormal(vec3 p) {
	if (abs(p.x) >= .5 - EPSILON) {
		return normalize(vec3(p.x * 2, 0, 0));
	}
	if (abs(p.y) >= .5 - EPSILON) {
		return normalize(vec3(0, p.y * 2, 0));
	}
	if (abs(p.z) >= .5 - EPSILON) {
		return normalize(vec3(0, 0, p.z * 2));
	}
	return vec3(0);
}

float sdfCube(vec3 p, vec3 size) {
	return length(max(abs(p) - size, 0.0));
}

vec3 normalizeCube(vec3 p) {
	return p / max(abs(p.x), max(abs(p.y), abs(p.z))) * .5;
}

vec4 box(vec3 p, float t, float i) {
	float tt = t * 1.5 + i;
	float tPos = floor(tt);
	float tAnim = mod(tt, 1);
	vec4 rand1 = texture2D(random, vec2(i, tPos / randomSize.x), 0);
	vec4 rand2 = texture2D(random, vec2(i, mod(tPos / randomSize.x + .5, 1)), 0);

	vec3 colorB1 = vec3(0, .5, 1);
	vec3 colorA1 = mix(vec3(1, 0, .5), vec3(0, 1, .5), step(rand1.w, .2));
	vec3 colorA2 = vec3(1, 1, 0);
	vec3 colorB2 = vec3(1, 0, 0);
	vec3 colorA = mix(colorA1, colorA2, step(rand2.w, .1));
	vec3 colorB = mix(colorB1, colorB2, step(rand2.w, .1));

	vec3 boxPos = normalizeCube(rand1.xyz - .5);

	float pulse = (1 - 1 / (tAnim * 20 + 1)) * 1.1;
	vec3 size = (vec3(0.18) - vec3(0.1) * rand2.x) * pulse;
	float bounds = step(sdfCube(p - boxPos, size), 0);

	vec3 shiftVec = cubeNormal(boxPos).zxy;
	float colorGradient = length((p - boxPos) * shiftVec - shiftVec * tAnim) * 4 - size.x - 1;
	float fade = smoothstep(.5, 1, tAnim);
	return vec4(mix(colorA, colorB, colorGradient), clamp(bounds - fade, 0, 1));
}

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	fragColor = vec4(0, 0, 0, 1);
	const int N = 80;
	for (int i = 0; i < N; i++) {
		vec4 col = box(fragCoord, iTime, float(i) / N);
		fragColor.rgb = mix(fragColor.rgb, col.rgb, col.a);
	}
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
