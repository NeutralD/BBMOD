show_debug_overlay(false);

application_surface_enable(true);
application_surface_draw_enable(false);
application_surface_scale = 2;

gpu_set_tex_filter(true);

renderer = new BBMOD_Renderer()
	.add_object(OSky)
	.add_object(OModel);

z = 0;
direction_up = 0;
mouse_last_x = 0;
mouse_last_y = 0;

mod_sphere = new BBMOD_Model("BBMOD/Models/Sphere.bbmod").freeze();