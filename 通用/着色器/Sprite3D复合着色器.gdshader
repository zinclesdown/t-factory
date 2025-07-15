shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D sprite_texture : source_color, filter_nearest;
uniform sampler2D raw_texture : hint_screen_texture;
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

// 用于进行描边操作
// 用于进行描边操作 - 修复版本
vec4 apply_outline(sampler2D tex, vec2 uv, vec4 original_color) {
	const vec2[8] DIRS = {vec2(1,0), vec2(0,1), vec2(-1,0), vec2(0,-1), vec2(1,1), vec2(-1,1), vec2(-1,-1), vec2(1,-1)};
	vec2 pixel_size = 1.0 / vec2(textureSize(tex, 0));
	
	// 如果当前像素已经有内容，不需要添加描边
	if (original_color.a > 0.01) {
		return original_color;
	}
	
	float outline_alpha = 0.0;
	bool has_valid_neighbor = false;
	
	for (int i = 0; i < 4 * outline_type; i++) {
		vec2 sample_uv = uv + DIRS[i] * pixel_size * outline_thickness;
		
		// 检查采样点是否在有效UV范围内
		if (sample_uv.x >= 0.0 && sample_uv.x <= 1.0 && sample_uv.y >= 0.0 && sample_uv.y <= 1.0) {
			float neighbor_alpha = texture(tex, sample_uv).a;
			if (neighbor_alpha > 0.01) {
				outline_alpha += neighbor_alpha;
				has_valid_neighbor = true;
			}
		}
	}
	
	// 只有在有有效邻居的情况下才绘制描边
	if (has_valid_neighbor && outline_alpha > 0.0) {
		return vec4(outline_color.rgb, outline_color.a);
	}
	
	return original_color;
}

// 用于应用波浪效果
vec3 apply_wave_effect(vec3 vertex) {
	float t = TIME + time_offset;
	float phase = vertex.x > 0.0 ? 0.0 : PI;
	vertex.z += 0.1 * sin(wave_frequency * t + phase) * wave_strength;
	vertex.y += 0.1 * clamp(sin(wave_frequency * t + phase), 0.0, 1.0) * wave_strength;
	return vertex;
}

// 用于应用果冻呼吸效果
vec3 apply_jelly_effect(vec3 vertex) {
	float t = TIME + time_offset;
	float x_scale = 1.0 + jelly_amplitude * sin(jelly_frequency * t);
	float y_scale = 1.0 + jelly_amplitude * sin(jelly_frequency * t + (inverse_phase ? PI : 0.0));
	vertex.x *= x_scale;
	if (affect_below_ground || vertex.y >= 0.0) vertex.y *= y_scale;
	return vertex;
}

// 用于应用振动效果
vec3 apply_shake_effect(vec3 vertex) {
	float t = TIME + time_offset;
	float shake_x = sin(shake_frequency * t + 10.0) * cos(shake_frequency * t * 1.3 + 5.0) * shake_amplitude * shake_x_weight;
	float shake_y = cos(shake_frequency * t + 20.0) * sin(shake_frequency * t * 1.7 + 15.0) * shake_amplitude * shake_y_weight;
	vertex.x += shake_x;
	vertex.y += shake_y;
	return vertex;
}

// 用于应用扭曲效果 (UV修改)
vec2 apply_distortion_uv(vec2 uv) {
	float t = (TIME + time_offset) * distortion_time_weight;
	vec2 time_offset_uv = vec2(distortion_speed_x * t, distortion_speed_y * t);
	vec4 noise = texture(noise_texture, uv + time_offset_uv);
	vec2 distortion_offset = (noise.xy - 0.5) * distortion_strength * distortion_progress;
	return uv + distortion_offset;
}

// 用于应用消融效果
vec4 apply_dissolve_effect(vec4 color, vec2 uv) {
	float dissolve_noise_val = texture(dissolve_noise, uv).r;
	
	// 如果进度大于噪声值，完全透明
	if (dissolve_progress > dissolve_noise_val) {
		return vec4(color.rgb, 0.0);
	}
	
	// 计算到边缘的距离
	float edge_distance = dissolve_progress - dissolve_noise_val;
	
	// 如果在边缘范围内，应用边缘颜色
	if (abs(edge_distance) < dissolve_edge_width) {
		float edge_factor = 1.0 - (abs(edge_distance) / dissolve_edge_width);
		vec3 final_color = mix(color.rgb, dissolve_edge_color.rgb, edge_factor);
		return vec4(final_color, color.a);
	}
	
	return color;
}

void vertex() {
	VERTEX = apply_shake_effect(apply_jelly_effect(apply_wave_effect(VERTEX)));
}

void fragment() {
	vec2 distorted_uv = apply_distortion_uv(UV); // 应用扭曲效果
	vec4 sprite_color = texture(sprite_texture, distorted_uv); // 使用扭曲后的UV采样
	vec4 final_color = apply_outline(sprite_texture, distorted_uv, sprite_color); // 应用描边
	
	// 应用颜色修改器
	if (enable_modifier) {
		final_color.rgb *= modifier_color.rgb;
	}
	
	// 应用消融效果
	final_color = apply_dissolve_effect(final_color, UV);
	
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a;
	
	// 根据enable_lighting控制光照
	if (enable_lighting==false) {
		EMISSION = final_color.rgb; // 设置自发光以跳过光照计算
	}
}