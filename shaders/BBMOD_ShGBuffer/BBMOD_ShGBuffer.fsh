struct VS_out
{
	float4 Position  : SV_POSITION;
	float3 Normal    : NORMAL0;
	float3 Tangent   : TANGENT0;
	float3 Bitangent : BINORMAL0;
	float2 TexCoord  : TEXCOORD0;
};

struct PS_out
{
	float4 GB0 : SV_TARGET0;
	float4 GB1 : SV_TARGET1;
	float4 GB2 : SV_TARGET2;
	float4 GB3 : SV_TARGET3;
};

// RGB: Base color, A: Opacity
#define texBaseOpacity gm_BaseTextureObject

// RGB: Tangent space normal, A: Roughness
Texture2D texNormalRoughness : register(t1);

// R: Metallic, G: Ambient occlusion
Texture2D texMetallicAO : register(t2);

// RGB: Subsurface color, A: Intensity
Texture2D texSubsurface : register(t3);

// RGBM encoded emissive color
Texture2D texEmissive : register(t4);

Texture2D texBestFitNormals : register(t5);

// Pixels with alpha less than this value will be discarded.
uniform float u_fAlphaTest;

// Distance to the far clipping plane.
uniform float u_fZFar;

#pragma include("Material.xsh", "hlsl11")
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
#define xAtan2(x, y) atan2(x, y)

/// @return Direction from point `from` to point `to` in degrees (0-360 range).
float xPointDirection(float2 from, float2 to)
{
	float x = xAtan2(from.x - to.x, from.y - to.y);
	return ((x > 0.0) ? x : (2.0 * X_PI + x)) * 180.0 / X_PI;
}

/// @desc Default specular color for dielectrics
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
#define X_F0_DEFAULT float3(0.04, 0.04, 0.04)

/// @desc Normal distribution function
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularD_GGX(float roughness, float NdotH)
{
	float r = xPow4(roughness);
	float a = NdotH * NdotH * (r - 1.0) + 1.0;
	return r / (X_PI * a * a);
}

/// @desc Roughness remapping for analytic lights.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xK_Analytic(float roughness)
{
	return xPow2(roughness + 1.0) * 0.125;
}

/// @desc Roughness remapping for IBL lights.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xK_IBL(float roughness)
{
	return xPow2(roughness) * 0.5;
}

/// @desc Geometric attenuation
/// @param k Use either xK_Analytic for analytic lights or xK_IBL for image based lighting.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularG_Schlick(float k, float NdotL, float NdotV)
{
	return (NdotL / (NdotL * (1.0 - k) + k))
		* (NdotV / (NdotV * (1.0 - k) + k));
}

/// @desc Fresnel
/// @source https://en.wikipedia.org/wiki/Schlick%27s_approximation
float3 xSpecularF_Schlick(float3 f0, float VdotH)
{
	return f0 + (1.0 - f0) * xPow5(1.0 - VdotH); 
}

/// @desc Cook-Torrance microfacet specular shading
/// @note N = normalize(vertexNormal)
///       L = normalize(light - vertex)
///       V = normalize(camera - vertex)
///       H = normalize(L + V)
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float3 xBRDF(float3 f0, float roughness, float NdotL, float NdotV, float NdotH, float VdotH)
{
	float3 specular = xSpecularD_GGX(roughness, NdotH)
		* xSpecularF_Schlick(f0, VdotH)
		* xSpecularG_Schlick(xK_Analytic(roughness), NdotL, NdotH);
	return specular / max(4.0 * NdotL * NdotV, 0.001);
}
#define X_GAMMA 2.2

/// @desc Converts gamma space color to linear space.
float3 xGammaToLinear(float3 rgb)
{
	return pow(rgb, X_GAMMA);
}

/// @desc Converts linear space color to gamma space.
float3 xLinearToGamma(float3 rgb)
{
	return pow(rgb, 1.0 / X_GAMMA);
}

/// @desc Gets color's luminance.
float xLuminance(float3 rgb)
{
	return (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
}
/// @note Input color should be in gamma space.
/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
float4 xEncodeRGBM(float3 color)
{
	float4 rgbm;
	color *= 1.0 / 6.0;
	rgbm.a = clamp(max(max(color.r, color.g), max(color.b, 0.000001)), 0.0, 1.0);
	rgbm.a = ceil(rgbm.a * 255.0) / 255.0;
	rgbm.rgb = color / rgbm.a;
	return rgbm;
}

/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
float3 xDecodeRGBM(float4 rgbm)
{
	return 6.0 * rgbm.rgb * rgbm.a;
}

struct Material
{
	float3 Base;
	float Opacity;
	float3 Normal;
	float Roughness;
	float Metallic;
	float AO;
	float4 Subsurface;
	float3 Emissive;
	float3 Specular;
};

Material UnpackMaterial(
	Texture2D texBaseOpacity,
	Texture2D texNormalRoughness,
	Texture2D texMetallicAO,
	Texture2D texSubsurface,
	Texture2D texEmissive,
	float3x3 tbn,
	float2 uv)
{
	float4 baseOpacity = texBaseOpacity.Sample(gm_BaseTexture, uv);
	float3 base = xGammaToLinear(baseOpacity.rgb);
	float opacity = baseOpacity.a;

	float4 normalRoughness = texNormalRoughness.Sample(gm_BaseTexture, uv);
	float3 normal = mul(normalRoughness.rgb * 2.0 - 1.0, tbn);
	float roughness = lerp(0.1, 0.9, normalRoughness.a);

	float4 metallicAO = texMetallicAO.Sample(gm_BaseTexture, uv);
	float metallic = metallicAO.r;
	float AO = metallicAO.g;

	float4 subsurface = texSubsurface.Sample(gm_BaseTexture, uv);
	subsurface.rgb = xGammaToLinear(subsurface.rgb);

	float3 emissive = xGammaToLinear(xDecodeRGBM(texEmissive.Sample(gm_BaseTexture, uv)));

	float3 specular = lerp(X_F0_DEFAULT, base, metallic);
	base *= (1.0 - metallic);

	Material material;
	material.Base = base;
	material.Opacity = opacity;
	material.Normal = normal;
	material.Roughness = roughness;
	material.Metallic = metallic;
	material.AO = AO;
	material.Subsurface = subsurface;
	material.Emissive = emissive;
	material.Specular = specular;
	return material;
}
// include("Material.xsh")

#pragma include("DepthEncoding.xsh", "hlsl11")
/// @param d Linearized depth to encode.
/// @return Encoded depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float3 xEncodeDepth(float d)
{
	const float inv255 = 1.0 / 255.0;
	float3 enc;
	enc.x = d;
	enc.y = d * 255.0;
	enc.z = enc.y * 255.0;
	enc = frac(enc);
	float temp = enc.z * inv255;
	enc.x -= enc.y * inv255;
	enc.y -= temp;
	enc.z -= temp;
	return enc;
}

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(float3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}
// include("DepthEncoding.xsh")

#pragma include("BestFitNormals.xsh", "hlsl11")
/// @source http://advances.realtimerendering.com/s2010/Kaplanyan-CryEngine3(SIGGRAPH%202010%20Advanced%20RealTime%20Rendering%20Course).pdf
float3 xBestFitNormal(float3 normal, Texture2D tex)
{
	normal = normalize(normal);
	float3 normalUns = abs(normal);
	float maxNAbs = max(max(normalUns.x, normalUns.y), normalUns.z);
	float2 texCoord = normalUns.z < maxNAbs ? (normalUns.y < maxNAbs ? normalUns.yz : normalUns.xz) : normalUns.xy;
	texCoord = texCoord.x < texCoord.y ? texCoord.yx : texCoord.xy;
	texCoord.y /= texCoord.x;
	normal /= maxNAbs;
	float fittingScale = tex.Sample(gm_BaseTexture, texCoord).r;
	return normal * fittingScale;
}
// include("BestFitNormals.xsh")

void main(in VS_out IN, out PS_out OUT)
{
	float3x3 TBN = float3x3(IN.Tangent, IN.Bitangent, IN.Normal);

	Material material = UnpackMaterial(
		texBaseOpacity,
		texNormalRoughness,
		texMetallicAO,
		texSubsurface,
		texEmissive,
		TBN,
		IN.TexCoord);

	if (material.Opacity < u_fAlphaTest)
	{
		discard;
	}

	OUT.GB0.rgb = xEncodeDepth(IN.Position.w / u_fZFar);
	OUT.GB0.a = material.AO;

	OUT.GB1.rgb = xBestFitNormal(material.Normal, texBestFitNormals) * 0.5 + 0.5;
	OUT.GB1.a = material.Roughness;

	OUT.GB2.rgb = material.Base;
	OUT.GB2.a = float((material.Metallic > material.Subsurface.a)
		? ((int(material.Metallic * 127) << 1) | 1)
		: ((int(material.Subsurface.a * 127) << 1) | 0)) / 255.0;

	OUT.GB3 = xEncodeRGBM(xLinearToGamma(material.Emissive));
}