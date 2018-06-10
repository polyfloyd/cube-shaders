#pragma use "../libcube.glsl"
#pragma map image=image:../img/wow.jpg

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	float t = iTime * 4;
	vec2 uv = cube_map_to_side(fragCoord) * vec2(1, -1);
	vec3 c = texture2D(image, uv * (mod(-t, 1) * 0.5 + 0.5) + .5).rgb;
	fragColor.rgb = mix(1 - c, c, step(.5, mod(t / 2, 1)));
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
