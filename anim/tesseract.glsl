#pragma use "../libcube.glsl"
#pragma use "../libnoise.glsl"

const vec3 hue = vec3(0, .5, 1);

float rand(float v) {
	return fract(sin(v) * 43758.5453123);
}

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	vec4 side = cube_map_to_side(fragCoord);
	vec2 uv = side.xy;

	float bearing = length(uv)*.6 + iTime*-.2 + rand(side.w);
	mat2 rotation = mat2(
		cos(bearing), sin(bearing),
		-sin(bearing), cos(bearing)
	);
	vec2 polarUV = uv * rotation;
	vec2 polar = vec2(length(polarUV), atan(polarUV.x, polarUV.y) / PI * 4);
	vec2 noiseUV = vec2(polar*4 + vec2(iTime, 0)*2);
	float waves = pow(mod(perlin_noise(noiseUV) - iTime*.8, 1), 2);

	float bounds = 1 - pow(length(vec2(max(abs(uv.x), abs(uv.y)))), 4) * 4;

	vec3 col = vec3(0);
	// blue
	col = hue * clamp(waves, 0, 1);
	// white edges
	col += clamp(pow(waves, 3) * bounds, 0, 1);

	// dot in the center
	float core = clamp(1 - length(uv) * 4 + (sin(iTime * 2)*.5+.5) * .3, 0, 1);
	col += hue * core;
	col += pow(core, 3);

	fragColor = vec4(col, 1.0);
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
