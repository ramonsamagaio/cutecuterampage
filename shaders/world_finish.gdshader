shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float saturation : hint_range(0.8, 1.3) = 1.09;
uniform float contrast : hint_range(0.8, 1.3) = 1.055;
uniform float vignette : hint_range(0.0, 0.5) = 0.135;
uniform float pastel_lift : hint_range(0.0, 0.12) = 0.028;
uniform float atmosphere : hint_range(0.0, 0.12) = 0.038;
uniform float center_light : hint_range(0.0, 0.12) = 0.026;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 src = texture(screen_texture, uv);
	vec3 c = src.rgb;
	float luma = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(luma), c, saturation);
	c = (c - 0.5) * contrast + 0.5;
	c += vec3(pastel_lift * 0.62, pastel_lift * 0.30, pastel_lift * 0.52);

	// Broad, extremely cheap moving canopy light. Two sine fields are enough to stop
	// the garden from reading like a perfectly flat uniformly-lit debug plane.
	float drift_a = sin(uv.x * 8.2 + uv.y * 3.9 + TIME * 0.10);
	float drift_b = sin(uv.x * 4.1 - uv.y * 7.3 - TIME * 0.072 + 1.7);
	float canopy = smoothstep(0.12, 0.86, drift_a * 0.58 + drift_b * 0.42);
	c *= 1.0 - canopy * atmosphere;

	vec2 centered = uv * 2.0 - 1.0;
	float radial = clamp(1.0 - length(centered) * 0.78, 0.0, 1.0);
	c += vec3(center_light * 0.82, center_light * 0.38, center_light * 0.67) * radial;

	float edge = smoothstep(0.46, 1.38, dot(centered, centered));
	c *= 1.0 - edge * vignette;

	// Soft highlight compression keeps bloom colors candy-bright without washing whites out.
	c = c / (vec3(0.92) + c * 0.08);
	COLOR = vec4(c, src.a);
}
