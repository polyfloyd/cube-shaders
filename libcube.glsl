const float PI = 3.141592;
const float EPSILON = 0.0001;

// Maps 2D output image space to 3D cube space.
//
// The returned coordinates are in the range of (-.5, .5).
vec3 cube_map_to_3d(vec2 pos) {
	vec3 p = vec3(0);
	if (pos.x < 64 && pos.y < 64) {
		// front
		p = vec3(
			pos.x / 64,
			0,
			pos.y / 64
		);

	} else if (pos.x < 64 && pos.y < 128) {
		// back
		p = vec3(
			1 - pos.x / 64,
			1,
			(pos.y - 64) / 64
		);

	} else if (pos.x < 64 && pos.y < 192) {
		// top
		p = vec3(
			(pos.y - 128) / 64,
			1 - pos.x / 64,
			1
		);

	} else if (pos.x < 128 && pos.y < 64) {
		// right
		p = vec3(
			1,
			(pos.x - 64) / 64,
			pos.y / 64
		);

	} else if (pos.x < 128 && pos.y < 128) {
		// left
		p = vec3(
			0,
			1 - (pos.x - 64) / 64,
			(pos.y - 64) / 64
		);

	} else if (pos.x < 128 && pos.y < 192) {
		// bottom
		p = vec3(
			(pos.y - 128) / 64,
			(pos.x - 64) / 64,
			0
		);
	}
	return p - .5;
}

// Maps a 3D position to a 2D position on a virtual sphere that wraps around
// the origin. The poles are aligned with the Z-axis.
//
// The coordinates are both in the range of [-0.5, 0.5].
vec2 map_to_sphere_uv(vec3 vert) {
	// Derived from https://stackoverflow.com/questions/25782895/what-is-the-difference-from-atany-x-and-atan2y-x-in-opengl-glsl/25783017
	float radius = distance(vec3(0), vert);
	float theta = atan(vert.y, vert.x + 1E-18); // in [-pi,pi]
	float phi = acos(vert.z / radius); // in [0,pi]
	return vec2(theta / PI * .5, phi / PI);
}

// Maps a uniform 3D position to an uniform 2D position on the current side.
//
// The X and Y of the returned vector are the coordinates and are in the range
// of (-.5, .5).
// 
// Z is the remaining axis and is constant for a single side.
//
// W is a unique identifier for the side.
//
// TODO: define orientation.
vec4 cube_map_to_side(vec3 p) {
	if (abs(p.x) >= .5 - EPSILON) {
		return vec4(p.y * sign(p.x), p.z, p.x, step(p.x, 0));
	}
	if (abs(p.y) >= .5 - EPSILON) {
		return vec4(p.x * sign(-p.y), p.z, p.y, step(p.y, 0) + 2);
	}
	if (abs(p.z) >= .5 - EPSILON) {
		return vec4(p.x * sign(p.z), p.y, p.z, step(p.z, 0) + 4);
	}
	return vec4(0, 0, 0, -1);
}
