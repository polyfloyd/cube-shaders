// http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/

/**
 * Part 2 Challenges
 * - Change the diffuse color of the sphere to be blue
 * - Change the specual color of the sphere to be green
 * - Make one of the lights pulse by having its intensity vary over time
 * - Add a third light to the scene
 */

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;

void mainCube(out vec4 fragColor, in vec3 fragCoord);

/**
 * Signed distance function for a sphere centered at the origin with radius 1.0;
 */
float sphereSDF(vec3 samplePoint) {
	return length(samplePoint) - 0.65;
}

float cubeSDF(vec3 samplePoint) {
	return length(max(abs(samplePoint) - vec3(0.5), 0.0));
}

/**
 * Signed distance function describing the scene.
 * https://www.shadertoy.com/view/lt33z7
 * Absolute value of the return value indicates the distance to the surface.
 * Sign indicates whether the point is inside or outside the surface,
 * negative indicating inside.
 */
float sceneSDF(vec3 samplePoint) {
	return cubeSDF(samplePoint);
}

/**
 * Return the shortest distance from the eyepoint to the scene surface along
 * the marching direction. If no part of the surface is found between start and end,
 * return end.
 * 
 * eye: the eye point, acting as the origin of the ray
 * marchingDirection: the normalized direction to march in
 * start: the starting distance away from the eye
 * end: the max distance away from the ey to march before giving up
 */
float shortestDistanceToSurface(vec3 eye, vec3 marchingDirection, float start, float end) {
	float depth = start;
	for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
		float dist = sceneSDF(eye + depth * marchingDirection);
		if (dist < EPSILON) {
			return depth;
		}
		depth += dist;
		if (depth >= end) {
			return end;
		}
	}
	return end;
}


/**
 * Return the normalized direction to march in from the eye point for a single pixel.
 * 
 * fieldOfView: vertical field of view in degrees
 * size: resolution of the output image
 * fragCoord: the x,y coordinate of the pixel in the output image
 */
vec3 rayDirection(float fieldOfView, vec2 size, vec2 fragCoord) {
	vec2 xy = fragCoord - size / 2.0;
	float z = size.y / tan(radians(fieldOfView) / 2.0);
	return normalize(vec3(xy, -z));
}

/**
 * Using the gradient of the SDF, estimate the normal on the surface at point p.
 */
vec3 estimateNormal(vec3 p) {
	return normalize(vec3(
				sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
				sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
				sceneSDF(vec3(p.x, p.y, p.z  + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
				));
}

/**
 * Lighting contribution of a single point light source via Phong illumination.
 * 
 * The vec3 returned is the RGB color of the light's contribution.
 *
 * k_a: Ambient color
 * k_d: Diffuse color
 * k_s: Specular color
 * alpha: Shininess coefficient
 * p: position of point being lit
 * eye: the position of the camera
 * lightPos: the position of the light
 * lightIntensity: color/intensity of the light
 *
 * See https://en.wikipedia.org/wiki/Phong_reflection_model#Description
 */
vec3 phongContribForLight(vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye,
		vec3 lightPos, vec3 lightIntensity) {
	vec3 N = estimateNormal(p);
	vec3 L = normalize(lightPos - p);
	vec3 V = normalize(eye - p);
	vec3 R = normalize(reflect(-L, N));

	float dotLN = dot(L, N);
	float dotRV = dot(R, V);

	if (dotLN < 0.0) {
		// Light not visible from this point on the surface
		return vec3(0.0, 0.0, 0.0);
	}

	if (dotRV < 0.0) {
		// Light reflection in opposite direction as viewer, apply only diffuse
		// component
		return lightIntensity * (k_d * dotLN);
	}
	return lightIntensity * (k_d * dotLN + k_s * pow(dotRV, alpha));
}

/**
 * Lighting via Phong illumination.
 * 
 * The vec3 returned is the RGB color of that point after lighting is applied.
 * k_a: Ambient color
 * k_d: Diffuse color
 * k_s: Specular color
 * alpha: Shininess coefficient
 * p: position of point being lit
 * eye: the position of the camera
 *
 * See https://en.wikipedia.org/wiki/Phong_reflection_model#Description
 */
vec3 phongIllumination(vec3 k_a, vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye) {
	const vec3 ambientLight = 0.5 * vec3(1.0, 1.0, 1.0);
	vec3 color = ambientLight * k_a;

	vec3 light1Pos = vec3(4.0 * sin(iTime),
			2.0,
			4.0 * cos(iTime));
	vec3 light1Intensity = vec3(0.4, 0.4, 0.4);

	color += phongContribForLight(k_d, k_s, alpha, p, eye,
			light1Pos,
			light1Intensity);

	vec3 light2Pos = vec3(2.0 * sin(0.37 * iTime),
			2.0 * cos(0.37 * iTime),
			2.0);
	vec3 light2Intensity = vec3(0.4, 0.4, 0.4);

	color += phongContribForLight(k_d, k_s, alpha, p, eye,
			light2Pos,
			light2Intensity);
	return color;
}

vec3 background(vec2 coord) {
	float s = 12;
	float c = step(mod(coord.x * s + step(mod(coord.y * s, 2), 1), 2), 1);
	return vec3(c * 0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec3 dir = rayDirection(45.0, iResolution.xy, fragCoord);
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

	float dist = shortestDistanceToSurface(eye, dir, MIN_DIST, MAX_DIST);

	if (dist > MAX_DIST - EPSILON) {
		// Didn't hit anything
		float s = max(iResolution.y, iResolution.y);
		fragColor = vec4(background(fragCoord / s), 1.0);
		return;
	}

	// The closest point on the surface to the eyepoint along the view ray
	vec3 p = eye + dist * dir;

	vec3 K_a = vec3(0.7, 0.2, 0.2);
	vec3 K_d = vec3(0.0, 0.0, 1.0);
	vec3 K_s = vec3(0.0, 1.0, 0.0);
	float shininess = 10.0;

//	vec3 color = phongIllumination(K_a, K_d, K_s, shininess, p, eye);
//	vec3 color = p+vec3(0.5);
//	fragColor = vec4(color, 1.0);

	mainCube(fragColor, p);
}
