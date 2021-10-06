// Based on https://godotshaders.com/shader/2d-outline-inline/

shader_type canvas_item;


// change at runtime
uniform bool selected = false;
uniform bool overlay = false;
uniform vec4 selected_color : hint_color = vec4(0.98823, 0.97647, 0.37647, 0.5);
uniform vec4 overlay_color : hint_color = vec4(0.98823, 0.97647, 0.37647, 0.5);

// constant
uniform vec4 border_color : hint_color = vec4(0.98823, 0.97647, 0.37647, 1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;




bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;
		
		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a == 0.0) == inside) {
				return true;
			}
		}
	}
	return false;
}

void fragment() {
	vec2 uv = UV;
	COLOR = texture(TEXTURE, uv);


	if (COLOR.a > 0.0) {
		if (selected) {
			COLOR.rgba = selected_color.rgba;
		} else if (overlay) {
			COLOR.rgba = overlay_color.rgba;
		} else {
			COLOR.a = 0.01;
		}
	}

	if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		COLOR.rgb = inside ? mix(COLOR.rgb, border_color.rgb, border_color.a) : border_color.rgb;
		COLOR.a += (1.0 - COLOR.a) * border_color.a;
	}



}