// Based on: https://www.shadertoy.com/view/MslGD8 by inigo quilez - iq/2013

#pragma use "../libcube.glsl"

vec3 hash(vec3 seed) {
	vec3 p = vec3(
		dot(seed, vec3(127.1, 311.7, 753.9)),
		dot(seed, vec3(269.5, 183.3, 742.3)),
		dot(seed, vec3(373.5, 973.1, 701.7))
	);
	return fract(sin(p) * 18.5453);
}

struct Cell {
	float dist;
	float id;
	float edge;
};

Cell voronoi(vec3 uv, float motion) {
	vec3 n = floor(uv);
	vec3 f = fract(uv);

	vec3 m = vec3(8);
	float second = 0;

	for (int z = -1; z <= 1; z++) {
		for (int y = -1; y <= 1; y++) {
			for (int x = -1; x <= 1; x++) {
				vec3 grid = vec3(float(x), float(y), float(z));
				vec3 point = hash(n + grid) * 6;

				float k = sin(motion + point.x + point.y + point.z);
				vec3 r = grid - f + (k * .3 + .5);

				float d = dot(r, r);
				if (d < m.x) {
					second = m.x;
					m = vec3(d, point);
				} else if (d < second) {
					second = d;
				}
			}
		}
	}

	return Cell(sqrt(m.x), m.y + m.z, abs(m.x - second));
}

vec3 color(float gradient) {
	return 0.5 + 0.5 * cos(gradient * PI*2 + vec3(0.0, 1.0, 2.0));	
}

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	fragColor = vec4(0, 0, 0, 1.0);

	Cell cell1 = voronoi(fragCoord * 3, iTime * 2);
	Cell cell2 = voronoi(fragCoord * 5, iTime * 3);
	Cell cell3 = voronoi(fragCoord * 7, iTime * 4);
	Cell cell4 = voronoi(fragCoord * 9, iTime * 5);

	vec4 col4 = vec4(vec3(1, .5, 0), clamp(1-cell4.edge*4, 0, 1));
	fragColor.rgb = mix(fragColor.rgb, col4.rgb, col4.a);
	vec4 col3 = vec4(vec3(1, 1, 0), clamp(1-cell3.edge*4, 0, 1));
	fragColor.rgb = mix(fragColor.rgb, col3.rgb, col3.a);
	vec4 col2 = vec4(vec3(.7, 0, 1), clamp(1-cell2.edge*4, 0, 1));
	fragColor.rgb = mix(fragColor.rgb, col2.rgb, col2.a);
	vec4 col1 = vec4(vec3(0, .8, 1), clamp(1-cell1.edge*4, 0, 1));
	fragColor.rgb = mix(fragColor.rgb, col1.rgb, col1.a);
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
