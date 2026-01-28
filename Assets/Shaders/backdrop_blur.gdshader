shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 20.0) = 8.0;
uniform vec4 tint_color : source_color = vec4(0.0, 0.0, 0.0, 0.6);
uniform float intensity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float blur = blur_amount * intensity;
	vec2 ps = SCREEN_PIXEL_SIZE * blur;

	// 25-tap 2D Gaussian kernel (sigma ~= 1.5)
	// 3 rings: cardinal + diagonal directions

	// Center
	vec4 col = texture(screen_texture, SCREEN_UV) * 0.1031;

	// Ring 1 - cardinal (distance 1)
	col += texture(screen_texture, SCREEN_UV + vec2(ps.x, 0.0)) * 0.0825;
	col += texture(screen_texture, SCREEN_UV - vec2(ps.x, 0.0)) * 0.0825;
	col += texture(screen_texture, SCREEN_UV + vec2(0.0, ps.y)) * 0.0825;
	col += texture(screen_texture, SCREEN_UV - vec2(0.0, ps.y)) * 0.0825;

	// Ring 1 - diagonal (distance sqrt(2))
	col += texture(screen_texture, SCREEN_UV + vec2(ps.x, ps.y)) * 0.0661;
	col += texture(screen_texture, SCREEN_UV + vec2(-ps.x, ps.y)) * 0.0661;
	col += texture(screen_texture, SCREEN_UV + vec2(ps.x, -ps.y)) * 0.0661;
	col += texture(screen_texture, SCREEN_UV + vec2(-ps.x, -ps.y)) * 0.0661;

	// Ring 2 - cardinal (distance 2)
	col += texture(screen_texture, SCREEN_UV + vec2(ps.x * 2.0, 0.0)) * 0.0424;
	col += texture(screen_texture, SCREEN_UV - vec2(ps.x * 2.0, 0.0)) * 0.0424;
	col += texture(screen_texture, SCREEN_UV + vec2(0.0, ps.y * 2.0)) * 0.0424;
	col += texture(screen_texture, SCREEN_UV - vec2(0.0, ps.y * 2.0)) * 0.0424;

	// Ring 2 - diagonal (distance 2*sqrt(2))
	col += texture(screen_texture, SCREEN_UV + vec2(ps.x * 2.0, ps.y * 2.0)) * 0.0174;
	col += texture(screen_texture, SCREEN_UV + vec2(-ps.x * 2.0, ps.y * 2.0)) * 0.0174;
	col += texture(screen_texture, SCREEN_UV + vec2(ps.x * 2.0, -ps.y * 2.0)) * 0.0174;
	col += texture(screen_texture, SCREEN_UV + vec2(-ps.x * 2.0, -ps.y * 2.0)) * 0.0174;

	// Ring 3 - cardinal (distance 3)
	col += texture(screen_texture, SCREEN_UV + vec2(ps.x * 3.0, 0.0)) * 0.0139;
	col += texture(screen_texture, SCREEN_UV - vec2(ps.x * 3.0, 0.0)) * 0.0139;
	col += texture(screen_texture, SCREEN_UV + vec2(0.0, ps.y * 3.0)) * 0.0139;
	col += texture(screen_texture, SCREEN_UV - vec2(0.0, ps.y * 3.0)) * 0.0139;

	// Ring 3 - diagonal (distance 3*sqrt(2))
	col += texture(screen_texture, SCREEN_UV + vec2(ps.x * 3.0, ps.y * 3.0)) * 0.0019;
	col += texture(screen_texture, SCREEN_UV + vec2(-ps.x * 3.0, ps.y * 3.0)) * 0.0019;
	col += texture(screen_texture, SCREEN_UV + vec2(ps.x * 3.0, -ps.y * 3.0)) * 0.0019;
	col += texture(screen_texture, SCREEN_UV + vec2(-ps.x * 3.0, -ps.y * 3.0)) * 0.0019;

	// Mix blurred screen with tint, scaled by intensity
	float tint_strength = tint_color.a * intensity;
	COLOR = mix(col, vec4(tint_color.rgb, 1.0), tint_strength);
	COLOR.a = intensity;
}
