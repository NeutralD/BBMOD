/// @func BBMOD_Renderer()
function BBMOD_Renderer() constructor
{
	/// @var {ds_list} List of object to render.
	/// @readonly
	Objects = ds_list_create();

	/// @var {BBMOD_Camera}
	/// @readonly
	Camera = new BBMOD_Camera();

	/// @var {real}
	Supersampling = 1;

	/// @var {uint}
	ColorGrading = 0;

	application_surface_enable(true);
	application_surface_draw_enable(false);
	gpu_set_tex_filter(true);

	/// @func add_object(_object)
	/// @param {object} _object
	/// @return {BBMOD_Renderer} Returns `self` to allow method chaining.
	static add_object = function (_object) {
		gml_pragma("forceinline");
		ds_list_add(Objects, _object);
		return self;
	};

	/// @func update()
	/// @return {BBMOD_Renderer} Returns `self` to allow method chaining.
	static update = function () {
		var _window_width = max(window_get_width(), 1);
		var _window_height = max(window_get_height(), 1);
		var _surface_width = max(_window_width * Supersampling, 1);
		var _surface_height = max(_window_height * Supersampling, 1);

		ce_surface_check(application_surface, _surface_width, _surface_height);

		Camera.update();

		return self;
	};

	/// @func render()
	/// @return {BBMOD_Renderer} Returns `self` to allow method chaining.
	static render = function () {
		Camera.apply();
		global.bbmod_camera_position = Camera.Position;

		gpu_push_state();
		gpu_set_ztestenable(true);
		gpu_set_zwriteenable(true);
		gpu_set_tex_filter(true);
		gpu_set_tex_mip_enable(mip_on);

		var _world = matrix_get(matrix_world);

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

		matrix_set(matrix_world, _world);

		gpu_pop_state();

		return self;
	};

	/// @func present()
	/// @return {BBMOD_Renderer} Returns `self` to allow method chaining.
	static present = function () {
		gml_pragma("forceinline");
		var _window_width = window_get_width();
		var _window_height = window_get_height();
		var _shader = BBMOD_ShPostProcess;
		shader_set(_shader);
		texture_set_stage(shader_get_sampler_index(_shader, "u_texLut"), sprite_get_texture(BBMOD_SprColorGrading, 0));
		shader_set_uniform_f(shader_get_uniform(_shader, "u_fLutIndex"), ColorGrading);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), 1 / _window_width, 1 / _window_height);
		shader_set_uniform_f(shader_get_uniform(_shader, "u_fDistortion"), 3);
		draw_surface_stretched(application_surface, 0, 0, _window_width, _window_height);
		shader_reset();
		return self;
	};
}