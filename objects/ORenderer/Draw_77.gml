var _scale = 1 / application_surface_scale;
draw_surface_ext(application_surface, 0, 0, _scale, _scale, 0, c_white, 1);

var _mode = "";

switch (mode_current)
{
case EMode.Normal:
	_mode = "Instances";
	break;

case EMode.Static:
	_mode = "Static batch";
	break;

case EMode.Dynamic:
	_mode = "Dynamic batch";
	break;
}

var _text = "Rendering mode: " + _mode + " [SPACE]";
var _x = 0;
var _y = 24;

if (TEST_CUBEMAP)
{
	cubemap.to_single_surface(0, 0);
	draw_surface(cubemap.Surface, 0, window_get_height() - surface_get_height(cubemap.Surface));

	_text += "\nCtrl+S to save cubemap as PNG";
}

draw_text_color(_x + 1, _y + 2, _text, 0, 0, 0, 0, 1);
draw_text(_x, _y, _text);