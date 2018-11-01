// Modified from: https://www.shadertoy.com/view/MslGD8

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#pragma use "../libcube.glsl"

vec3 hash(vec3 seed) {
	vec3 p = vec3(
		dot(seed, vec3(127.1, 311.7, 753.9)),
		dot(seed, vec3(269.5, 183.3, 742.3)),
		dot(seed, vec3(373.5, 973.1, 701.7))
	);
	return fract(sin(p) * 18.5453);
}

// return distance, and cell id
vec2 voronoi(vec3 x) {
	vec3 n = floor(x);
	vec3 f = fract(x);

	vec3 m = vec3(8);
	for (int z = -1; z <= 1; z++) {
		for (int y = -1; y <= 1; y++) {
			for (int x = -1; x <= 1; x++) {
				vec3 g = vec3(x, y, z);
				vec3 o = hash(n + g);
				vec3 r = g - f + (0.5+0.5*tan(iTime + PI*2 - o));
				float d = dot(r, r);
				if (d < m.x) {
					m = vec3(d, o);
				}
			}
		}
	}

	return vec2(sqrt(m.x), m.y + m.z);
}

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	vec2 c = voronoi((8.0 + 4.0 * sin(0.2 * iTime)) * fragCoord);
	vec3 col = 0.5 + 0.5*cos(c.y*PI*2 + vec3(0.0,1.0,2.0));
	fragColor = vec4(col, 1.0);
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
