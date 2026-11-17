shader_type canvas_item;
uniform float enabled_amount = 0.0;
uniform bool race_mode = false;
vec3 hue(vec3 c, float angle) {
 float co = cos(radians(angle)); float si = sin(radians(angle));
 return vec3(dot(c, vec3(.213+.787*co-.213*si,.715-.715*co-.715*si,.072-.072*co+.928*si)),
 dot(c,vec3(.213-.213*co+.143*si,.715+.285*co+.140*si,.072-.072*co-.283*si)),
 dot(c,vec3(.213-.213*co-.787*si,.715-.715*co+.715*si,.072+.928*co+.072*si)));
}
vec3 saturate_color(vec3 c, float s) {
 return clamp(mix(vec3(dot(c,vec3(.213,.715,.072))),c,s),vec3(0.),vec3(1.));
}
vec3 sepia(vec3 c, float amount) {
 vec3 sep = vec3(dot(c,vec3(.393,.769,.189)),dot(c,vec3(.349,.686,.168)),dot(c,vec3(.272,.534,.131)));
 return clamp(mix(c,sep,amount),vec3(0.),vec3(1.));
}
void fragment() {
 vec4 source = texture(TEXTURE, UV);
 vec3 off_color = saturate_color(source.rgb,.45) * 1.13;
 vec3 on_color = clamp(hue(saturate_color(sepia(source.rgb,.2),2.3),5.),vec3(0.),vec3(1.)) * 1.06;
 vec3 race_color = clamp(hue(saturate_color(sepia(source.rgb,.35),3.4),-21.),vec3(0.),vec3(1.));
 COLOR = vec4(race_mode ? race_color : mix(off_color,on_color,enabled_amount), source.a);
}
