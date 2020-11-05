event_inherited();

model = ORenderer.mod_character;
animation_player = new BBMOD_AnimationPlayer(model);
animation_player.play(ORenderer.anim_idle, true);
image_xscale = 10;