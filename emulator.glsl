// This file implements an emulator for a LED-Panel cube.
//
// The renderer is based upon this ray marching tutorial:
//   http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/
//
// To use:
//
// 1. define the special rendering function:
//
//   void mainCube(out vec4 fragColor, in vec3 fragCoord);
//
// 2. Define the mainImage function with include guard:
//
//   #ifndef _EMULATOR
//   void mainImage(out vec4 fragColor, in vec2 fragCoord) {
//       mainCube(fragColor, cube_map_to_3d(fragCoord) * 2 - 1);
//   }
//   #endif
//
// 3. Include the emulator by prepending a separate -i option on the Shady command line:
//
//   shady -i emulator.glsl -i my-animation.glsl <other options>

#define _EMULATOR

// Forward declaration of the function that renders the surface of the cube.
void mainCube(out vec4 fragColor, in vec3 fragCoord);

const int EMU_MAX_MARCHING_STEPS = 255;
const float EMU_MIN_DIST = 0.0;
const float EMU_MAX_DIST = 100.0;
const float EMU_EPSILON = 0.0001;

float emuCubeSDF(vec3 samplePoint) {
	return length(max(abs(samplePoint) - vec3(0.5), 0.0));
}

float emuSceneSDF(vec3 samplePoint) {
	return emuCubeSDF(samplePoint);
}

float emuShortestDistanceToSurface(vec3 eye, vec3 marchingDirection, float start, float end) {
	float depth = start;
	for (int i = 0; i < EMU_MAX_MARCHING_STEPS; i++) {
		float dist = emuSceneSDF(eye + depth * marchingDirection);
		if (dist < EMU_EPSILON) {
			return depth;
		}
		depth += dist;
		if (depth >= end) {
			return end;
		}
	}
	return end;
}

vec3 emuRayDirection(float fieldOfView, vec2 size, vec2 fragCoord) {
	vec2 xy = fragCoord - size / 2.0;
	float z = size.y / tan(radians(fieldOfView) / 2.0);
	return normalize(vec3(xy, -z));
}

vec3 emuEstimateNormal(vec3 p) {
	return normalize(vec3(
		emuSceneSDF(vec3(p.x + EMU_EPSILON, p.y, p.z)) - emuSceneSDF(vec3(p.x - EMU_EPSILON, p.y, p.z)),
		emuSceneSDF(vec3(p.x, p.y + EMU_EPSILON, p.z)) - emuSceneSDF(vec3(p.x, p.y - EMU_EPSILON, p.z)),
		emuSceneSDF(vec3(p.x, p.y, p.z  + EMU_EPSILON)) - emuSceneSDF(vec3(p.x, p.y, p.z - EMU_EPSILON))
	));
}

vec3 emuBackground(vec2 coord) {
	float s = 12;
	float c = step(mod(coord.x * s + step(mod(coord.y * s, 2), 1), 2), 1);
	return vec3(c * 0.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec3 dir = emuRayDirection(45.0, iResolution.xy, fragCoord);
	vec3 eye = vec3(0.0, 0.0, 5.0);

	float r = iTime;
	mat3 model = mat3(
		cos(r),  0.0, sin(r),
		0.0,     1.0, 0.0,
		-sin(r), 0.0, cos(r)
	);
	model = model * mat3(
		1.0, 0.0,     0.0,
		0.0, cos(r),  sin(r),
		0.0, -sin(r), cos(r)
	);
	eye = eye * model;
	dir = dir * model;

	float dist = emuShortestDistanceToSurface(eye, dir, EMU_MIN_DIST, EMU_MAX_DIST);
	if (dist > EMU_MAX_DIST - EMU_EPSILON) {
		// Didn't hit anything, draw the background.
		float s = max(iResolution.y, iResolution.y);
		fragColor = vec4(emuBackground(fragCoord / s), 1.0);
		return;
	}

	// The closest point on the surface to the eyepoint along the view ray
	vec3 p = eye + dist * dir;
	mainCube(fragColor, p);
}
