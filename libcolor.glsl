vec3 hsvToRGB(vec3 hsv) {
	float h = hsv.x;
	float s = hsv.y;
	float v = hsv.z;
	if (s <= 0) {
		return vec3(v);
	}

	float hh = mod(h, 1) * 6;
	int i = int(hh);
	float ff = hh - i;
	float p = v * (1.0 - s);
	float q = v * (1.0 - (s * ff));
	float t = v * (1.0 - (s * (1.0 - ff)));

	switch (i) {
		case 0:
			return vec3(v, t, p);
		case 1:
			return vec3(q, v, p);
		case 2:
			return vec3(p, v, t);
		case 3:
			return vec3(p, q, v);
		case 4:
			return vec3(t, p, v);
		default:
			return vec3(v, p, q);
	}
}
