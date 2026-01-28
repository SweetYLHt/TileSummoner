shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform int blur_radius : hint_range(1, 16) = 8;
uniform float blur_scale : hint_range(0.5, 3.0) = 1.0;
uniform vec4 tint_color : source_color = vec4(0.0, 0.0, 0.0, 0.6);
uniform float intensity : hint_range(0.0, 1.0) = 1.0;

// Precomputed Gaussian kernel weights (sigma = 10, radius = 16)
const float GAUSSIAN_16[17] = float[](
	0.079788, 0.078698, 0.075613, 0.070734, 0.064411, 0.057106, 0.049284,
	0.041395, 0.033851, 0.026946, 0.020884, 0.015761, 0.011577, 0.008282,
	0.005770, 0.003912, 0.002583
);

void fragment() {
	vec2 resolution = SCREEN_PIXEL_SIZE * blur_scale;
	vec2 uv = SCREEN_UV;

	// Center sample
	vec4 col = texture(screen_texture, uv) * GAUSSIAN_16[0];
	float total_weight = GAUSSIAN_16[0];

	// Horizontal and vertical blur combined (separable approximation in single pass)
	for (int i = 1; i <= blur_radius; i++) {
		float weight = GAUSSIAN_16[i];
		float offset = float(i);

		// Horizontal samples
		col += texture(screen_texture, uv + vec2(offset * resolution.x, 0.0)) * weight;
		col += texture(screen_texture, uv - vec2(offset * resolution.x, 0.0)) * weight;

		// Vertical samples
		col += texture(screen_texture, uv + vec2(0.0, offset * resolution.y)) * weight;
		col += texture(screen_texture, uv - vec2(0.0, offset * resolution.y)) * weight;

		total_weight += weight * 4.0;
	}

	// Diagonal samples for smoother blur (using reduced weights)
	for (int i = 1; i <= blur_radius / 2; i++) {
		float weight = GAUSSIAN_16[i * 2] * 0.5;
		float offset = float(i);

		col += texture(screen_texture, uv + vec2(offset, offset) * resolution) * weight;
		col += texture(screen_texture, uv + vec2(-offset, offset) * resolution) * weight;
		col += texture(screen_texture, uv + vec2(offset, -offset) * resolution) * weight;
		col += texture(screen_texture, uv + vec2(-offset, -offset) * resolution) * weight;

		total_weight += weight * 4.0;
	}

	// Normalize
	col /= total_weight;

	// Mix blurred screen with tint, scaled by intensity
	float tint_strength = tint_color.a * intensity;
	COLOR = mix(col, vec4(tint_color.rgb, 1.0), tint_strength);
	COLOR.a = intensity;
}
