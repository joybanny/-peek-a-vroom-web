shader_type canvas_item;
uniform float fill_amount = 0.0;
uniform bool fast = false;
vec3 hue(vec3 c, float angle) {
 float co = cos(radians(angle)); float si = sin(radians(angle));
 return vec3(dot(c, vec3(.213+.787*co-.213*si,.715-.715*co-.715*si,.072-.072*co+.928*si)),
 dot(c,vec3(.213-.213*co+.143*si,.715+.285*co+.140*si,.072-.072*co-.283*si)),
 dot(c,vec3(.213-.213*co-.787*si,.715-.715*co+.715*si,.072+.928*co+.072*si)));
}
vec3 filtered(vec3 c, float angle, float saturation, float brightness) {
 c = clamp(hue(c, angle), vec3(0.), vec3(1.));
 c = mix(vec3(dot(c, vec3(.213,.715,.072))), c, saturation);
 return clamp(c, vec3(0.), vec3(1.)) * brightness;
}
void fragment() {
 vec4 source = texture(TEXTURE, UV);
 vec3 yellow = fast ? source.rgb : filtered(source.rgb,29.,.85,1.45);
 vec3 red = filtered(source.rgb,-32.,1.4,.98);
 float edge = fill_amount <= 0. ? 1. : (fill_amount >= 1. ? 0. : .92-fill_amount*.84);
 float filled = fill_amount <= 0. ? 0. : step(edge, UV.y);
 COLOR = vec4(mix(yellow,red,filled),source.a);
}
