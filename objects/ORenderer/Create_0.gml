show_debug_overlay(true);

application_surface_enable(true);
application_surface_draw_enable(false);
application_surface_scale = 2;

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_tex_filter(true);

camera = camera_create();

var _fov = 60;
var _aspect = window_get_width() / window_get_height();
var _znear = 0.1;
var _zfar = 8192;

camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(
	-_fov, -_aspect, _znear, _zfar));

x = 3;
z = 0;
direction = 180;
direction_up = 0;
mouse_last_x = 0;
mouse_last_y = 0;

spr_sky = sprite_add("BBMOD/Skies/NoonSky.png", 0, false, true, 0, 0);
spr_ibl = sprite_add("BBMOD/Skies/NoonIBL.png", 0, false, true, 0, 0);

bbmod_set_ibl_sprite(spr_ibl, 0);

mod_sphere = new BBMOD_Model("BBMOD/Models/Sphere.bbmod");

mat_sky = new BBMOD_Material(BBMOD_ShSky, sprite_get_texture(spr_sky, 0));
mat_sky.set_on_apply(shader_sky_on_apply);
mat_sky.set_culling(cull_noculling);

#macro BATCH_SIZE 64

enum EMode
{
	Normal,
	Static,
	Dynamic,
	SIZE
};

mode_current = EMode.Normal;

material = [
	[new BBMOD_Material(BBMOD_ShDefault)],
	new BBMOD_Material(BBMOD_ShDefault),
	new BBMOD_Material(BBMOD_ShDefaultBatched)
];

model = [
	mod_sphere,
	BBMOD_NONE,
	BBMOD_NONE
];

freezed = false;

for (var i = 0; i < BATCH_SIZE; ++i)
{
	var _x = (i mod 8) * 5;
	var _y = (i div 8) * 5;
	instance_create_layer(_x, _y, layer, OModel);
}