var _mod_sphere = ORenderer.mod_sphere;
var _static_batch = static_batch;
static_batch.start();
with (OModel)
{
	_static_batch.add(_mod_sphere, matrix_build(
		x, y, z, 0, 0, image_angle, image_xscale, image_xscale, image_xscale));
}
static_batch.finish();
static_batch.freeze();