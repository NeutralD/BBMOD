#pragma once

#include <BBMOD/Config.hpp>
#include <BBMOD/VertexFormat.hpp>

#include <assimp/vector2.h>
#include <assimp/vector3.h>

#include <vector>
#include <fstream>

struct SVertex
{
	SVertex()
		: Position(aiVector3D())
		, Normal(aiVector3D())
		, Texture(aiVector2D())
		, Tangent(aiVector3D())
	{
	}
	
	bool Save(std::ofstream& file);

	SVertexFormat* VertexFormat = nullptr;
	aiVector3D Position;
	aiVector3D Normal;
	aiVector2D Texture;
	uint32_t Color = 0;
	aiVector3D Tangent;
	float BitangentSign = 1.0;
	float Bones[4] = { 0.0f, 0.0f, 0.0f, 0.0f };
	float Weights[4] = { 0.0f, 0.0f, 0.0f, 0.0f };
	int Id = 0;
};

struct SMesh
{
	static SMesh* FromAssimp(struct aiMesh* mesh, struct SModel* model, const struct SConfig& config);

	bool Save(std::ofstream& file);

	SVertexFormat* VertexFormat = nullptr;

	size_t MaterialIndex = 0;

	std::vector<SVertex*> Data;
};
