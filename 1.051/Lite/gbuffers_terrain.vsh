#version 120

/*--------------------
//ADJUSTABLE VARIABLES//
---------------------*/

#define WAVING_LEAVES
//#define WAVING_VINES
#define WAVING_GRASS
#define TALLPLANTS_and_TALLGRASS
#define WAVING_WHEAT
#define WAVING_CARROTS_POTATOES
#define WAVING_FLOWERS
#define WAVING_SAPLINGS
#define WAVING_FIRE
#define WAVING_LAVA
#define WAVING_LILYPAD

//AETHER 2
//#define WAVING_AETHER_GRASS
//#define WAVING_AETHER_LEAVES
//#define WAVING_AETHER_FLOWERS
//#define WAVING_ORANGE_PLANT			//A bit buggy

//THAUMCRAFT
//#define WAVING_THAUMCRAFT_LEAVES
//#define WAVING_TAINTED_GRASS_AND_PLANT
//#define WAVING_THAUMCRAFT_SAPLINGS_AND_FLOWERS

/*---------------------------
//END OF ADJUSTABLE VARIABLES//
----------------------------*/



const float PI = 3.1415927;

varying vec4 color;
varying vec2 lmcoord;
varying float translucent;
varying vec4 vtexcoordam; // .st for add, .pq for mul
varying vec4 vtexcoord;

varying float dist;

varying vec3 tangent;
varying vec3 normal;
varying vec3 binormal;
varying vec3 viewVector;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform int worldTime;
uniform float frameTimeCounter;
uniform float rainStrength;

float pi2wt = PI*2*(frameTimeCounter*24);

vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {
    vec3 ret;
    float magnitude,d0,d1,d2,d3;
    magnitude = sin(pi2wt*fm + pos.x*0.5 + pos.z*0.5 + pos.y*0.5) * mm + ma;
    d0 = sin(pi2wt*f0);
    d1 = sin(pi2wt*f1);
    d2 = sin(pi2wt*f2);
    ret.x = sin(pi2wt*f3 + d0 + d1 - pos.x + pos.z + pos.y) * magnitude;
    ret.z = sin(pi2wt*f4 + d1 + d2 + pos.x - pos.z + pos.y) * magnitude;
	ret.y = sin(pi2wt*f5 + d2 + d0 + pos.z + pos.y - pos.y) * magnitude;
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0027, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.0348, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}

vec3 calcWaterMove(in vec3 pos) {
	float fy = fract(pos.y + 0.001);
	
	if (fy > 0.002) {
		float wave = 0.05 * sin(2 * PI * (worldTime / 86.0 + pos.x /  7.0 + pos.z / 13.0))
					+ 0.05 * sin(2 * PI * (worldTime / 60.0 + pos.x / 11.0 + pos.z /  5.0));
		return vec3(0, clamp(wave, -fy, 1.0-fy), 0);
	}
	
	else {
		return vec3(0);
	}
}

varying float glowingBlocks;

//////////////////////////////main//////////////////////////////
//////////////////////////////main//////////////////////////////
//////////////////////////////main//////////////////////////////
//////////////////////////////main//////////////////////////////
//////////////////////////////main//////////////////////////////

void main() {
	vec2 texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;
	vec2 midcoord = (gl_TextureMatrix[0] *  mc_midTexCoord).st;
	vec2 texcoordminusmid = texcoord-midcoord;
	vtexcoordam.pq  = abs(texcoordminusmid)*2;
	vtexcoordam.st  = min(texcoord,midcoord-texcoordminusmid);
	vtexcoord.st    = sign(texcoordminusmid)*0.5+0.5;
	
	translucent = 0.0f;
	glowingBlocks = 0.0f;

	if (mc_Entity.x == 50.0 	//Torch
    //|| mc_Entity.x == 76.0		//Redstone Torch ON
	|| mc_Entity.x == 89.0		//Glowstone
	|| mc_Entity.x == 124.0){ 	//Redstone Lamp ON
    //|| mc_Entity.x == 10.0		//Flowing Lava
	//|| mc_Entity.x == 11.0){	//Still Lava
	glowingBlocks = 1.0;
	}	
	
	float istopv = 0.0;
	if (gl_MultiTexCoord0.t < mc_midTexCoord.t) istopv = 1.0;
	/* un-rotate */
	vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
	vec3 worldpos = position.xyz + cameraPosition;
	
	//initialize per-entity waving parameters
	float parm0,parm1,parm2,parm3,parm4,parm5 = 0.0;
	vec3 ampl1,ampl2;
	ampl1 = vec3(0.0);
	ampl2 = vec3(0.0);
	

if (istopv > 0.9) {
#ifdef WAVING_VINES
		if ( mc_Entity.x == 106 ) {
			parm0 = 0.0040;
			parm1 = 0.0064;
			parm2 = 0.0043;
			parm3 = 0.0035;
			parm4 = 0.0037;
			parm5 = 0.0041;
			ampl1 = vec3(1.0,0.2,1.0);
			ampl2 = vec3(0.5,0.1,0.5);
		}
#endif
	
#ifdef WAVING_GRASS
	if ( mc_Entity.x == 31 || mc_Entity.x == 204.0 || mc_Entity.x == 204.2 || mc_Entity.x == 435.0 || mc_Entity.x == 435.1 || mc_Entity.x == 435.2 || mc_Entity.x == 435.3 || mc_Entity.x == 435.4 || mc_Entity.x == 435.5 || mc_Entity.x == 435.6 || mc_Entity.x == 435.7 || mc_Entity.x == 435.8 || mc_Entity.x == 435.9 || mc_Entity.x == 435.10 || mc_Entity.x == 435.11 || mc_Entity.x == 435.12 || mc_Entity.x == 435.13 || mc_Entity.x == 435.14 || mc_Entity.x == 435.15) {
			parm0 = 0.0041;
			parm1 = 0.0070;
			parm2 = 0.0044;
			parm3 = 0.0038;
			parm4 = 0.0063;
			parm5 = 0.0;
			ampl1 = vec3(3.0,1.6,3.0);
			ampl2 = vec3(0.0,0.0,0.0);
			}
#endif

#ifdef WAVING_AETHER_GRASS
	if ( mc_Entity.x == 4048.0 || mc_Entity.x == 702.0) {
			parm0 = 0.0041;
			parm1 = 0.0070;
			parm2 = 0.0044;
			parm3 = 0.0038;
			parm4 = 0.0063;
			parm5 = 0.0;
			ampl1 = vec3(3.0,1.6,3.0);
			ampl2 = vec3(0.0,0.0,0.0);
			}
#endif

#ifdef WAVING_TAINTED_GRASS_AND_PLANT
	if (mc_Entity.x == 2422) {
			parm0 = 0.0041;
			parm1 = 0.0070;
			parm2 = 0.0044;
			parm3 = 0.0038;
			parm4 = 0.0063;
			parm5 = 0.0;
			ampl1 = vec3(3.0,1.6,3.0);
			ampl2 = vec3(0.0,0.0,0.0);
			}
#endif	
	
#ifdef WAVING_FLOWERS
	if ((mc_Entity.x == 37 || mc_Entity.x == 38 || mc_Entity.x == 474.0 || mc_Entity.x == 474.1 || mc_Entity.x == 474.2 || mc_Entity.x == 474.3 || mc_Entity.x == 474.4 || mc_Entity.x == 474.5 || mc_Entity.x == 475.0 || mc_Entity.x == 475.1 || mc_Entity.x == 475.2 || mc_Entity.x == 475.3 || mc_Entity.x == 475.4 || mc_Entity.x == 475.5 || mc_Entity.x == 475.6 || mc_Entity.x == 475.7 || mc_Entity.x == 475.8 || mc_Entity.x == 459.0)) {
			parm0 = 0.0041;
			parm1 = 0.005;
			parm2 = 0.0044;
			parm3 = 0.0038;
			parm4 = 0.0240;
			parm5 = 0.0;
			ampl1 = vec3(0.8,0.0,0.8);
			ampl2 = vec3(0.4,0.0,0.4);
			}
#endif
	
#ifdef WAVING_WHEAT
	if ( mc_Entity.x == 59 || mc_Entity.x == 472.0) {
			parm0 = 0.0041;
			parm1 = 0.0070;
			parm2 = 0.0044;
			parm3 = 0.0240;
			parm4 = 0.0063;
			parm5 = 0.0;
			ampl1 = vec3(0.8,0.0,0.8);
			ampl2 = vec3(0.4,0.0,0.4);
			}
#endif

#ifdef WAVING_CARROTS_POTATOES
	if (mc_Entity.x == 141 || mc_Entity.x == 142) {
			parm0 = 0.0041;
			parm1 = 0.0070;
			parm2 = 0.0044;
			parm3 = 0.0240;
			parm4 = 0.0063;
			parm5 = 0.0;
			ampl1 = vec3(0.8,0.0,0.8);
			ampl2 = vec3(0.4,0.0,0.4);
			}
#endif

#ifdef WAVING_THAUMCRAFT_SAPLINGS_AND_FLOWERS
	if (mc_Entity.x == 2404) {
			parm0 = 0.0041;
			parm1 = 0.005;
			parm2 = 0.0044;
			parm3 = 0.0038;
			parm4 = 0.0240;
			parm5 = 0.0;
			ampl1 = vec3(0.8,0.0,0.8);
			ampl2 = vec3(0.4,0.0,0.4);
			}
#endif

#ifdef WAVING_SAPLINGS
	if (mc_Entity.x == 6 || mc_Entity.x == 4571.0 || mc_Entity.x == 4571.1 || mc_Entity.x == 4571.2 || mc_Entity.x == 4571.3 || mc_Entity.x == 4571.4 || mc_Entity.x == 4571.5 || mc_Entity.x == 4571.6 || mc_Entity.x == 4571.7 || mc_Entity.x == 4571.8) {
			parm0 = 0.0041;
			parm1 = 0.005;
			parm2 = 0.0044;
			parm3 = 0.0038;
			parm4 = 0.0240;
			parm5 = 0.0;
			ampl1 = vec3(0.8,0.0,0.8);
			ampl2 = vec3(0.4,0.0,0.4);
			}
#endif	
	
#ifdef WAVING_FIRE
		if ( mc_Entity.x == 51) {
			parm0 = 0.0105;
			parm1 = 0.0096;
			parm2 = 0.0087;
			parm3 = 0.0063;
			parm4 = 0.0097;
			parm5 = 0.0156;
			ampl1 = vec3(1.2,0.4,1.2);
			ampl2 = vec3(0.8,0.8,0.8);
		}				
#endif
}

float movemult = 0.0;

#ifdef WAVING_LEAVES
	if ( mc_Entity.x == 18.0 || mc_Entity.x == 161 || mc_Entity.x == 218.0 || mc_Entity.x == 218.1 || mc_Entity.x == 218.2 || mc_Entity.x == 218.3 || mc_Entity.x == 218.4 || mc_Entity.x == 218.5 || mc_Entity.x == 218.6 || mc_Entity.x == 218.7 || mc_Entity.x == 218.8 || mc_Entity.x == 218.9 || mc_Entity.x == 218.10 || mc_Entity.x == 218.11 || mc_Entity.x == 218.12 || mc_Entity.x == 218.13 || mc_Entity.x == 218.14 || mc_Entity.x == 218.15 || mc_Entity.x == 219.0 || mc_Entity.x == 219.1) {
		parm0 = 0.0040;
		parm1 = 0.0064;
		parm2 = 0.0043;
		parm3 = 0.0035;
		parm4 = 0.0037;
		parm5 = 0.0041;
		ampl1 = vec3(1.0,0.2,1.0);
		ampl2 = vec3(0.5,0.1,0.5);
	}
#endif

#ifdef WAVING_THAUMCRAFT_LEAVES
	if ( mc_Entity.x == 2406) {
			parm0 = 0.0040;
			parm1 = 0.0064;
			parm2 = 0.0043;
			parm3 = 0.0035;
			parm4 = 0.0037;
			parm5 = 0.0041;
			ampl1 = vec3(1.0,0.2,1.0);
			ampl2 = vec3(0.5,0.1,0.5);
			}
#endif	

#ifdef WAVING_ORANGE_PLANT
	if ( mc_Entity.x == 4045) {
			parm0 = 0.0040;
			parm1 = 0.0064;
			parm2 = 0.0043;
			parm3 = 0.0035;
			parm4 = 0.0037;
			parm5 = 0.0041;
			ampl1 = vec3(1.0,0.2,1.0);
			ampl2 = vec3(0.5,0.1,0.5);
			}		
#endif

#ifdef TALLPLANTS_and_TALLGRASS
	if ( mc_Entity.x == 175.0 && texcoord.t < 0.23) {
			parm0 = 0.0041;
			parm1 = 0.0070;
			parm2 = 0.0044;
			parm3 = 0.0240;
			parm4 = 0.0063;
			parm5 = 0.0;
			ampl1 = vec3(0.8,0.0,0.8);
			ampl2 = vec3(0.4,0.0,0.4);
			}
#endif

#ifdef WAVING_LAVA
	if ( mc_Entity.x == 10 || mc_Entity.x == 11 )	movemult = 0.25;
#endif
	
#ifdef WAVING_LILYPAD
	if ( mc_Entity.x == 111)  movemult = 1.0;
#endif

	position.xyz += calcWaterMove(worldpos.xyz) * movemult;
	position.xyz += calcMove(worldpos.xyz, parm0, parm1, parm2, parm3, parm4, parm5, ampl1, ampl2);
	
	if (mc_Entity.x == 18 
	|| mc_Entity.x == 106
	|| mc_Entity.x == 175 	
	|| mc_Entity.x == 31
	|| mc_Entity.x == 83 	
	|| mc_Entity.x == 37 
	|| mc_Entity.x == 38 
	|| mc_Entity.x == 59 
	|| mc_Entity.x == 30.0 
	|| mc_Entity.x == 115.0 
	|| mc_Entity.x == 32.0){
	translucent = 1.0;
	}
	
	/* re-rotate */
	
	/* projectify */
	gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
	
	color = gl_Color;
	
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	normal = normalize(gl_NormalMatrix * gl_Normal);
	tangent = vec3(0.0);
	binormal = vec3(0.0);

if (gl_Normal.x > 0.5) {
	tangent  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0, 0.0));
	binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	if (mc_Entity.x == 89 || mc_Entity.x == 124) color *= 1.75f;		
} else if (gl_Normal.x < -0.5) {
	tangent  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	if (mc_Entity.x == 89 || mc_Entity.x == 124) color *= 1.75f;			
}
	
mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
					  tangent.y, binormal.y, normal.y,
					  tangent.z, binormal.z, normal.z);


	viewVector = ( gl_ModelViewMatrix * gl_Vertex).xyz;
	
	viewVector = normalize(tbnMatrix * viewVector);
	dist = 0.0;
	dist = length(gbufferModelView *gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
}
