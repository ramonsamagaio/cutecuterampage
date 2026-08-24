shader_type canvas_item;
render_mode unshaded, blend_add;

uniform vec4 beam_tint : source_color = vec4(1.0, 0.25, 0.65, 1.0);
uniform float energy = 2.0;
uniform float ripple_speed = 23.0;
uniform float ripple_density = 34.0;
uniform float edge_power = 1.4;

void fragment() {
	float across = abs(UV.y * 2.0 - 1.0);
	float core = pow(clamp(1.0 - across, 0.0, 1.0), edge_power);
	float ripple = 0.88 + 0.12 * sin(TIME * ripple_speed - UV.x * ripple_density);
	float shimmer = 0.92 + 0.08 * sin(TIME * (ripple_speed * 1.73) + UV.x * 57.0 + UV.y * 9.0);
	vec4 vertex_color = COLOR;
	vec3 hdr_color = vertex_color.rgb * beam_tint.rgb * energy * ripple * shimmer;
	hdr_color += beam_tint.rgb * core * energy * 0.75;
	COLOR = vec4(hdr_color, vertex_color.a * beam_tint.a);
}
