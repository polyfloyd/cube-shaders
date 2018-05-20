#pragma use "../libcube.glsl"
#pragma map lightTex=image:../img/globe-light.jpg
#pragma map darkTex=image:../img/globe-dark.jpg
#pragma map gyros=perip_mat4:/dev/ttyUSB0;230400?

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	fragCoord *= mat3(gyros);
	float tLight = iTime * 1.2;
	float tGeo = iTime * 0.1;

	vec2 uv = map_to_sphere_uv(fragCoord);
	vec4 li = texture2D(lightTex, vec2(-uv.x - tGeo, uv.y));
	vec4 da = texture2D(darkTex, vec2(-uv.x - tGeo, uv.y));

	vec3 terminator = fragCoord * mat3(
		cos(tLight),  sin(tLight), 0,
		-sin(tLight), cos(tLight), 0,
		0,            0,           1
	);

	fragColor = mix(li, da, clamp(terminator.x * 8 + .5, 0, 1));
	fragColor.rgb += vec3(.2, .0, 0) * clamp(-abs(terminator.x * 16) + 1, 0, 1);
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
