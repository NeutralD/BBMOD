var _camera = renderer.Camera;

_camera.AspectRatio = window_get_width() / window_get_height();

// Mouselook
_camera.set_mouse_look(mouse_check_button(mb_right));
window_set_cursor(_camera.MouseLook ? cr_none : cr_arrow);

// Move around
var _move_speed = keyboard_check(vk_shift) ? 4 : 1;

if (keyboard_check(ord("W")))
{
	x += lengthdir_x(_move_speed, _camera.Direction);
	y += lengthdir_y(_move_speed, _camera.Direction);
}
else if (keyboard_check(ord("S")))
{
	x -= lengthdir_x(_move_speed, _camera.Direction);
	y -= lengthdir_y(_move_speed, _camera.Direction);
}

if (keyboard_check(ord("A")))
{
	x += lengthdir_x(_move_speed, _camera.Direction + 90);
	y += lengthdir_y(_move_speed, _camera.Direction + 90);
}
else if (keyboard_check(ord("D")))
{
	x += lengthdir_x(_move_speed, _camera.Direction - 90);
	y += lengthdir_y(_move_speed, _camera.Direction - 90);
}

z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * _move_speed;

_camera.Zoom += (mouse_wheel_down() - mouse_wheel_up()) * 2;
_camera.Zoom = max(_camera.Zoom, 0);

// Controls
_camera.Exposure += (keyboard_check(vk_add) - keyboard_check(vk_subtract)) * 0.01;
_camera.Exposure = max(_camera.Exposure, 0.01);

renderer.update();