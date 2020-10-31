/// @func BBMOD_DeferredRenderer()
function BBMOD_DeferredRenderer() : BBMOD_Renderer() constructor
{
	application_surface_enable(true);
	application_surface_draw_enable(false);
	gpu_set_tex_filter(true);

	GB = array_create(4, noone);

	/// @func render()
	/// @return {BBMOD_Renderer} Returns `self` to allow method chaining.
	static render = function () {
		var _surface_width = surface_get_width(application_surface);
		var _surface_height = surface_get_height(application_surface);

		for (var i = 0; i < 4; ++i)
		{
			GB[@ i] = ce_surface_check(GB[i], _surface_width, _surface_height);
		}

		////////////////////////////////////////////////////////////////////////
		// G-Buffer
		surface_set_target_ext(0, application_surface);
		surface_set_target_ext(1, GB[1]);
		surface_set_target_ext(2, GB[2]);
		surface_set_target_ext(3, GB[3]);
		draw_clear_alpha(0, 0);

		Camera.apply();

		gpu_push_state();
		gpu_set_blendenable(false);
		gpu_set_ztestenable(true);
		gpu_set_zwriteenable(true);
		gpu_set_tex_filter(true);
		gpu_set_tex_mip_enable(mip_on);

		var _world = matrix_get(matrix_world);

		global.bbmod_render_pass = BBMOD_RENDER_DEFERRED;

		bbmod_material_reset();
		var i = 0;
		repeat (ds_list_size(Objects))
		{
			with (Objects[| i++])
			{
				event_perform(ev_draw, 0);
			}
		}
		bbmod_material_reset();

		global.bbmod_render_pass = BBMOD_RENDER_FORWARD;

		matrix_set(matrix_world, _world);

		gpu_pop_state();

		surface_reset_target();
		ce_surface_copy(application_surface, GB[0]);
		////////////////////////////////////////////////////////////////////////

		return self;
	};

	/// @func present()
	/// @return {BBMOD_Renderer} Returns `self` to allow method chaining.
	static present = function () {
		var _width = window_get_width();
		var _height = window_get_height();

		var _shader = BBMOD_ShDeferred;
		shader_set(_shader);
		texture_set_stage(1, surface_get_texture(GB[1]));
		texture_set_stage(2, surface_get_texture(GB[2]));
		texture_set_stage(3, surface_get_texture(GB[3]));

		_bbmod_shader_set_exposure(_shader);
		_bbmod_shader_set_camera_position(_shader);

		var _camera = Camera;
		var _tan_fov_y = dtan(_camera.Fov * 0.5);
		var _tan_aspect = [_tan_fov_y * _camera.AspectRatio, -_tan_fov_y];

		shader_set_uniform_f(shader_get_uniform(_shader, "u_fZFar"), _camera.ZFar);

		var _inverse = _camera.get_view_mat();
		ce_matrix_inverse(_inverse);

		shader_set_uniform_matrix_array(shader_get_uniform(_shader, "u_mInverse"), _inverse);
		shader_set_uniform_f_array(shader_get_uniform(_shader, "u_vTanAspect"), _tan_aspect);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_vLightDir"), -1, -1, -1);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_vLightCol"), 1, 1, 1, 3.14);

		draw_surface_stretched(GB[0], 0, 0, _width, _height);
		shader_reset();

		//var _width_half = _width * 0.5;
		//var _height_half = _height * 0.5;
		//draw_surface_stretched(GB[0], 0,           0,            _width_half, _height_half);
		//draw_surface_stretched(GB[1], _width_half, 0,            _width_half, _height_half);
		//draw_surface_stretched(GB[2], 0,           _height_half, _width_half, _height_half);
		//draw_surface_stretched(GB[3], _width_half, _height_half, _width_half, _height_half);
		return self;
	};
}