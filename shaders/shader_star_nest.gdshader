shader_type canvas_item;
render_mode unshaded;

uniform int iterations = 20;
uniform float formuparam = 1.00;

uniform int volsteps = 20;
uniform float stepsize = 0.1;

uniform float zoom = 0.800;
uniform float tile = 0.5;
uniform float speed = 0.001;

uniform float brightness = 0.002;
uniform float darkmatter = 0.100;
uniform float distfading = 0.650;
uniform float saturation = 0.750;

uniform vec2 iResolution = vec2(192, 192);
uniform vec2 iMouse = vec2(0,0);

float SCurve (float value) {

    if (value < 0.5)
    {
        return value * value * value * value * value * 16.0; 
    }
    
    value -= 1.0;
    
    return value * value * value * value * value * 16.0 + 1.0;
}

void fragment()
{
	//get coords and direction
	vec2 uv=FRAGCOORD.xy/iResolution.xy-.5;
	uv.y*=iResolution.y/iResolution.x;
	vec3 dir=vec3(uv*zoom,1.);
	float time=TIME*speed+.25;

	//mouse rotation
	float a1=0.5+iMouse.x/iResolution.x*2.;
	float a2=0.8+iMouse.y/iResolution.y*2.;
	mat2 rot1=mat2(vec2(cos(a1),sin(a1)),vec2(-sin(a1),cos(a1)));
	mat2 rot2=mat2(vec2(cos(a2),sin(a2)),vec2(-sin(a2),cos(a2)));
	dir.xy*=rot1;
	dir.xz*=rot2;
	vec3 from=vec3(1.0,0.5,0.5);
	from-=vec3(0.0,time,0.0);
	from.xz*=rot1;
	from.xy*=rot2;
	
	//volumetric rendering
	float s=0.1,fade=1.;
	vec3 v=vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*0.5;
		p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) { 
			p=abs(p)/dot(p,p)-formuparam; // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a = pow(a, 2.3); // add contrast
		if (r>6) fade*=1.-dm; // dark matter, don't render near
		//v+=vec3(dm,dm*.5,0.);
		v+=fade;
		v+=vec3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;
	}
    
	v=mix(vec3(length(v)),v,saturation); //color adjust
    
    vec4 C = vec4(v*.01,1.);
    
     	C.r = pow(C.r, 0.35); 
 	 	C.g = pow(C.g, 0.36); 
 	 	C.b = pow(C.b, 0.38); 
 	
    vec4 L = C;   	
    
    COLOR.r = mix(L.r, SCurve(C.r), 0.7); 
    COLOR.g = mix(L.g, SCurve(C.g), 1.0); 
    COLOR.b = mix(L.b, SCurve(C.b), 0.2);     	
	
}