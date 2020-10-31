struct VS_out
{
	float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD0;
};

struct PS_out
{
	float4 Color : SV_TARGET0;
};

#define texGB0 gm_BaseTextureObject
Texture2D texGB1 : register(t1);
Texture2D texGB2 : register(t2);
Texture2D texGB3 : register(t3);

uniform float4x4 u_mInverse;
uniform float u_fZFar;
uniform float u_fExposure;
uniform float3 u_vCamPos;
uniform float2 u_vTanAspect;
uniform float3 u_vLightDir;
uniform float4 u_vLightCol;

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
#pragma include("Projecting.xsh", "hlsl11")
/// @param tanAspect (tanFovY*(screenWidth/screenHeight),-tanFovY), where
///                  tanFovY = dtan(fov*0.5)
/// @param texCoord  Sceen-space UV.
/// @param depth     Scene depth at texCoord.
/// @return Point projected to view-space.
float3 xProject(float2 tanAspect, float2 texCoord, float depth)
{
	return float3(tanAspect * (texCoord * 2.0 - 1.0) * depth, depth);
}

/// @param p A point in clip space (transformed by projection matrix, but not
///          normalized).
/// @return P's UV coordinates on the screen.
float2 xUnproject(float4 p)
{
	float2 uv = p.xy / p.w;
	uv = uv * 0.5 + 0.5;
	uv.y = 1.0 - uv.y;
	return uv;
}
// include("Projecting.xsh")

#pragma include("BRDF.xsh", "hlsl11")
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
// include("BRDF.xsh")

#pragma include("CheapSubsurface.xsh", "hlsl11")
/// @param subsurface Color in RGB and thickness/intensity in A.
/// @source https://colinbarrebrisebois.com/2011/03/07/gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurface-scattering-look/
float3 xCheapSubsurface(float4 subsurface, float3 eye, float3 normal, float3 light, float3 lightColor)
{
	const float fLTPower = 1.0;
	const float fLTScale = 1.0;
	float3 vLTLight = light + normal;
	float fLTDot = pow(clamp(dot(eye, -vLTLight), 0.0, 1.0), fLTPower) * fLTScale;
	float fLT = fLTDot * subsurface.a;
	return subsurface.rgb * lightColor * fLT;
}
// include("CheapSubsurface.xsh")

#pragma include("RGBM.xsh", "hlsl11")
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
// include("RGBM.xsh")

#pragma include("Color.xsh", "hlsl11")
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
// include("Color.xsh")

/// @source https://www.shadertoy.com/view/lslGzl
float3 xUncharted2ToneMapping(float3 color, float exposure)
{
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	color *= exposure;
	color = ((color * (A * color + C * B) + D * E) / (color * (A * color + B) + D * F)) - E / F;
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	color /= white;
	return color;
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

void main(in VS_out IN, out PS_out OUT)
{
	////////////////////////////////////////////////////////////////////////////
	// Sample G-Buffer
	float4 GB1 = texGB1.Sample(gm_BaseTexture, IN.TexCoord);
	if (dot(GB1.xyz, 1.0) == 0.0)
	{
		discard;
	}

	float4 GB0 = texGB0.Sample(gm_BaseTexture, IN.TexCoord);
	float4 GB2 = texGB2.Sample(gm_BaseTexture, IN.TexCoord);
	float4 GB3 = texGB3.Sample(gm_BaseTexture, IN.TexCoord);

	float depth = xDecodeDepth(GB0.rgb) * u_fZFar;
	float3 posView = xProject(u_vTanAspect, IN.TexCoord, depth);
	float3 posWorld = mul(u_mInverse, float4(posView, 1.0)).xyz;
	float3 V = normalize(u_vCamPos - posWorld);

	////////////////////////////////////////////////////////////////////////////
	// Get material properties
	Material material;

	material.AO = GB0.a;

	material.Normal = normalize(GB1.rgb * 2.0 - 1.0);
	material.Roughness = GB1.a;

	material.Base = GB2.rgb;

	material.Subsurface = 0.0;
	material.Metallic = 0.0;

	int i = int(GB2.a * 255.0);

	if (i & 1)
	{
		material.Metallic = float(i >> 1) / 127.0;
	}
	else
	{
		material.Subsurface.rgb = material.Base;
		material.Subsurface.a = float(i >> 1) / 127.0;
	}

	material.Specular = lerp(X_F0_DEFAULT, material.Base, material.Metallic);

	material.Emissive = xGammaToLinear(xDecodeRGBM(GB3));
	////////////////////////////////////////////////////////////////////////////
	float3 lightColor = u_vLightCol.rgb * u_vLightCol.a;

	float3 diffuse = 0.0;
	float3 specular = 0.0;

	float3 N = material.Normal;
	float3 L = -normalize(u_vLightDir);
	float NdotL = saturate(dot(N, L));

	if (NdotL > 0.0)
	{
		diffuse += lightColor * NdotL;

		float3 H = normalize(L + V);
		float NdotV = saturate(dot(N, V));
		float NdotH = saturate(dot(N, H));
		float VdotH = saturate(dot(V, H));

		float3 brdf = xBRDF(material.Specular, material.Roughness, NdotL, NdotV, NdotH, VdotH);
		specular += lightColor * brdf * NdotL;
	}

	OUT.Color.rgb = 0.0;
	OUT.Color.a = 1.0;

	// Diffuse
	OUT.Color.rgb = material.Base * diffuse;
	// Specular
	OUT.Color.rgb += specular;
	// Ambient occlusion
	OUT.Color.rgb *= material.AO;
	// Emissive
	OUT.Color.rgb += material.Emissive;
	// Subsurface scattering
	OUT.Color.rgb += xCheapSubsurface(material.Subsurface, -V, N, -L, lightColor);
	// Tone mapping
	OUT.Color.rgb = xUncharted2ToneMapping(OUT.Color.rgb, u_fExposure);
	// Gamma correction
	OUT.Color.rgb = xLinearToGamma(OUT.Color.rgb);
}