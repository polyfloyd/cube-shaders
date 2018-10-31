#pragma use "../libcube.glsl"
#pragma use "../libcolor.glsl"
#pragma map nyanTex=image:../img/nyan.png
#pragma map noise=builtin:RGBA Noise Small

const float TAIL_STEP_SIZE = 0.03;
const float TAIL_RADIUS    = 0.2;
const int   TAIL_NUM_STEPS = 80;

vec4 nyancatTexture(vec2 uv, float time) {
	uv = clamp(uv, 0, 1);
	const float numFrames = 6;
	const float subset = numFrames * 40 / 256.0;
	float idx = mod(round(time * 12), numFrames);
	return texture2D(nyanTex, vec2(
		subset * (idx + uv.x) / numFrames,
		uv.y
	));
}

mat3 movement(float time) {
	float ry = time * 0.8;
	float rz = time * 2.1;
	mat3 my = mat3(
		 cos(ry), 0.0, sin(ry),
		 0.0,     1.0, 0.0,
		-sin(ry), 0.0, cos(ry)
	);
	mat3 mz = mat3(
		 cos(rz), sin(rz), 0.0,
		-sin(rz), cos(rz), 0.0,
		 0.0,     0.0,     1.0
	);
	return my * mz;
}

vec4 nyancat(vec3 fragCoord, float time) {
	vec3 p = normalize(fragCoord * movement(time));
	vec3 n = cross(p, vec3(1, 0, 0));
	vec2 nyanUV = n.zy * vec2(-1, 1) * .7;
	vec3 side = fragCoord * movement(time);
	return nyancatTexture(nyanUV + .5, iTime) * step(-side.x, 0);
}

vec4 tail(vec3 fragCoord, float time) {
	float tailDist = 1. / 0.;
	float tailIntensity = 0;
	for (int i = 0; i < TAIL_NUM_STEPS; i++) {
		vec3 ref = fragCoord * movement(time - float(i) * TAIL_STEP_SIZE);
		float dist = distance(normalize(ref), vec3(1, 0, 0)) * .6;
		tailDist = min(tailDist, dist);
		tailIntensity = min(tailIntensity + step(dist, TAIL_RADIUS), 1);
	}

	vec3 tailColors[6];
	tailColors[0] = vec3(1, 0, 0);
	tailColors[1] = vec3(1, 0.6, 0);
	tailColors[2] = vec3(1, 1, 0);
	tailColors[3] = vec3(0, 1, 0);
	tailColors[4] = vec3(0, 0.5, 0.8);
	tailColors[5] = vec3(0.6, 0, 0.6);
	return vec4(
		tailColors[int(
			floor(tailDist * tailColors.length() / TAIL_RADIUS)
		)],
		tailIntensity
	);
}

vec4 splarkles(vec3 fragCoord, float time) {
	const float speed = 2.2;
	const float thickness = .05;
	const float radius = .4;

	vec3 color = vec3(0);

	float a = 0;
	for (int i = 0; i < 16; i++) {
		float t = time * speed + texture2D(noise, vec2(i / 64., 0)).r;
		float n = mod(t, 1);

		vec4 r = (floor(t) + 10) * texture2D(noise, vec2(i / 64., 1));
		mat3 mx = mat3(
			1.0,  0.0,      0.0,
			0.0,  cos(r.x), sin(r.x),
			0.0, -sin(r.x), cos(r.x)
		);
		mat3 my = mat3(
			 cos(r.y), 0.0, sin(r.y),
			 0.0,      1.0, 0.0,
			-sin(r.y), 0.0, cos(r.y)
		);
		mat3 mz = mat3(
			 cos(r.z), sin(r.z), 0.0,
			-sin(r.z), cos(r.z), 0.0,
			0.0,       0.0,      1.0
		);
		mat3 motion = mx * my * mz;

		vec3 p = normalize(fragCoord * motion);
		float dist = 1 - distance(vec3(0, 0, 1), p) + n * radius - thickness;
		vec3 direction = cross(p, vec3(0, 0, 1));
		float angrad = atan(direction.x, direction.y) / PI;

		a += (1 - step(1, dist - thickness)) // ring, inner
			* step(1, dist)                  // ring, outer
			* step(0.5, mod(angrad * 8, 1)); // line splitting
	}

	return vec4(1, 1, 1, clamp(a, 0, 1));
}

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	vec4 tail = tail(fragCoord, iTime);
	vec4 nyan = nyancat(fragCoord, iTime);
	vec4 splarkles = splarkles(fragCoord, iTime);

	fragColor.rgb = vec3(0x07, 0x26, 0x47) / 255.0;
	fragColor.rgb = mix(fragColor.rgb, tail.rgb, tail.a);
	fragColor.rgb = mix(fragColor.rgb, nyan.rgb, nyan.a);
	fragColor.rgb = mix(fragColor.rgb, splarkles.rgb, splarkles.a);
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
