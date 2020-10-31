event_inherited();

show_debug_overlay(false);
display_set_gui_maximize(1, 1);

renderer = new BBMOD_DeferredRenderer()
	.add_object(OModel)
	;

if (os_type == os_windows)
{
	renderer.Supersampling = 1;
}

renderer.Camera.FollowObject = id;

mod_sphere = new BBMOD_Model("BBMOD/Models/Sphere.bbmod");

mat_gbuffer = new BBMOD_Material(BBMOD_ShGBuffer);
mat_gbuffer.RenderPath = BBMOD_RENDER_DEFERRED;
mat_gbuffer.OnApply = method(self, function (_material) {
	var _shader = _material.Shader;

	if (!_material.Mipmapping)
	{
		gpu_set_tex_mip_enable(mip_off);
	}

	if (!_material.Filtering)
	{
		gpu_set_tex_filter(false);
	}

	texture_set_stage(1, _material.NormalRoughness);
	texture_set_stage(2, _material.MetallicAO);
	texture_set_stage(3, _material.Subsurface);
	texture_set_stage(4, _material.Emissive);
	texture_set_stage(5, sprite_get_texture(BBMOD_SprBestFitNormals, 0));

	var _camera = renderer.Camera;

	_bbmod_shader_set_alpha_test(_shader, _material.AlphaTest);
	shader_set_uniform_f(shader_get_uniform(_shader, "u_fZFar"), _camera.ZFar);
});