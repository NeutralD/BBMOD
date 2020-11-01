event_inherited();

show_debug_overlay(false);
display_set_gui_maximize(1, 1);

renderer = new BBMOD_Renderer()
	.add_object(OModel)
	.add_object(OSky)
	;

if (os_type == os_windows)
{
	renderer.Supersampling = 2;
}

renderer.Camera.FollowObject = id;

mod_sphere = new BBMOD_Model("BBMOD/Models/Sphere.bbmod");