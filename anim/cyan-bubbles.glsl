// https://www.shadertoy.com/view/Xl2Bz3

#pragma use "../libcube.glsl"

#define ROWS 9
#define COLS 12.
//#define PI 3.14159265359
#define TAU 6.28318530718
#define es (4./192)
#define initialRad .175
#define waveCenter .4325
#define waveWidth .205
#define colDelta PI/COLS
#define rMat(x) mat2(cos(x), -sin(x), sin(x), cos(x))
#define dotRad(x) TAU*x/float(COLS)*.25
#define CLR vec3(.288, .843, .976)

float rm(float value, float min, float max) {
    return clamp((value - min) / (max - min), 0., 1.);
}

float calcRowRad(int rowNum){
    float rad = initialRad;
    //FIXME codeblock below could be replaced with non conditional expression,
    //          but in some reason it don't work. Any ideas?
    //rad += step(0., sin(iTime)) * step(0., cos(iTime)) * .066;
    {
        float s = sin(iTime * 12.);
        float c = cos(iTime * 12.);
        if(s > 0. && c > 0.)
            rad += s * .066;
    }
    for(int i=0; i<rowNum; i++)
        rad += dotRad(rad) * 1.33;
    return rad;
}

float clr(float r, float a){
    vec2 st = vec2(r * cos(a), r * sin(a));
    float clr = 0.;
    for(int j = 0; j < ROWS; j++){
        float rowRad = calcRowRad(j);
        vec2 dotCenter = vec2(rowRad, 0.) * rMat(colDelta * mod(float(j), 2.));
        float dotRad = dotRad(rowRad);
        float dotClr = smoothstep(dotRad, dotRad - es, length(st - dotCenter));
        float thickness = pow(rm(abs(length(dotCenter) - waveCenter), 0., waveWidth), 1.25);
        dotClr *= smoothstep(dotRad * thickness - es, dotRad * thickness, length(st - dotCenter));
        dotClr *= step(es, 1. - thickness);
        clr += dotClr;
    }

    return clr;
}

//void mainImage(out vec4 fragColor, in vec2 fragCoord) {
//    vec2 st = (mod(fragCoord.xy, 64.0) * 2. - 64.0)/64.0;
//    float delta = PI/COLS*2.;
//    float l = length(st);
//    float a = mod(atan(st.y, st.x), delta) - delta/4.;
//    fragColor = vec4(clr(l, a) * CLR, 1.);
//}

void mainCube(out vec4 fragColor, vec3 fragCoord) {
    vec2 st = cube_map_to_side(fragCoord).xy * 1.5;
    float delta = PI/COLS*2.;
    float l = length(st);
    float a = mod(atan(st.y, st.x), delta) - delta/4.;
    fragColor = vec4(clr(l, a) * CLR, 1.);
}

#ifndef _EMULATOR
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	mainCube(fragColor, cube_map_to_3d(fragCoord));
}
#endif
