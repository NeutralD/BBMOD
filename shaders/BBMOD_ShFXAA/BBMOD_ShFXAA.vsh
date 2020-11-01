attribute vec4 in_Position;
attribute vec2 in_TextureCoord;

uniform vec2 u_vTexelVS;

varying vec4 v_vPos;

#pragma include("FXAA_VS.xsh", "glsl")
// Source: https://www.geeks3d.com/20110405/fxaa-fast-approximate-anti-aliasing-demo-glsl-opengl-test-radeon-geforce/3/

/// @param texCoord Texture coordinates.
/// @param texel    vec2(1.0 / textureWidth, 1.0 / textureHeight)
vec4 xFxaaFragPos(vec2 texCoord, vec2 texel)
{
	vec4 pos;
	pos.xy = texCoord;
	pos.zw = texCoord - (texel * 0.75);
	return pos;
}
// include("FXAA_VS.xsh")

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	v_vPos = xFxaaFragPos(in_TextureCoord, u_vTexelVS);
}