const float PI = 3.141592;
const float EPSILON = 0.0001;

// Maps 2D output image space to 3D cube space.
//
// The returned coordinates are in the range of (-.5, .5).
vec3 cube_map_to_3d(vec2 pos) {
	vec3 p = vec3(0);
	if (pos.x < 64 && pos.y < 64) {
		// top
		p = vec3(
			1.0 - pos.y / 64.0,
			1.0 - pos.x / 64.0,
			1.0
		);

	} else if (pos.x < 64 && pos.y < 128) {
		// front
		p = vec3(
			pos.x / 64.0,
			1.0,
			(pos.y - 64.0) / 64.0
		);

	} else if (pos.x < 64 && pos.y < 192) {
		// back
		p = vec3(
			1.0 - pos.x / 64.0,
			0.0,
			(pos.y - 128.0) / 64.0
		);

	} else if (pos.x < 128 && pos.y < 64) {
		// bottom
		p = vec3(
			1.0 - pos.y / 64.0,
			(pos.x - 64.0) / 64.0,
			0.0
		);

	} else if (pos.x < 128 && pos.y < 128) {
		// right
		p = vec3(
			1.0,
			1.0 - (pos.x - 64.0) / 64.0,
			(pos.y - 64.0) / 64.0
		);

	} else if (pos.x < 128 && pos.y < 192) {
		// left
		p = vec3(
			0.0,
			(pos.x - 64.0) / 64.0,
			(pos.y - 128.0) / 64.0
		);
	}
	return p - .5;
}

vec2 map_to_sphere_uv(vec3 vert) {
	// Derived from https://stackoverflow.com/questions/25782895/what-is-the-difference-from-atany-x-and-atan2y-x-in-opengl-glsl/25783017
	float radius = distance(vec3(0), vert);
	float theta = atan(vert.y, vert.x + 1E-18);
	float phi = acos(vert.z / radius); // in [0,pi]
	return vec2(theta / (PI * 2), phi / PI);
}

// Maps a uniform 3D position to an uniform 2D position on the current side.
//
// The coordinages are in the range of (-.5, .5).
//
// TODO: define orientation.
vec2 cube_map_to_side(vec3 p) {
	if (abs(p.x) >= .5 - EPSILON) {
		return vec2(p.y, p.z);
	}
	if (abs(p.y) >= .5 - EPSILON) {
		return vec2(p.x, p.z);
	}
	if (abs(p.z) >= .5 - EPSILON) {
		return vec2(p.x, p.y);
	}
	return vec2(0);
}
