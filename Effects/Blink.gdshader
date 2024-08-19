shader_type canvas_item;

uniform bool active = false;

void fragment(){
	vec4 previouscolor = texture(TEXTURE, UV);
	vec4 whitecolor = vec4(1.0, 1.0, 1.0, previouscolor.a);
	vec4 newcolor = previouscolor;
	if (active == true){
		newcolor = whitecolor;
	}
	COLOR = newcolor;
}