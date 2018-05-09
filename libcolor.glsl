vec3 hsvToRGB(vec3 hsv) {
	float h = hsv.x;
	float s = hsv.y;
	float v = hsv.z;
	if (s <= 0) {
		return vec3(v);
	}

	float hh = mod(h, 1) * 6;
	float ff = mod(hh, 1);
	float p = v * (1.0 - s);
	float q = v * (1.0 - (s * ff));
	float t = v * (1.0 - (s * (1.0 - ff)));

	if (hh <= 1) {
		return vec3(v, t, p);
	} else if (hh <= 2) {
		return vec3(q, v, p);
	} else if (hh <= 3) {
		return vec3(p, v, t);
	} else if (hh <= 4) {
		return vec3(p, q, v);
	} else if (hh <= 5) {
		return vec3(t, p, v);
	} else {
		return vec3(v, p, q);
	}
}
