shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float saturation : hint_range(0.8, 1.3) = 1.08;
uniform float contrast : hint_range(0.8, 1.3) = 1.055;
uniform float vignette : hint_range(0.0, 0.5) = 0.16;
uniform float pastel_lift : hint_range(0.0, 0.12) = 0.025;

void fragment() {
	vec4 src = texture(screen_texture, SCREEN_UV);
	vec3 c = src.rgb;
	float luma = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(luma), c, saturation);
	c = (c - 0.5) * contrast + 0.5;
	c += vec3(pastel_lift * 0.62, pastel_lift * 0.30, pastel_lift * 0.52);
	vec2 centered = SCREEN_UV * 2.0 - 1.0;
	float edge = smoothstep(0.42, 1.35, dot(centered, centered));
	c *= 1.0 - edge * vignette;
	COLOR = vec4(c, src.a);
}
