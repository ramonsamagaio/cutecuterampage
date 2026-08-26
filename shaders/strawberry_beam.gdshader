shader_type canvas_item;
render_mode unshaded, blend_add;

uniform vec4 beam_tint : source_color = vec4(1.0, 0.25, 0.65, 1.0);
uniform float energy = 2.0;
uniform float ripple_speed = 23.0;
uniform float ripple_density = 34.0;
uniform float edge_power = 1.4;
uniform float wave_strength = 0.08;
uniform float strand_strength = 0.26;
uniform float sparkle_strength = 0.12;
uniform float phase = 0.0;
uniform float flow_speed = 4.0;

float hash11(float p) {
	p = fract(p * 0.1031);
	p *= p + 33.33;
	p *= p + p;
	return fract(p);
}

void fragment() {
	float t = TIME;
	float y = UV.y * 2.0 - 1.0;
	float longitudinal_wave = sin(UV.x * ripple_density - t * ripple_speed + phase);
	float secondary_wave = sin(UV.x * (ripple_density * 0.47) + t * (ripple_speed * 1.31) + phase * 1.7);
	float warped_y = y + longitudinal_wave * wave_strength * (0.35 + 0.65 * abs(y)) + secondary_wave * wave_strength * 0.28;
	float across = abs(warped_y);

	float core = pow(clamp(1.0 - across, 0.0, 1.0), edge_power);
	float soft_body = smoothstep(1.05, 0.02, across);
	float inner = pow(clamp(1.0 - across * 1.55, 0.0, 1.0), 2.2);

	float flow = 0.88 + 0.12 * sin(UV.x * 72.0 - t * ripple_speed * 1.8 + phase);
	float flicker = 0.93 + 0.07 * sin(t * (ripple_speed * 2.2) + UV.x * 19.0 + phase * 3.0);
	float ribbon_a = pow(max(0.0, 1.0 - abs(y - sin(UV.x * 43.0 - t * 7.5 + phase) * 0.28) * 5.0), 6.0);
	float ribbon_b = pow(max(0.0, 1.0 - abs(y + sin(UV.x * 35.0 + t * 8.4 + phase * 0.6) * 0.31) * 5.4), 6.0);
	float strands = (ribbon_a + ribbon_b) * strand_strength;

	float cell = floor(UV.x * 155.0 + t * flow_speed * 13.0);
	float spark_gate = step(0.972, hash11(cell + phase * 19.0));
	float spark_shape = pow(max(0.0, 1.0 - abs(fract(UV.x * 155.0 + t * flow_speed * 13.0) - 0.5) * 7.0), 5.0);
	float sparks = spark_gate * spark_shape * pow(max(0.0, 1.0 - across * 1.4), 3.0) * sparkle_strength;

	float head = smoothstep(0.0, 0.018, UV.x);
	float tail = 1.0 - smoothstep(0.92, 1.0, UV.x);
	float longitudinal_envelope = head * (0.76 + tail * 0.24);

	float intensity = (soft_body * 0.52 + core * 0.92 + inner * 1.25 + strands + sparks * 3.0) * flow * flicker;
	vec4 vertex_color = COLOR;
	vec3 hdr = beam_tint.rgb * energy * intensity * longitudinal_envelope;
	hdr += vec3(1.0, 0.84, 0.96) * inner * energy * 0.62;
	hdr += beam_tint.rgb * sparks * energy * 1.8;

	float alpha = vertex_color.a * beam_tint.a * clamp(soft_body + inner + strands, 0.0, 1.0) * longitudinal_envelope;
	COLOR = vec4(hdr * vertex_color.rgb, alpha);
}
