/// @func BBMOD_Renderer()
function BBMOD_Renderer() constructor
{
	/// @var {ds_list} List of object to render.
	/// @readonly
	Objects = ds_list_create();

	/// @var {camera}
	/// @readonly
	Camera = camera_create();

	/// @var {array}
	CameraFrom = ce_vec3_create(0);

	/// @var {array}
	CameraTo = ce_vec3_create(1, 0, 0);

	/// @var {array}
	CameraUp = ce_vec3_create(0, 0, 1);

	/// @var {real}
	Fov = 60;

	/// @var {real}
	AspectRatio = 16 / 9;

	/// @var {real}
	ZNear = 0.1;

	/// @var {real}
	ZFar = 8192;

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
		return self;
	};

	/// @func render()
	/// @return {BBMOD_Renderer} Returns `self` to allow method chaining.
	static render = function () {
		camera_set_view_mat(Camera, matrix_build_lookat(
			CameraFrom[0], CameraFrom[1], CameraFrom[2],
			CameraTo[0], CameraTo[1], CameraTo[2],
			CameraUp[0], CameraUp[1], CameraUp[2]));

		camera_set_proj_mat(Camera, matrix_build_projection_perspective_fov(
			-Fov, -AspectRatio, ZNear, ZFar));

		camera_apply(Camera);
		bbmod_set_camera_position(CameraFrom[0], CameraFrom[1], CameraFrom[2]);

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
}