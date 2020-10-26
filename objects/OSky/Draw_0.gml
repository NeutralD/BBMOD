var _renderer = instance_find(ORenderer, 0);
var _camera_position = _renderer.renderer.CameraFrom;

matrix_set(matrix_world, matrix_build(
	_camera_position[0],
	_camera_position[1],
	_camera_position[2],
	0, 0, 0,
	1000, 1000, 1000));

_renderer.mod_sphere.render([BBMOD_MATERIAL_SKY]);