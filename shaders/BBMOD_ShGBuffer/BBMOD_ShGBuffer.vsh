struct VS_in
{
	float4 Position : POSITION0;
	float3 Normal   : NORMAL0;
	float2 TexCoord : TEXCOORD0;
	float4 TangentW : TEXCOORD1;
};

struct VS_out
{
	float4 Position  : SV_POSITION;
	float3 Normal    : NORMAL0;
	float3 Tangent   : TANGENT0;
	float3 Bitangent : BINORMAL0;
	float2 TexCoord  : TEXCOORD0;
};

void main(in VS_in IN, out VS_out OUT)
{
	OUT.Position  = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], IN.Position);
	OUT.Normal    = normalize(mul(gm_Matrices[MATRIX_WORLD], float4(IN.Normal, 0.0)).xyz);
	OUT.Tangent   = normalize(mul(gm_Matrices[MATRIX_WORLD], float4(IN.TangentW.xyz, 0.0)).xyz);
	OUT.Bitangent = normalize(mul(gm_Matrices[MATRIX_WORLD],
		normalize(float4(cross(IN.Normal, IN.TangentW.xyz) * IN.TangentW.w, 0.0))).xyz);
	OUT.TexCoord  = IN.TexCoord;
}