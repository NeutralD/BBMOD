/// @func BBMOD_Camera()
function BBMOD_Camera() constructor
{
	/// @var {camera} An underlying GM camera.
	/// @readonly
	Camera = camera_create();

	/// @var {real}
	Exposure = 1;

	/// @var {real[]} The camera's positon.
	Position = ce_vec3_create(0);

	/// @var {real[]} A position where the camera is looking at.
	Target = ce_vec3_create(1, 0, 0);

	/// @var {real[]} The camera's up vector.
	Up = ce_vec3_create(0, 0, 1);

	/// @var {real} The camera's field of view.
	Fov = 60;

	/// @var {real} The camera's aspect ratio.
	AspectRatio = 16 / 9;

	/// @var {real} Distance to the near clipping plane. Anything closer to the
	/// camera than this won't be visible.
	ZNear = 0.1;

	/// @var {real} Distance to the far clipping plane. Anything farther from the
	/// camera than this won't be visible.
	ZFar = 8192;

	/// @var {uint/undefined} In id of an instance to follow or `undefined`.
	FollowObject = undefined;

	/// @var {bool} True to enable mouselook.
	/// @private
	MouseLook = true;

	/// @var {real[]/undefined}
	/// @private
	MouseLockAt = undefined;

	/// @var {real}
	/// @readonly
	Direction = 0;

	/// @var {real}
	/// @readonly
	DirectionUp = 0;

	/// @var {real}
	Zoom = 0;

	/// @func set_mouse_look(_enable)
	/// @param {bool} _enable
	/// @return {BBMOD_Camera} Returns `self` to allow method chaining.
	static set_mouse_look = function (_enable) {
		if (_enable)
		{
			if (MouseLockAt == undefined)
			{
				MouseLockAt = [
					window_mouse_get_x(),
					window_mouse_get_y(),
				];
			}
		}
		else
		{
			MouseLockAt = undefined;
		}
		MouseLook = _enable;
		return self;
	};

	/// @func update()
	/// @return {BBMOD_Camera} Returns `self` to allow method chaining.
	static update = function () {
		if (MouseLook)
		{
			var _mouse_x = window_mouse_get_x();
			var _mouse_y = window_mouse_get_y();
			var _mouse_sensitivity = 0.8;
			Direction += (MouseLockAt[0] - _mouse_x) * _mouse_sensitivity;
			DirectionUp += (MouseLockAt[1] - _mouse_y) * _mouse_sensitivity;
			DirectionUp = clamp(DirectionUp, -89, 89);
			window_mouse_set(MouseLockAt[0], MouseLockAt[1]);
		}

		if (Zoom <= 0)
		{
			// First person camera
			if (FollowObject != undefined)
			{
				Position[@ 0] = FollowObject.x;
				Position[@ 1] = FollowObject.y;
				Position[@ 2] = FollowObject.z;
			}

			Target = ce_vec3_clone(Position);
			ce_vec3_add(Target, [
				+dcos(Direction),
				-dsin(Direction),
				+dtan(DirectionUp)
			]);
		}
		else
		{
			// Third person camera
			if (FollowObject != undefined)
			{
				Target[@ 0] = FollowObject.x;
				Target[@ 1] = FollowObject.y;
				Target[@ 2] = FollowObject.z;
			}

			Position = ce_vec3_clone(Target);
			var _l = dcos(DirectionUp) * Zoom;
			ce_vec3_add(Position, [
				-dcos(Direction) * _l,
				+dsin(Direction) * _l,
				-dsin(DirectionUp) * Zoom
			]);
		}

		camera_set_view_mat(Camera, matrix_build_lookat(
			Position[0], Position[1], Position[2],
			Target[0], Target[1], Target[2],
			Up[0], Up[1], Up[2]));

		camera_set_proj_mat(Camera, matrix_build_projection_perspective_fov(
			-Fov, -AspectRatio, ZNear, ZFar));

		return self;
	};

	/// @func get_view_mat()
	/// @return {real[]}
	static get_view_mat = function () {
		gml_pragma("forceinline");
		return camera_get_view_mat(Camera);
	};

	/// @func getproj_mat()
	/// @return {real[]}
	static get_view_mat = function () {
		gml_pragma("forceinline");
		return camera_get_proj_mat(Camera);
	};

	/// @func apply()
	/// @return {BBMOD_Camera} Returns `self` to allow method chaining.
	static apply = function () {
		gml_pragma("forceinline");
		camera_apply(Camera);
		global.bbmod_camera_exposure = Exposure;
		return self;
	};
}