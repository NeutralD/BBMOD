show_debug_overlay(false);

z = 0;

renderer = new BBMOD_Renderer()
	.add_object(OSky)
	.add_object(OModel);

renderer.Camera.FollowObject = id;

mod_sphere = new BBMOD_Model("BBMOD/Models/Sphere.bbmod").freeze();