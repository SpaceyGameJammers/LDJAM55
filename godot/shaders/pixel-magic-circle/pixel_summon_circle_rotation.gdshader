shader_type canvas_item;

render_mode unshaded, blend_sub;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
uniform float speed = 1.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME * speed;
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
const float p_o8572_cx = 0.000000000;
const float p_o8572_cy = 0.000000000;
const float p_o8572_scale_x = 0.500000000;
const float p_o8572_scale_y = 0.500000000;
const float p_o8570_x = 64.000000000;
const float p_o8570_y = 64.000000000;
const float p_o8570_c = 12.000000000;
const float p_o8570_d = 0.000000000;
const float p_o8557_gradient_0_pos = 0.000000000;
const vec4 p_o8557_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 0.000000000);
const float p_o8557_gradient_1_pos = 0.321774015;
const vec4 p_o8557_gradient_1_col = vec4(0.000000000, 0.906250000, 1.000000000, 1.000000000);
vec4 o8557_gradient_gradient_fct(float x) {
  if (x < p_o8557_gradient_0_pos) {
    return p_o8557_gradient_0_col;
  } else if (x < p_o8557_gradient_1_pos) {
    return mix(p_o8557_gradient_0_col, p_o8557_gradient_1_col, ((x-p_o8557_gradient_0_pos)/(p_o8557_gradient_1_pos-p_o8557_gradient_0_pos)));
  }
  return p_o8557_gradient_1_col;
}
const float p_o8571_default_in1 = 0.000000000;
const float p_o8571_default_in2 = 0.160000000;
const float p_o8055_default_in1 = 0.000000000;
const float p_o8055_default_in2 = 0.000000000;
const float p_o8501_default_in1 = 0.000000000;
const float p_o8501_default_in2 = 0.000000000;
const float p_o8500_cx = 0.000000000;
const float p_o8500_cy = 0.000000000;
const float p_o8500_scale_x = 1.395000000;
const float p_o8500_scale_y = 1.360000000;
const float p_o8423_cx = 0.000000000;
const float p_o8423_cy = 0.000000000;
const float seed_o8416 = 122918.000000000;
const float p_o8416_count = 13.000000000;
const float p_o8416_rings = 1.000000000;
const float p_o8416_scale_x = 0.100000000;
const float p_o8416_scale_y = 0.100000000;
const float p_o8416_radius = 0.330000000;
const float p_o8416_spiral = 0.000000000;
const float p_o8416_i_rotate = 1.000000000;
const float p_o8416_i_scale = 0.000000000;
const float p_o8416_rotate = 0.000000000;
const float p_o8416_scale = 0.000000000;
const float p_o8416_value = 0.000000000;
const float p_o8499_value = 0.890000000;
const float p_o8499_width = 0.100000000;
float o8416_input_in(vec2 uv, float _seed_variation_) {
vec4 o8443_0 = textureLod(texture_1, (uv), 0.0);
vec3 o8499_0_false = clamp((o8443_0.rgb-vec3(p_o8499_value))/max(0.0001, p_o8499_width)+vec3(0.5), vec3(0.0), vec3(1.0));
vec3 o8499_0_true = vec3(1.0)-o8499_0_false;vec4 o8499_0_1_rgba = vec4(o8499_0_false, o8443_0.a);
return (dot((o8499_0_1_rgba).rgb, vec3(1.0))/3.0);
}
float o8416_input_mask(vec2 uv, float _seed_variation_) {
return 1.0;
}
vec4 splatter_o8416(vec2 uv, int count, int rings, inout vec3 instance_uv, vec2 seed, float _seed_variation_) {
	float c = 0.0;
	vec3 rc = vec3(0.0);
	vec3 rc1;
	seed = rand2(seed);
	for (int i = 0; i < count; ++i) {
		float a = -1.57079632679+6.28318530718*float(i)*p_o8416_rings/float(count);
		float rings_distance = ceil(float(i+1)*float(rings)/float(count))/float(rings);
		float spiral_distance = float(i+1)/float(count);
		vec2 pos = p_o8416_radius*mix(rings_distance, spiral_distance, p_o8416_spiral)*vec2(cos(a), sin(a));
		float mask = o8416_input_mask(fract(pos-vec2(0.5)), _seed_variation_);
		if (mask > 0.01) {
			vec2 pv = uv-0.5-pos;
			rc1 = rand3(seed);
			seed = rand2(seed);
			float angle = (seed.x * 2.0 - 1.0) * p_o8416_rotate * 0.01745329251 + (a+1.57079632679) * p_o8416_i_rotate;
			float ca = cos(angle);
			float sa = sin(angle);
			pv = vec2(ca*pv.x+sa*pv.y, -sa*pv.x+ca*pv.y);
			pv /= mix(1.0, float(i+1)/float(count+1), p_o8416_i_scale);
			pv /= vec2(p_o8416_scale_x, p_o8416_scale_y);
			pv *= (seed.y-0.5)*2.0*p_o8416_scale+1.0;
			pv += vec2(0.5);
			seed = rand2(seed);
			if (pv != clamp(pv, vec2(0.0), vec2(1.0))) {
				continue;
			}
			vec2 full_uv = pv;
			pv = get_from_tileset( 1.0, seed.x, pv);
			float c1 = o8416_input_in(pv, false ? seed.x : 0.0)*mask*(1.0-p_o8416_value*seed.x);
			c = max(c, c1);
			rc = mix(rc, rc1, step(c, c1));
			instance_uv = mix(instance_uv, vec3(full_uv, seed.x), step(c, c1));
		}
	}
	return vec4(rc, c);
}
const float p_o8415_cx = 0.000000000;
const float p_o8415_cy = 0.000000000;
const float p_o8054_default_in1 = 0.000000000;
const float p_o8054_default_in2 = 0.000000000;
const float p_o8086_amount = 0.100000000;
const float p_o8086_eps = 0.100000000;
const float p_o8084_cx = 0.000000000;
const float p_o8084_cy = 0.000000000;
const float p_o8057_default_in1 = 0.000000000;
const float p_o8057_default_in2 = 0.330000000;
const float seed_o8085 = -7561.000000000;
const float p_o8085_scale_x = 3.000000000;
const float p_o8085_scale_y = 3.000000000;
const float p_o8085_folds = 0.000000000;
const float p_o8085_iterations = 2.000000000;
const float p_o8085_persistence = 0.500000000;
const float p_o8085_offset = 0.000000000;
float o8086_input_d(vec2 uv, float _seed_variation_) {
vec2 o8084_0_c = vec2(0.5+p_o8084_cx, 0.5+p_o8084_cy);float o8085_0_1_f = fbm_2d_value((rotate((uv)-o8084_0_c, (abs(cos(elapsed_time*0.2))*360.0)*0.01745329251)+o8084_0_c), vec2(p_o8085_scale_x, p_o8085_scale_y), int(p_o8085_folds), int(p_o8085_iterations), p_o8085_persistence, p_o8085_offset, (seed_o8085+fract(_seed_variation_)));
float o8057_0_clamp_false = o8085_0_1_f*p_o8057_default_in2;
float o8057_0_clamp_true = clamp(o8057_0_clamp_false, 0.0, 1.0);
float o8057_0_2_f = o8057_0_clamp_false;
vec4 o8084_0_1_rgba = vec4(vec3(o8057_0_2_f), 1.0);
return (dot((o8084_0_1_rgba).rgb, vec3(1.0))/3.0);
}
vec2 o8086_slope(vec2 uv, float epsilon, float _seed_variation_) {
	return vec2(o8086_input_d(fract(uv+vec2(epsilon, 0.0)), _seed_variation_)-o8086_input_d(fract(uv-vec2(epsilon, 0.0)), _seed_variation_), o8086_input_d(fract(uv+vec2(0.0, epsilon)), _seed_variation_)-o8086_input_d(fract(uv-vec2(0.0, epsilon)), _seed_variation_));
}const float p_o8063_default_in1 = 0.000000000;
const float p_o8063_default_in2 = 0.000000000;
const float p_o8061_value = 0.250000000;
const float p_o8061_width = 0.500000000;
const float p_o8061_contrast = 1.000000000;
const float p_o8060_sides = 5.000000000;
const float p_o8060_radius = 0.120000000;
const float p_o8062_value = 0.250000000;
const float p_o8062_width = 0.500000000;
const float p_o8062_contrast = 1.000000000;
const float p_o8059_cx = 0.000000000;
const float p_o8059_cy = 0.000000000;
const float p_o8059_rotate = 180.000000000;
const float p_o8064_sides = 5.000000000;
const float p_o8064_radius = 0.120000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec2 o8570_0_uv = floor(((scale((uv), vec2(0.5+p_o8572_cx, 0.5+p_o8572_cy), vec2(p_o8572_scale_x, p_o8572_scale_y)))*vec2(p_o8570_x, p_o8570_y)))+vec2(0.5);
vec3 o8570_0_dither = fract(vec3(dot(vec2(171.0, 231.0), o8570_0_uv))/vec3(103.0, 71.0, 97.0));
vec2 o8423_0_c = vec2(0.5+p_o8423_cx, 0.5+p_o8423_cy);vec3 o8416_0_instance_uv = vec3(0.0);
vec4 o8416_0_rch = splatter_o8416((rotate((scale((o8570_0_uv/vec2(p_o8570_x, p_o8570_y)), vec2(0.5+p_o8500_cx, 0.5+p_o8500_cy), vec2(p_o8500_scale_x, p_o8500_scale_y)))-o8423_0_c, (elapsed_time*100.0)*0.01745329251)+o8423_0_c), int(p_o8416_count), int(p_o8416_rings), o8416_0_instance_uv, vec2(float((seed_o8416+fract(_seed_variation_)))), _seed_variation_);float o8416_0_1_f = o8416_0_rch.a;
vec4 o8423_0_1_rgba = vec4(vec3(o8416_0_1_f), 1.0);
vec4 o8500_0_1_rgba = o8423_0_1_rgba;
vec2 o8415_0_c = vec2(0.5+p_o8415_cx, 0.5+p_o8415_cy);vec3 o8416_2_instance_uv = vec3(0.0);
vec4 o8416_2_rch = splatter_o8416((rotate((o8570_0_uv/vec2(p_o8570_x, p_o8570_y))-o8415_0_c, (elapsed_time*-100.0)*0.01745329251)+o8415_0_c), int(p_o8416_count), int(p_o8416_rings), o8416_2_instance_uv, vec2(float((seed_o8416+fract(_seed_variation_)))), _seed_variation_);float o8416_0_3_f = o8416_2_rch.a;
vec4 o8415_0_1_rgba = vec4(vec3(o8416_0_3_f), 1.0);
float o8501_0_clamp_false = max((dot((o8500_0_1_rgba).rgb, vec3(1.0))/3.0),(dot((o8415_0_1_rgba).rgb, vec3(1.0))/3.0));
float o8501_0_clamp_true = clamp(o8501_0_clamp_false, 0.0, 1.0);
float o8501_0_1_f = o8501_0_clamp_false;
vec2 o8086_0_slope = o8086_slope((o8570_0_uv/vec2(p_o8570_x, p_o8570_y)), p_o8086_eps, _seed_variation_);
vec2 o8086_0_warp = o8086_0_slope;float o8060_0_1_f = shape_polygon(((o8570_0_uv/vec2(p_o8570_x, p_o8570_y))+p_o8086_amount*o8086_0_warp), p_o8060_sides, p_o8060_radius*1.0, (mix(0.55,0.72,abs(sin(elapsed_time * 2.0))))*1.0);
float o8061_0_step = clamp((o8060_0_1_f - (p_o8061_value))/max(0.0001, p_o8061_width)+0.5, 0.0, 1.0);
float o8061_0_false = clamp((min(o8061_0_step, 1.0-o8061_0_step) * 2.0) / (1.0 - p_o8061_contrast), 0.0, 1.0);
float o8061_0_true = 1.0-o8061_0_false;float o8061_0_1_f = o8061_0_false;
vec2 o8059_0_c = vec2(0.5+p_o8059_cx, 0.5+p_o8059_cy);float o8064_0_1_f = shape_star((rotate(((o8570_0_uv/vec2(p_o8570_x, p_o8570_y))+p_o8086_amount*o8086_0_warp)-o8059_0_c, p_o8059_rotate*0.01745329251)+o8059_0_c), p_o8064_sides, p_o8064_radius*1.0, (mix(0.55,0.72,abs(sin(elapsed_time * 2.0))))*1.0);
vec4 o8059_0_1_rgba = vec4(vec3(o8064_0_1_f), 1.0);
float o8062_0_step = clamp(((dot((o8059_0_1_rgba).rgb, vec3(1.0))/3.0) - (p_o8062_value))/max(0.0001, p_o8062_width)+0.5, 0.0, 1.0);
float o8062_0_false = clamp((min(o8062_0_step, 1.0-o8062_0_step) * 2.0) / (1.0 - p_o8062_contrast), 0.0, 1.0);
float o8062_0_true = 1.0-o8062_0_false;float o8062_0_1_f = o8062_0_false;
float o8063_0_clamp_false = max(o8061_0_1_f,o8062_0_1_f);
float o8063_0_clamp_true = clamp(o8063_0_clamp_false, 0.0, 1.0);
float o8063_0_1_f = o8063_0_clamp_false;
vec4 o8086_0_1_rgba = vec4(vec3(o8063_0_1_f), 1.0);
float o8054_0_clamp_false = (dot((o8086_0_1_rgba).rgb, vec3(1.0))/3.0)+p_o8054_default_in2;
float o8054_0_clamp_true = clamp(o8054_0_clamp_false, 0.0, 1.0);
float o8054_0_2_f = o8054_0_clamp_true;
float o8055_0_clamp_false = o8501_0_1_f+o8054_0_2_f;
float o8055_0_clamp_true = clamp(o8055_0_clamp_false, 0.0, 1.0);
float o8055_0_1_f = o8055_0_clamp_true;
float o8571_0_clamp_false = floor(o8055_0_1_f/p_o8571_default_in2)*p_o8571_default_in2;
float o8571_0_clamp_true = clamp(o8571_0_clamp_false, 0.0, 1.0);
float o8571_0_2_f = o8571_0_clamp_false;
vec4 o8557_0_1_rgba = o8557_gradient_gradient_fct(o8571_0_2_f);
vec3 o8570_0_1_rgb = floor(((o8557_0_1_rgba).rgb)*p_o8570_c+p_o8570_d*(o8570_0_dither-vec3(0.5)))/p_o8570_c;
vec4 o8572_0_1_rgba = vec4(o8570_0_1_rgb, 1.0);

	vec4 color_tex = o8572_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	COLOR = color_tex;

}



