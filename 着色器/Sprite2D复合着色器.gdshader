shader_type canvas_item;

uniform sampler2D sprite_texture : source_color, filter_nearest;
uniform float time_offset : hint_range(0.0, 100.0, 0.01) = 0.0;

group_uniforms LightingControl;
uniform bool enable_lighting = false;

group_uniforms WalkWaveEffect;
uniform float wave_strength : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float wave_frequency : hint_range(0.0, 20.0, 0.1) = 10.0;

group_uniforms OutlinerEffect;
uniform vec4 outline_color : source_color = vec4(1.0);
uniform int outline_type : hint_range(0, 2) = 2;
uniform float outline_thickness : hint_range(0.0, 5.0, 0.1) = 0.0;

group_uniforms JellyEffect;
uniform float jelly_frequency : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float jelly_amplitude : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform bool affect_below_ground = false;
uniform bool inverse_phase = true;

group_uniforms DistortionEffect;
uniform sampler2D noise_texture : source_color, filter_linear;
uniform float distortion_progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float distortion_strength : hint_range(0.0, 0.1, 0.001) = 0.02;
uniform float distortion_speed_x : hint_range(-5.0, 5.0, 0.1) = 1.0;
uniform float distortion_speed_y : hint_range(-5.0, 5.0, 0.1) = 0.5;
uniform float distortion_time_weight : hint_range(0.0, 1.0, 0.01) = 1.0;

group_uniforms DissolveEffect;
uniform sampler2D dissolve_noise : source_color, filter_linear;
uniform float dissolve_progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform vec4 dissolve_edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float dissolve_edge_width : hint_range(0.0, 0.2, 0.001) = 0.05;

group_uniforms ModifierEffect;
uniform vec4 modifier_color : source_color = vec4(1.0);
uniform bool enable_modifier = false;

group_uniforms ShakeEffect;
uniform float shake_amplitude : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float shake_frequency : hint_range(0.0, 20.0, 0.1) = 10.0;
uniform float shake_x_weight : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float shake_y_weight : hint_range(0.0, 1.0, 0.1) = 1.0;

// 描边函数
vec4 apply_outline(sampler2D tex, vec2 uv, vec4 original_color, vec2 pixel_size) {
	const vec2[8] DIRS = {vec2(1,0), vec2(0,1), vec2(-1,0), vec2(0,-1), vec2(1,1), vec2(-1,1), vec2(-1,-1), vec2(1,-1)};
	
	if (original_color.a > 0.01) {
		return original_color;
	}
	
	float outline_alpha = 0.0;
	bool has_valid_neighbor = false;
	
	for (int i = 0; i < 4 * outline_type; i++) {
		vec2 sample_uv = uv + DIRS[i] * pixel_size * outline_thickness;
		
		if (sample_uv.x >= 0.0 && sample_uv.x <= 1.0 && sample_uv.y >= 0.0 && sample_uv.y <= 1.0) {
			float neighbor_alpha = texture(tex, sample_uv).a;
			if (neighbor_alpha > 0.01) {
				outline_alpha += neighbor_alpha;
				has_valid_neighbor = true;
			}
		}
	}
	
	if (has_valid_neighbor && outline_alpha > 0.0) {
		return vec4(outline_color.rgb, outline_color.a);
	}
	
	return original_color;
}

// 扭曲效果(UV修改)
vec2 apply_distortion_uv(vec2 uv) {
	float t = (TIME + time_offset) * distortion_time_weight;
	vec2 time_offset_uv = vec2(distortion_speed_x * t, distortion_speed_y * t);
	vec4 noise = texture(noise_texture, uv + time_offset_uv);
	vec2 distortion_offset = (noise.xy - 0.5) * distortion_strength * distortion_progress;
	return uv + distortion_offset;
}

// 消融效果
vec4 apply_dissolve_effect(vec4 color, vec2 uv) {
	float dissolve_noise_val = texture(dissolve_noise, uv).r;
	
	if (dissolve_progress > dissolve_noise_val) {
		return vec4(color.rgb, 0.0);
	}
	
	float edge_distance = dissolve_progress - dissolve_noise_val;
	
	if (abs(edge_distance) < dissolve_edge_width) {
		float edge_factor = 1.0 - (abs(edge_distance) / dissolve_edge_width);
		vec3 final_color = mix(color.rgb, dissolve_edge_color.rgb, edge_factor);
		return vec4(final_color, color.a);
	}
	
	return color;
}

void vertex() {
	// 波浪效果
	float t = TIME + time_offset;
	float phase = VERTEX.x > 0.0 ? 0.0 : PI;
	VERTEX.x += 10.0 * sin(wave_frequency * t + phase) * wave_strength;
	VERTEX.y += 10.0 * clamp(sin(wave_frequency * t + phase), 0.0, 1.0) * wave_strength;
	
	// 果冻效果
	float x_scale = 1.0 + jelly_amplitude * sin(jelly_frequency * t);
	float y_scale = 1.0 + jelly_amplitude * sin(jelly_frequency * t + (inverse_phase ? PI : 0.0));
	VERTEX.x *= x_scale;
	if (affect_below_ground || VERTEX.y <= 0.0) VERTEX.y *= y_scale;
	
	// 振动效果
	float shake_x = sin(shake_frequency * t + 10.0) * cos(shake_frequency * t * 1.3 + 5.0) * shake_amplitude * shake_x_weight;
	float shake_y = cos(shake_frequency * t + 20.0) * sin(shake_frequency * t * 1.7 + 15.0) * shake_amplitude * shake_y_weight;
	VERTEX.x += shake_x * 10.0;
	VERTEX.y += shake_y * 10.0;
}

void fragment() {
	vec2 distorted_uv = apply_distortion_uv(UV);
	vec4 sprite_color = texture(TEXTURE, distorted_uv);
	vec4 final_color = apply_outline(TEXTURE, distorted_uv, sprite_color, TEXTURE_PIXEL_SIZE);
	
	// 颜色修改器
	if (enable_modifier) {
		final_color.rgb *= modifier_color.rgb;
	}
	
	// 消融效果
	final_color = apply_dissolve_effect(final_color, UV);
	
	COLOR = final_color;
	
	// 光照控制
	if (!enable_lighting) {
		COLOR.rgb = final_color.rgb; // 2D中不需要特殊处理自发光
	}
}