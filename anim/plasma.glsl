#pragma use "../libcube.glsl"
#pragma use "../libcolor.glsl"
#pragma use "../libnoise.glsl"

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	float h = mod(perlin_noise(fragCoord * 3 + iTime) + iTime, 1);
	fragColor = vec4(hsvToRGB(vec3(h, 1, 1)), 1.0);
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
