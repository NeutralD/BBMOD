matrix_set(matrix_world, matrix_build(
	x, y, z, 0, 0, image_angle, image_xscale, image_xscale, image_xscale));

model.render([BBMOD_MATERIAL_DEFAULT_ANIMATED], animation_player.get_transform());