shader_type canvas_item;

uniform float fadeout_progress:hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float h_move_offset = 300.0;


void vertex() {
	VERTEX.x += fadeout_progress * h_move_offset;
}

void fragment() {
	COLOR.a = (1.0-fadeout_progress) * texture(TEXTURE, UV).a * COLOR.a;
}
