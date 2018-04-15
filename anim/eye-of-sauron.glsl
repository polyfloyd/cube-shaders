// Eye of Sauron.	By Dave Hoskins. Dec. 2013
// Video: http://youtu.be/DCQrDLbhiuQ

// https://www.shadertoy.com/view/ldBGWW

#pragma use "../libcube.glsl"
#pragma map iChannel0=builtin:RGBA Noise Medium
//#pragma map gyros=perip_mat4:/dev/ttyUSB0;230400

#define TAU 6.28318530718
#define MOD2 vec2(.16632,.17369)
#define MOD3 vec3(.16532,.17369,.15787)

float gTime = iTime + 44.29;
float flareUp = 0;

vec2 Rotate2axis(vec2 p, float a) {
	float si = sin(a);
	float co = cos(a);
	return mat2(si, co, -co, si) * p;
}

// Linear step, faster than smoothstep...
float LinearStep(float a, float b, float x) {
	return clamp((x-a)/(b-a), 0.0, 1.0);
}

float Hash(float p) {
	vec2 p2 = fract(vec2(p) * MOD2);
	p2 += dot(p2.yx, p2.xy+19.19);
	return fract(p2.x * p2.y);
}

float EyeNoise(in float x) {
	float p = floor(x);
	float f = fract(x);
	f = clamp(pow(f, 7.0), 0.0,1.0);
	//f = f*f*(3.0-2.0*f);
	return mix(Hash(p), Hash(p+1.0), f);
}

float Noise( in vec3 x ) {
	vec3 p = floor(x);
	vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy + vec2(37.0, 17.0) * p.z) + f.xy;
	vec2 rg = textureLod( iChannel0, (uv+.5)/256., 0.).yx;
	return mix(rg.x, rg.y, f.z);
}

float Pupil(vec3 p, float r) {
	// It's just a stretched sphere but the mirrored
	// halves are push together to make a sharper top and bottom.
	p.xz = abs(p.xz)+.25;
	return length(p) - r;
}

float DE_Fire(vec3 p) {
	p *= vec3(1.0, 1.0, 1.5);
	float len = length(p);
	float ax = atan(p.y, p.x)*10.0;
	float ay = atan(p.y, p.z)*10.0;
	vec3 shape = vec3(len*.5-gTime*1.2, ax, ay) * 2.0;

	shape += 2.5 * (Noise(p * .25) -
					Noise(p * 0.5) * .5 +
					Noise(p * 2.0) * .25);
	float f = Noise(shape)*6.0;
	f += (LinearStep(7.30, 8.3+flareUp, len)*LinearStep(12.0+flareUp*2.0, 8.0, len)) * 3.0;
	p *= vec3(.75, 1.2, 1.0);
	len = length(p);
	f = mix(f, 0.0, LinearStep(12.5+flareUp, 16.5+flareUp, len));
	return f;
}

float Sphere(vec3 p, float r) {
	return length(p) - r;
}

float DE_Pillars(vec3 p) {
	// It's just two spheres with added bumpy noise.
	// Simple, but it'll do fine. :)
	float d = Sphere((p+vec3(0.0, 1.0, 0.0))*vec3(1.0, 1.0, 18.0), 20.0);
	d = max(-Sphere((p + vec3(0.0, -3.0, 38.0))* vec3(1.5, 1.1, .95), 44.0), d);
	d += Noise(p*2.0)*.15 + Noise(p*8.0)*.04;
	return d;
}

float DE_Pupil(vec3 p) {
	float time = gTime * .5+sin(gTime*.3)*.5;
	float t = EyeNoise(time) * .125 +.125;
	p.yz = Rotate2axis(p.yz, t * TAU);
	p *= vec3(1.2-EyeNoise(time+32.5)*.5, .155, 1.0);
	t = EyeNoise(time-31.0) * .125 +.1875;
	p.xz = Rotate2axis(p.xz, t*TAU);
	p += vec3(.0, 0.0, 4.);

	float  d = Pupil(p, .78);
	return d * max(1.0, abs(p.y*2.5));
}

vec3 Normal(in vec3 pos) {
	vec2 eps = vec2(0.1, 0.0);
	vec3 nor = vec3(
		DE_Pillars(pos+eps.xyy) - DE_Pillars(pos-eps.xyy),
		DE_Pillars(pos+eps.yxy) - DE_Pillars(pos-eps.yxy),
		DE_Pillars(pos+eps.yyx) - DE_Pillars(pos-eps.yyx));
	return normalize(nor);
}

vec4 Raymarch(in vec3 ro, in vec3 rd, in vec2 randPos, out float pupil) {
	float sum = 0.0;
	// Starting point plus dither to prevent edge banding...
	float t = 14.0 + .1 * texture(iChannel0, randPos).y;
	vec3 pos = vec3(0.0, 0.0, 0.0);
	pupil = 0.0;
	for (int i=0; i < 80 && t <= 37.0; i++) {
		pos = ro + t*rd;
		vec3 shape = pos * vec3(1.8, .4, 1.5);

		// Accumulate pixel denisity depending on the distance to the pupil
		float d = DE_Pupil(pos);
		pupil += LinearStep(0.02 + Noise(pos*4.0+gTime)*.3, 0.0, d) * .17;

		// Add fire around pupil...
		sum += LinearStep(1.3, 0.0, d) * .024;

		sum += max(DE_Fire(pos), 0.0) * .00262;
		t += max(.1, t*.0057);
	}

	return vec4(pos, clamp(sum*sum*sum, 0.0, 1.0 ));
}

vec3 FlameColour(float f) {
	f = f*f*(3.0-2.0*f);
	return min(vec3(f+.8, f*f*1.4+.05, f*f*f*.6) * f, 1.0);
}

void mainCube(out vec4 fragColor, in vec3 fragCoord) {
//	fragCoord = fragCoord * gyros;
	vec2 uv = map_to_sphere_uv(fragCoord);
	uv.x *= 2.0;
	uv.x += 0.5;

	flareUp = max(sin(gTime*.75+3.5), 0.0);
	vec2 p = -1.0 + 2.0 * uv;
	p.x *= iResolution.x/iResolution.y;

	vec3 origin = vec3(0, -10, -20);
	vec3 target = vec3(0.0, 0.0, 0.0);

	// Make camera ray using origin and target positions...
	vec3 cw = normalize( target-origin);
	vec3 cp = vec3(0.0, 1.0, 0.0);
	vec3 cu = normalize( cross(cw, cp) );
	vec3 cv = ( cross(cu,cw) );
	vec3 ray = normalize(p.x*cu + p.y*cv + 1.5 * cw );

	float pupil = 0.0;
	vec4 ret = Raymarch(origin, ray, uv, pupil);
	vec3 col = vec3(0.0);

	vec3 light = vec3(0.0, 4.0, -4.0);
	// Do the lightning flash effect...
	float t = mod(gTime+3.0, 13.0);
	float flash = smoothstep(0.4, .0, t);
	flash += smoothstep(0.2, .0, abs(t-.6)) * 1.5;
	flash += smoothstep(0.7, .8, t) * smoothstep(1.3, .8, t);
	flash *= 2.2;

	col += FlameColour(ret.w);
	col = mix (col, vec3(0.0), min(pupil, 1.0));

	// Contrasts...
	col = sqrt(col);
	col = min(mix(vec3(length(col)),col, 1.22), 1.0);
	col += col * .3;

	fragColor = vec4(min(col, 1.0),1.0);
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
