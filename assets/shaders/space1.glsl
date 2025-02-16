// https://www.shadertoy.com/view/XlfGRj
// Star Nest by Pablo Roman Andrioli
// License: MIT

#version 330 core
#define iterations 20
#define formuparam 0.53 // .83, 0.53

#define volsteps 15
#define stepsize 0.5

//#define zoom   0.700
#define tile   0.9
#define speed  0.010

#define brightness 0.0008
#define darkmatter 0.800
#define distfading 0.330
#define saturation 0.650





uniform vec2 uResolution;
uniform float uTime;
uniform vec4 uMouse;
out vec4 fragColor;
// This is how much you are drifting around. Zero means it only moves when the mouse moves
uniform float uDrift;
uniform float uZoom = 0.7;


void main()
{
  vec2 uv = gl_FragCoord.xy / uResolution.xy;
  //uv = uv * 2.0 - 1.0;
  uv.x *= uResolution.x / uResolution.y;
  float time = uTime * (uDrift) * 5; //+ uMouse.x*0.01;
  //get coords and direction
  //vec2 uv=fragCoord.xy/uResolution.xy-.5;
  uv.y*=uResolution.y/uResolution.x;
  vec3 dir=vec3(uv*uZoom,1.);
  //float time=iTime*speed+.25;

  //mouse rotation
  float a1=.5+uMouse.x/uResolution.x*2.;
  float a2=.8+uMouse.y/uResolution.y*2.;
  mat2 rot1=mat2(cos(a1),sin(a1),-sin(a1),cos(a1));
  mat2 rot2=mat2(cos(a2),sin(a2),-sin(a2),cos(a2));
  dir.xz*=rot1;
  dir.xy*=rot2;
  vec3 from=vec3(1.,.5,0.5);
  from+=vec3(time*2.,time,-2.);
  from.xz*=rot1;
  from.xy*=rot2;

  //volumetric rendering
  float s=0.1,fade=0.8;
  vec3 v=vec3(0.);
  for (int r=0; r<volsteps; r++) {
    vec3 p=from+s*dir*.5;
    p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
    float pa,a=pa=0.;
    for (int i=0; i<iterations; i++) {
      p=abs(p)/dot(p,p)-formuparam; // the magic formula
      a+=abs(length(p)-pa); // absolute sum of average change
      pa=length(p);
    }
    float dm=max(0.,darkmatter-a*a*.001); //dark matter
    a*=a*a; // add contrast
    if (r>0) fade*=1.-dm; // dark matter, don't render near
                          //v+=vec3(dm,dm*.5,0.);
    v+=fade;
    v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
    fade*=distfading; // distance fading
    s+=stepsize;
  }
  v=mix(vec3(length(v)),v,saturation); //color adjust
  fragColor = vec4(v*.01,1.0);

}

