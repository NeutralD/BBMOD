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

#pragma include("LogLUV.xsh", "glsl")
// Source: http://graphicrants.blogspot.com/2009/04/rgbm-color-encoding.html

const mat3 xMatrixLogLuvEncode = mat3(
	0.2209, 0.3390, 0.4184,
	0.1138, 0.6780, 0.7319,
	0.0102, 0.1130, 0.2969);

const mat3 xMatrixLogLuvDecode = mat3(
	6.0014, -2.7008, -1.7996,
	-1.3320, 3.1029, -5.7721,
	0.3008, -1.0882, 5.6268);

/// @desc Encodes RGB color to LogLUV.
vec4 xEncodeLogLuv(vec3 vRGB)
{
	vec4 vResult;
	vec3 Xp_Y_XYZp = xMatrixLogLuvEncode * vRGB;
	Xp_Y_XYZp = max(Xp_Y_XYZp, vec3(1e-6, 1e-6, 1e-6));
	vResult.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
	float Le = 2.0 * log2(Xp_Y_XYZp.y) + 127.0;
	vResult.w = fract(Le);
	vResult.z = (Le - (floor(vResult.w * 255.0)) / 255.0) / 255.0;
	return vResult;
}

/// @desc Decodes RGB color from LogLUV.
vec3 xDecodeLogLuv(vec4 vLogLuv)
{
	float Le = vLogLuv.z * 255.0 + vLogLuv.w;
	vec3 Xp_Y_XYZp;
	Xp_Y_XYZp.y = exp2((Le - 127.0) / 2.0);
	Xp_Y_XYZp.z = Xp_Y_XYZp.y / vLogLuv.y;
	Xp_Y_XYZp.x = vLogLuv.x * Xp_Y_XYZp.z;
	vec3 vRGB = xMatrixLogLuvDecode * Xp_Y_XYZp;
	return max(vRGB, vec3(0.0, 0.0, 0.0));
}
// include("LogLUV.xsh")

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
	gl_FragColor.rgb = xDecodeLogLuv(texture2D(gm_BaseTexture, xVec3ToEquirectangularUv(v_vNormal)));
	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * u_fExposure);
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
	gl_FragColor.a = 1.0;
}