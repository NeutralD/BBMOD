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
	Supersampling = 2;

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

		if (surface_get_width(application_surface) != _surface_width
			|| surface_get_height(application_surface) != _surface_height)
		{
			surface_resize(application_surface, _surface_width, _surface_height);
		}

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
		draw_surface_stretched(application_surface, 0, 0, window_get_width(), window_get_height());
		return self;
	};
}