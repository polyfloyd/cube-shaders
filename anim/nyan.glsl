#pragma use "../libcube.glsl"
#pragma use "../libcolor.glsl"
#pragma map nyanTex=image:../img/nyan.png
#pragma map noise=builtin:RGBA Noise Small

const float TAIL_STEP_SIZE = 0.03;
const float TAIL_RADIUS    = 0.2;
const int   TAIL_NUM_STEPS = 80;

vec4 nyan(vec2 uv, float time) {
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
	float rx = time * 2;
	float ry = time;
	float rz = time * 1.5;
	mat3 mx = mat3(
		1.0, 0.0,      0.0,
		0.0, cos(rx),  sin(rx),
		0.0, -sin(rx), cos(rx)
	);
	mat3 my = mat3(
		cos(ry),  0.0, sin(ry),
		0.0,      1.0, 0.0,
		-sin(ry), 0.0, cos(ry)
	);
	mat3 mz = mat3(
		cos(rz),  sin(rz), 0.0,
		-sin(rz), cos(rz), 0.0,
		0.0,      0.0,     1.0
	);
	return my * mx * mz;
}

vec4 tail(vec3 fragCoord, float time) {
	float tailDist = 1. / 0.;
	float tailIntensity = 0;
	vec2 uvPrev = vec2(0);
	for (int i = 0; i < TAIL_NUM_STEPS; i++) {
		vec2 orig_uv = map_to_sphere_uv(fragCoord);
		vec2 uv = map_to_sphere_uv(fragCoord * movement(time - float(i) * TAIL_STEP_SIZE));

		float dist = length(uv);
		tailDist = min(tailDist, dist);
		tailIntensity = min(tailIntensity + step(dist, TAIL_RADIUS), 1);

		uvPrev = uv;
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
			round((tailDist - .05) * tailColors.length() * (1. / TAIL_RADIUS + 1))
		)],
		tailIntensity
	);
}

vec4 splarkles(vec3 fragCoord, float time) {
	const float speed = 0.2;
	const float thickness = .015;
	const float radius = .05;

	float a = 0;
	for (int i = 0; i < 16; i++) {
		float t = texture2D(noise, vec2(i / 64., 0)).r * 5 + time * speed;
		float rx = (floor(t / radius) + 10) * texture2D(noise, vec2(i / 64., 1)).r;
		float ry = (floor(t / radius) + 10) * texture2D(noise, vec2(i / 64., 1)).g;
		float rz = (floor(t / radius) + 10) * texture2D(noise, vec2(i / 64., 1)).b;
		mat3 mx = mat3(
			1.0, 0.0,      0.0,
			0.0, cos(rx),  sin(rx),
			0.0, -sin(rx), cos(rx)
		);
		mat3 my = mat3(
			cos(ry),  0.0, sin(ry),
			0.0,      1.0, 0.0,
			-sin(ry), 0.0, cos(ry)
		);
		mat3 mz = mat3(
			cos(rz),  sin(rz), 0.0,
			-sin(rz), cos(rz), 0.0,
			0.0,      0.0,     1.0
		);

		vec3 p = fragCoord * mx * my * mz;
		float dist = 1.5 - distance(vec3(0.5, 0, 0), normalize(p)) + mod(t, radius);
		vec2 s = cube_map_to_side(p).xy;
		float angrad = atan(s.x, s.y) / PI;

		a += (1 - step(1, dist - thickness)) // ring, inner
			* step(1, dist)                  // ring, outer
			* step(0.5, mod(angrad * 8, 1)); // line splitting
	}

	return vec4(1, 1, 1, step(1, a));
}

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
	float t = iTime;

	vec4 tail = tail(fragCoord, t);

	vec2 uv1 = map_to_sphere_uv(vec3(0, 0, 1) * movement(t));
	vec2 uv2 = map_to_sphere_uv(vec3(0, 0, 1) * movement(t - TAIL_STEP_SIZE));
	vec2 dir = normalize(uv1 - uv2);
	mat2 nyanDir = mat2(
		dir.x, dir.y,
		-dir.y, dir.x
	);

	float r = PI * .6;
	mat3 nyanR = mat3(
		cos(r),  0.0, sin(r),
		0.0,     1.0, 0.0,
		-sin(r), 0.0, cos(r)
	);
	vec2 nyanUV = map_to_sphere_uv(fragCoord * movement(t) * nyanR);
	nyanUV -= vec2(0, 0.5);
	nyanUV *= vec2(5, 2.5);
	nyanUV -= vec2(0, 0.5);
	nyanUV = nyanUV * nyanDir * nyanDir;
	vec4 nyan = nyan(nyanUV + .5, iTime);

	vec4 splarkles = splarkles(fragCoord, t);
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
