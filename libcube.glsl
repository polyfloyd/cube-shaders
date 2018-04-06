#define PI 3.141592

vec3 cube_map_to_3d(vec2 pos) {
	if (pos.x < 64 && pos.y < 64) {
		// top
		return vec3(
			1.0 - pos.y / 64.0,
			1.0 - pos.x / 64.0,
			1.0
		);

	} else if (pos.x < 64 && pos.y < 128) {
		// front
		return vec3(
			pos.x / 64.0,
			1.0,
			(pos.y - 64.0) / 64.0
		);

	} else if (pos.x < 64 && pos.y < 192) {
		// back
		return vec3(
			1.0 - pos.x / 64.0,
			0.0,
			(pos.y - 128.0) / 64.0
		);

	} else if (pos.x < 128 && pos.y < 64) {
		// bottom
		return vec3(
			1.0 - pos.y / 64.0,
			(pos.x - 64.0) / 64.0,
			0.0
		);

	} else if (pos.x < 128 && pos.y < 128) {
		// right
		return vec3(
			1.0,
			1.0 - (pos.x - 64.0) / 64.0,
			(pos.y - 64.0) / 64.0
		);

	} else if (pos.x < 128 && pos.y < 192) {
		// left
		return vec3(
			0.0,
			(pos.x - 64.0) / 64.0,
			(pos.y - 128.0) / 64.0
		);
	}
	return vec3(0.0);
}

vec2 map_to_sphere_uv(vec3 vert) {
	// Derived from https://stackoverflow.com/questions/25782895/what-is-the-difference-from-atany-x-and-atan2y-x-in-opengl-glsl/25783017
	float radius = distance(vec3(0), vert);
	float theta = atan(vert.y, vert.x + 1E-18);
	float phi = acos(vert.z / radius); // in [0,pi]
	return vec2(theta / (PI * 2), phi / PI);
}
