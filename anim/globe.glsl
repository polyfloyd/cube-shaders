#pragma use "../libcube.glsl"
#pragma map surface=image:../img/world.jpg
//#pragma map gyros=perip_mat4:/dev/ttyUSB0;230400

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	float t = iTime * 0.3;
	vec2 uv = map_to_sphere_uv(fragCoord);
	fragColor = texture2D(surface, vec2(-uv.x - t, uv.y));
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
