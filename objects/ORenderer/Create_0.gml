event_inherited();

show_debug_overlay(false);
display_set_gui_maximize(1, 1);

renderer = new BBMOD_Renderer()
	.add_object(OCharacter)
	//.add_object(OModel)
	.add_object(ODynamicBatch)
	//.add_object(OStaticBatch)
	.add_object(OSky)
	;

if (os_type == os_windows)
{
	renderer.RenderScale = 2;
}
else if (os_type == os_android)
{
	renderer.RenderScale = 0.5;
	room_speed = 30;
}

renderer.Camera.FollowObject = id;

mod_sphere = new BBMOD_Model("BBMOD/Models/Sphere.bbmod");

mod_character = new BBMOD_Model("Assets/Character.bbmod");

anim_idle = new BBMOD_Animation("Assets/Idle.bbanim");