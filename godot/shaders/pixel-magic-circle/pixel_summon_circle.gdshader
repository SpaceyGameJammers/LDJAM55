shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
,depth_draw_alpha_prepass
;
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
uniform sampler2D texture_1;
const float texture_1_size = 512.0;
vec2 get_from_tileset(float count, float seed, vec2 uv) {
	return clamp((uv+floor(rand2(vec2(seed))*count))/count, vec2(0.0), vec2(1.0));
}
vec2 custom_uv_transform(vec2 uv, vec2 cst_scale, float rnd_rotate, float rnd_scale, vec2 seed) {
	seed = rand2(seed);
	uv -= vec2(0.5);
	float angle = (seed.x * 2.0 - 1.0) * rnd_rotate;
	float ca = cos(angle);
	float sa = sin(angle);
	uv = vec2(ca*uv.x+sa*uv.y, -sa*uv.x+ca*uv.y);
	uv *= (seed.y-0.5)*2.0*rnd_scale+1.0;
	uv /= cst_scale;
	uv += vec2(0.5);
	return uv;
}
vec2 rotate(vec2 uv, float rotate) {
 	vec2 rv;
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	return rv;	
}
vec2 scale(vec2 uv, vec2 center, vec2 scale) {
	uv -= center;
	uv /= scale;
	uv += center;
	return uv;
}
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
float value_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float p00 = rand(mod(o, size));
	float p01 = rand(mod(o + vec2(0.0, 1.0), size));
	float p10 = rand(mod(o + vec2(1.0, 0.0), size));
	float p11 = rand(mod(o + vec2(1.0, 1.0), size));
	p00 = sin(p00 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p01 = sin(p01 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p10 = sin(p10 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p11 = sin(p11 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	vec2 t =  f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return mix(mix(p00, p10, t.x), mix(p01, p11, t.x), t.y);
}
float fbm_2d_value(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = value_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float perlin_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float a00 = rand(mod(o, size)) * 6.28318530718 + offset * 6.28318530718;
	float a01 = rand(mod(o + vec2(0.0, 1.0), size)) * 6.28318530718 + offset * 6.28318530718;
	float a10 = rand(mod(o + vec2(1.0, 0.0), size)) * 6.28318530718 + offset * 6.28318530718;
	float a11 = rand(mod(o + vec2(1.0, 1.0), size)) * 6.28318530718 + offset * 6.28318530718;
	vec2 v00 = vec2(cos(a00), sin(a00));
	vec2 v01 = vec2(cos(a01), sin(a01));
	vec2 v10 = vec2(cos(a10), sin(a10));
	vec2 v11 = vec2(cos(a11), sin(a11));
	float p00 = dot(v00, f);
	float p01 = dot(v01, f - vec2(0.0, 1.0));
	float p10 = dot(v10, f - vec2(1.0, 0.0));
	float p11 = dot(v11, f - vec2(1.0, 1.0));
	vec2 t =  f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return 0.5 + mix(mix(p00, p10, t.x), mix(p01, p11, t.x), t.y);
}
float fbm_2d_perlin(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = perlin_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float perlinabs_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	return abs(2.0*perlin_noise_2d(coord, size, offset, seed)-1.0);
}
float fbm_2d_perlinabs(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = perlinabs_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float fbm_2d_mod289(float x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
float fbm_2d_permute(float x) {
	return fbm_2d_mod289(((x * 34.0) + 1.0) * x);
}
vec2 fbm_2d_rgrad2(vec2 p, float rot, float seed) {
	float u = fbm_2d_permute(fbm_2d_permute(p.x) + p.y) * 0.0243902439 + rot; // Rotate by shift
	u = fract(u) * 6.28318530718; // 2*pi
	return vec2(cos(u), sin(u));
}
float simplex_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	coord *= 2.0; // needed for it to tile
	coord += rand2(vec2(seed, 1.0-seed)) + size;
	size *= 2.0; // needed for it to tile
	coord.y += 0.001;
	vec2 uv = vec2(coord.x + coord.y*0.5, coord.y);
	vec2 i0 = floor(uv);
	vec2 f0 = fract(uv);
	vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
	vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
	vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
	i1 = i0 + i1;
	vec2 i2 = i0 + vec2(1.0, 1.0);
	vec2 d0 = coord - p0;
	vec2 d1 = coord - p1;
	vec2 d2 = coord - p2;
	vec3 xw = mod(vec3(p0.x, p1.x, p2.x), size.x);
	vec3 yw = mod(vec3(p0.y, p1.y, p2.y), size.y);
	vec3 iuw = xw + 0.5 * yw;
	vec3 ivw = yw;
	vec2 g0 = fbm_2d_rgrad2(vec2(iuw.x, ivw.x), offset, seed);
	vec2 g1 = fbm_2d_rgrad2(vec2(iuw.y, ivw.y), offset, seed);
	vec2 g2 = fbm_2d_rgrad2(vec2(iuw.z, ivw.z), offset, seed);
	vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
	vec3 t = 0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2));
	t = max(t, vec3(0.0));
	vec3 t2 = t * t;
	vec3 t4 = t2 * t2;
	float n = dot(t4, w);
	return 0.5 + 5.5 * n;
}
float fbm_2d_simplex(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = simplex_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node =  0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718 * node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular2_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular2(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular2_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular3_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = abs((diff).x) + abs((diff).y);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular3(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular3_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular4_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = abs((diff).x) + abs((diff).y);
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular4(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular4_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular5_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.5 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = max(abs((diff).x), abs((diff).y));
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular5(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular5_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular6_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = max(abs((diff).x), abs((diff).y));
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular6(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular6_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
// MIT License Inigo Quilez - https://www.shadertoy.com/view/Xd23Dh
float voronoise_noise_2d( vec2 coord, vec2 size, float offset, float seed) {
	vec2 i = floor(coord) + rand2(vec2(seed, 1.0-seed)) + size;
	vec2 f = fract(coord);
	
	vec2 a = vec2(0.0);
	
	for( int y=-2; y<=2; y++ ) {
		for( int x=-2; x<=2; x++ ) {
			vec2  g = vec2( float(x), float(y) );
			vec3  o = rand3( mod(i + g, size) + vec2(seed) );
			o.xy += 0.25 * sin(offset * 6.28318530718 + 6.28318530718*o.xy);
			vec2  d = g - f + o.xy;
			float w = pow( 1.0-smoothstep(0.0, 1.414, length(d)), 1.0 );
			a += vec2(o.z*w,w);
		}
	}
	
	return a.x/a.y;
}
float fbm_2d_voronoise(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = voronoise_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float shape_circle(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float distance = length(uv);
	return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}
float shape_polygon(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y)+3.14159265359;
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y);
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_curved_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
	float slice = 6.28318530718/sides;
	return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}
float shape_rays(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
	float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
	return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}
const vec4 p_o83131_albedo_color = vec4(0.919965982, 0.633208990, 0.163686007, 1.000000000);
const float p_o83131_metallic = 1.000000000;
const float p_o83131_roughness = 0.160000000;
const float p_o83131_emission_energy = 1.000000000;
const float p_o83131_normal = 1.000000000;
const float p_o83131_ao = 0.000000000;
const float p_o83131_depth_scale = 0.500000000;
float o83131_input_depth_tex(vec2 uv, float _seed_variation_) {
return 0.0;
}
const float p_o152361_cx = 0.000000000;
const float p_o152361_cy = 0.000000000;
const float p_o152361_scale_x = 0.500000000;
const float p_o152361_scale_y = 0.500000000;
const float p_o152359_x = 64.000000000;
const float p_o152359_y = 64.000000000;
const float p_o152359_c = 12.000000000;
const float p_o152359_d = 0.000000000;
const float p_o152345_gradient_0_pos = 0.000000000;
const vec4 p_o152345_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 0.000000000);
const float p_o152345_gradient_1_pos = 0.752928994;
const vec4 p_o152345_gradient_1_col = vec4(1.000000000, 0.859375000, 0.997802734, 1.000000000);
vec4 o152345_gradient_gradient_fct(float x) {
  if (x < p_o152345_gradient_0_pos) {
    return p_o152345_gradient_0_col;
  } else if (x < p_o152345_gradient_1_pos) {
    return mix(p_o152345_gradient_0_col, p_o152345_gradient_1_col, ((x-p_o152345_gradient_0_pos)/(p_o152345_gradient_1_pos-p_o152345_gradient_0_pos)));
  }
  return p_o152345_gradient_1_col;
}
const float p_o152360_default_in1 = 0.000000000;
const float p_o152360_default_in2 = 0.160000000;
const float p_o83135_default_in1 = 0.000000000;
const float p_o83135_default_in2 = 0.000000000;
const float p_o83581_default_in1 = 0.000000000;
const float p_o83581_default_in2 = 0.000000000;
const float p_o83495_cx = 0.000000000;
const float p_o83495_cy = 0.000000000;
const float seed_o83496 = 122918.000000000;
const float p_o83496_count = 35.000000000;
const float p_o83496_rings = 1.000000000;
const float p_o83496_scale_x = 0.038000000;
const float p_o83496_scale_y = 0.038000000;
const float p_o83496_radius = 0.330000000;
const float p_o83496_spiral = 0.000000000;
const float p_o83496_i_rotate = 1.000000000;
const float p_o83496_i_scale = 0.000000000;
const float p_o83496_rotate = 0.000000000;
const float p_o83496_scale = 0.000000000;
const float p_o83496_value = 0.000000000;
const float p_o83579_value = 0.890000000;
const float p_o83579_width = 0.100000001;
float o83496_input_in(vec2 uv, float _seed_variation_) {
vec4 o83523_0 = textureLod(texture_1, (uv), 0.0);
vec3 o83579_0_false = clamp((o83523_0.rgb-vec3(p_o83579_value))/max(0.0001, p_o83579_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o83579_0_true = vec3(1.0)-o83579_0_false;vec4 o83579_0_1_rgba = vec4(o83579_0_false, o83523_0.a);
return (dot((o83579_0_1_rgba).rgb, vec3(1.0))/3.0);
}
float o83496_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o83496(vec2 uv, int count, int rings, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	seed = rand2(seed);
	for (int i = 0; i < count; ++i) {
		float a = -1.57079632679+6.28318530718*float(i)*p_o83496_rings/float(count);
		float rings_distance = ceil(float(i+1)*float(rings)/float(count))/float(rings);
		float spiral_distance = float(i+1)/float(count);
		vec2 pos = p_o83496_radius*mix(rings_distance, spiral_distance, p_o83496_spiral)*vec2(cos(a), sin(a));
		float mask = o83496_input_mask(fract(pos-vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = uv-0.5-pos;
			rc1 = rand3(seed);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o83496_rotate * 0.01745329251 + (a+1.57079632679) * p_o83496_i_rotate;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv /= mix(1.0, float(i+1)/float(count+1), p_o83496_i_scale);
			pv /= vec2(p_o83496_scale_x, p_o83496_scale_y);
			pv *= (seed.y-0.5)*2.0*p_o83496_scale+1.0;
			pv += vec2(0.5);
			seed = rand2(seed);
			if (pv != clamp(pv, vec2(0.0), vec2(1.0))) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o83496_input_in(pv, false ? seed.x : 0.0)*mask*(1.0-p_o83496_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
const float p_o83580_cx = 0.000000000;
const float p_o83580_cy = 0.000000000;
const float p_o83580_scale_x = 1.115000000;
const float p_o83580_scale_y = 1.115000000;
const float p_o83503_cx = 0.000000000;
const float p_o83503_cy = 0.000000000;
const float p_o83134_default_in1 = 0.000000000;
const float p_o83134_default_in2 = 0.000000000;
const float p_o83166_amount = 0.100000000;
const float p_o83166_eps = 0.100000000;
const float p_o83164_cx = 0.000000000;
const float p_o83164_cy = 0.000000000;
const float p_o83137_default_in1 = 0.000000000;
const float p_o83137_default_in2 = 0.330000000;
const float seed_o83165 = -7561.000000000;
const float p_o83165_scale_x = 3.000000000;
const float p_o83165_scale_y = 3.000000000;
const float p_o83165_folds = 0.000000000;
const float p_o83165_iterations = 2.000000000;
const float p_o83165_persistence = 0.500000000;
const float p_o83165_offset = 0.000000000;
float o83166_input_d(vec2 uv, float _seed_variation_) {
vec2 o83164_0_c = vec2(0.5+p_o83164_cx, 0.5+p_o83164_cy);float o83165_0_1_f = fbm_2d_value((rotate((uv)-o83164_0_c, (abs(cos(elapsed_time*0.2))*360.0)*0.01745329251)+o83164_0_c), vec2(p_o83165_scale_x, p_o83165_scale_y), int(p_o83165_folds), int(p_o83165_iterations), p_o83165_persistence, p_o83165_offset, (seed_o83165+fract(_seed_variation_)));
float o83137_0_clamp_false = o83165_0_1_f*p_o83137_default_in2;
float o83137_0_clamp_true = clamp(o83137_0_clamp_false, 0.0, 1.0);
float o83137_0_2_f = o83137_0_clamp_false;
vec4 o83164_0_1_rgba = vec4(vec3(o83137_0_2_f), 1.0);
return (dot((o83164_0_1_rgba).rgb, vec3(1.0))/3.0);
}
vec2 o83166_slope(vec2 uv, float epsilon, float _seed_variation_) {
	return vec2(o83166_input_d(fract(uv+vec2(epsilon, 0.0)), _seed_variation_)-o83166_input_d(fract(uv-vec2(epsilon, 0.0)), _seed_variation_), o83166_input_d(fract(uv+vec2(0.0, epsilon)), _seed_variation_)-o83166_input_d(fract(uv-vec2(0.0, epsilon)), _seed_variation_));
}const float p_o83143_default_in1 = 0.000000000;
const float p_o83143_default_in2 = 0.000000000;
const float p_o83141_value = 0.250000000;
const float p_o83141_width = 0.500000000;
const float p_o83141_contrast = 1.000000000;
const float p_o83140_sides = 5.000000000;
const float p_o83140_radius = 0.120000000;
const float p_o83142_value = 0.250000000;
const float p_o83142_width = 0.500000000;
const float p_o83142_contrast = 1.000000000;
const float p_o83139_cx = 0.000000000;
const float p_o83139_cy = 0.000000000;
const float p_o83139_rotate = 180.000000000;
const float p_o83144_sides = 5.000000000;
const float p_o83144_radius = 0.120000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec2 o152359_0_uv = floor(((scale((uv), vec2(0.5+p_o152361_cx, 0.5+p_o152361_cy), vec2(p_o152361_scale_x, p_o152361_scale_y)))*vec2(p_o152359_x, p_o152359_y)))+vec2(0.5);
vec3 o152359_0_dither = fract(vec3(dot(vec2(171.0, 231.0), o152359_0_uv))/vec3(103.0, 71.0, 97.0));
vec2 o83495_0_c = vec2(0.5+p_o83495_cx, 0.5+p_o83495_cy);vec3 o83496_0_instance_uv = vec3(0.0);
vec4 o83496_0_rch = splatter_o83496((rotate((o152359_0_uv/vec2(p_o152359_x, p_o152359_y))-o83495_0_c, (elapsed_time * 10.0)*0.01745329251)+o83495_0_c), int(p_o83496_count), int(p_o83496_rings), o83496_0_instance_uv, vec2(float((seed_o83496+fract(_seed_variation_)))), _seed_variation_);float o83496_0_1_f = o83496_0_rch.a;
vec4 o83495_0_1_rgba = vec4(vec3(o83496_0_1_f), 1.0);
vec2 o83503_0_c = vec2(0.5+p_o83503_cx, 0.5+p_o83503_cy);vec3 o83496_2_instance_uv = vec3(0.0);
vec4 o83496_2_rch = splatter_o83496((rotate((scale((o152359_0_uv/vec2(p_o152359_x, p_o152359_y)), vec2(0.5+p_o83580_cx, 0.5+p_o83580_cy), vec2(p_o83580_scale_x, p_o83580_scale_y)))-o83503_0_c, (-(elapsed_time * 10.0))*0.01745329251)+o83503_0_c), int(p_o83496_count), int(p_o83496_rings), o83496_2_instance_uv, vec2(float((seed_o83496+fract(_seed_variation_)))), _seed_variation_);float o83496_0_3_f = o83496_2_rch.a;
vec4 o83503_0_1_rgba = vec4(vec3(o83496_0_3_f), 1.0);
vec4 o83580_0_1_rgba = o83503_0_1_rgba;
float o83581_0_clamp_false = max((dot((o83495_0_1_rgba).rgb, vec3(1.0))/3.0),(dot((o83580_0_1_rgba).rgb, vec3(1.0))/3.0));
float o83581_0_clamp_true = clamp(o83581_0_clamp_false, 0.0, 1.0);
float o83581_0_1_f = o83581_0_clamp_false;
vec2 o83166_0_slope = o83166_slope((o152359_0_uv/vec2(p_o152359_x, p_o152359_y)), p_o83166_eps, _seed_variation_);
vec2 o83166_0_warp = o83166_0_slope;float o83140_0_1_f = shape_polygon(((o152359_0_uv/vec2(p_o152359_x, p_o152359_y))+p_o83166_amount*o83166_0_warp), p_o83140_sides, p_o83140_radius*1.0, (mix(0.55,0.72,abs(sin(elapsed_time * 2.0))))*1.0);
float o83141_0_step = clamp((o83140_0_1_f - (p_o83141_value))/max(0.0001, p_o83141_width)+0.5, 0.0, 1.0);
float o83141_0_false = clamp((min(o83141_0_step, 1.0-o83141_0_step) * 2.0) / (1.0 - p_o83141_contrast), 0.0, 1.0);
float o83141_0_true = 1.0-o83141_0_false;float o83141_0_1_f = o83141_0_false;
vec2 o83139_0_c = vec2(0.5+p_o83139_cx, 0.5+p_o83139_cy);float o83144_0_1_f = shape_star((rotate(((o152359_0_uv/vec2(p_o152359_x, p_o152359_y))+p_o83166_amount*o83166_0_warp)-o83139_0_c, p_o83139_rotate*0.01745329251)+o83139_0_c), p_o83144_sides, p_o83144_radius*1.0, (mix(0.55,0.72,abs(sin(elapsed_time * 2.0))))*1.0);
vec4 o83139_0_1_rgba = vec4(vec3(o83144_0_1_f), 1.0);
float o83142_0_step = clamp(((dot((o83139_0_1_rgba).rgb, vec3(1.0))/3.0) - (p_o83142_value))/max(0.0001, p_o83142_width)+0.5, 0.0, 1.0);
float o83142_0_false = clamp((min(o83142_0_step, 1.0-o83142_0_step) * 2.0) / (1.0 - p_o83142_contrast), 0.0, 1.0);
float o83142_0_true = 1.0-o83142_0_false;float o83142_0_1_f = o83142_0_false;
float o83143_0_clamp_false = max(o83141_0_1_f,o83142_0_1_f);
float o83143_0_clamp_true = clamp(o83143_0_clamp_false, 0.0, 1.0);
float o83143_0_1_f = o83143_0_clamp_false;
vec4 o83166_0_1_rgba = vec4(vec3(o83143_0_1_f), 1.0);
float o83134_0_clamp_false = (dot((o83166_0_1_rgba).rgb, vec3(1.0))/3.0)+p_o83134_default_in2;
float o83134_0_clamp_true = clamp(o83134_0_clamp_false, 0.0, 1.0);
float o83134_0_2_f = o83134_0_clamp_true;
float o83135_0_clamp_false = o83581_0_1_f+o83134_0_2_f;
float o83135_0_clamp_true = clamp(o83135_0_clamp_false, 0.0, 1.0);
float o83135_0_1_f = o83135_0_clamp_true;
float o152360_0_clamp_false = floor(o83135_0_1_f/p_o152360_default_in2)*p_o152360_default_in2;
float o152360_0_clamp_true = clamp(o152360_0_clamp_false, 0.0, 1.0);
float o152360_0_2_f = o152360_0_clamp_false;
vec4 o152345_0_1_rgba = o152345_gradient_gradient_fct(o152360_0_2_f);
vec3 o152359_0_1_rgb = floor(((o152345_0_1_rgba).rgb)*p_o152359_c+p_o152359_d*(o152359_0_dither-vec3(0.5)))/p_o152359_c;
vec4 o152361_0_1_rgba = vec4(o152359_0_1_rgb, 1.0);

	vec3 albedo_tex = ((o152361_0_1_rgba).rgb).rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o83131_albedo_color.rgb;
	METALLIC = 1.0*p_o83131_metallic;
	ROUGHNESS = 1.0*p_o83131_roughness;
	NORMAL = vec3(0.5);
	EMISSION = vec3(0.0)*p_o83131_emission_energy;
	ALPHA = (dot((o152361_0_1_rgba).rgb, vec3(1.0))/3.0);

}



