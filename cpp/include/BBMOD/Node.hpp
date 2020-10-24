#pragma once

#include <assimp/matrix4x4.h>

#include <string>
#include <vector>
#include <fstream>

struct SNode
{
	bool Save(std::ofstream& file);

	std::string Name;

	float Index = 0.0f;

	bool IsBone = false;

	aiMatrix4x4 TransformMatrix;

	std::vector<size_t> Meshes;

	std::vector<SNode*> Children;
};
