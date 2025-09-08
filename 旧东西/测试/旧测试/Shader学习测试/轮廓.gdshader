shader_type canvas_item;

uniform vec4 outline_color:source_color = vec4(0.,0.,0.,1.);

void fragment() {
	// 上下左右采样
	float PIXEL_SZIE = TEXTURE_PIXEL_SIZE.x;

	vec4 COLOR1 = texture(TEXTURE, UV + vec2(+PIXEL_SZIE, +PIXEL_SZIE));
	vec4 COLOR2 = texture(TEXTURE, UV + vec2(+PIXEL_SZIE, -PIXEL_SZIE));
	vec4 COLOR3 = texture(TEXTURE, UV + vec2(-PIXEL_SZIE, +PIXEL_SZIE));
	vec4 COLOR4 = texture(TEXTURE, UV + vec2(-PIXEL_SZIE, -PIXEL_SZIE));

	vec4 COLOR_RAW = texture(TEXTURE, UV);
	COLOR = COLOR1 + COLOR2 + COLOR3 + COLOR4;

	if (COLOR_RAW.a > 0.0){
		COLOR = COLOR_RAW;
	}else if (COLOR.a > 0.0) {
		COLOR = outline_color;
	}
}