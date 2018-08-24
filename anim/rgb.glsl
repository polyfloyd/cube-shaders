#pragma use "../libcube.glsl"

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	fragColor.rgb = fragCoord.rgb + .5;
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
