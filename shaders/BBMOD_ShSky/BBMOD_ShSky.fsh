varying vec3 v_vNormal;

// Camera's exposure value
uniform float u_fExposure;

#pragma include("EquirectangularMapping.xsh", "glsl")
#define X_PI   3.14159265359
#define X_2_PI 6.28318530718

/// @return x^2
#define xPow2(x) ((x) * (x))

/// @return x^3
#define xPow3(x) ((x) * (x) * (x))

/// @return x^4
#define xPow4(x) ((x) * (x) * (x) * (x))

/// @return x^5
#define xPow5(x) ((x) * (x) * (x) * (x) * (x))

/// @return arctan2(x,y)
#define xAtan2(x, y) atan(y, x)

/// @return Direction from point `from` to point `to` in degrees (0-360 range).
float xPointDirection(vec2 from, vec2 to)
{
	float x = xAtan2(from.x - to.x, from.y - to.y);
	return ((x > 0.0) ? x : (2.0 * X_PI + x)) * 180.0 / X_PI;
}

/// @param dir A sampling direction in world space.
/// @return UV coordinates on an equirectangular map.
vec2 xVec3ToEquirectangularUv(vec3 dir)
{
	vec3 n = normalize(dir);
	return vec2((xAtan2(n.x, n.y) / X_2_PI) + 0.5, acos(n.z) / X_PI);
}
// include("EquirectangularMapping.xsh")

#pragma include("RGBM.xsh", "glsl")
/// @note Input color should be in gamma space.
/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec4 xEncodeRGBM(vec3 color)
{
	vec4 rgbm;
	color *= 1.0 / 6.0;
	rgbm.a = clamp(max(max(color.r, color.g), max(color.b, 0.000001)), 0.0, 1.0);
	rgbm.a = ceil(rgbm.a * 255.0) / 255.0;
	rgbm.rgb = color / rgbm.a;
	return rgbm;
}

/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec3 xDecodeRGBM(vec4 rgbm)
{
	return 6.0 * rgbm.rgb * rgbm.a;
}
// include("RGBM.xsh")

#pragma include("Color.xsh", "glsl")
#define X_GAMMA 2.2

/// @desc Converts gamma space color to linear space.
vec3 xGammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(X_GAMMA));
}

/// @desc Converts linear space color to gamma space.
vec3 xLinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / X_GAMMA));
}

/// @desc Gets color's luminance.
float xLuminance(vec3 rgb)
{
	return (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
}
// include("Color.xsh")

void main()
{
	gl_FragColor.rgb = xGammaToLinear(xDecodeRGBM(texture2D(gm_BaseTexture, xVec3ToEquirectangularUv(v_vNormal))));
	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * u_fExposure);
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
	gl_FragColor.a = 1.0;
}