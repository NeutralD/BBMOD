#pragma once

#include <fstream>

struct SVertexFormat
{
	bool Save(std::ofstream& file);

	bool Vertices = true;

	bool Normals = false;

	bool TextureCoords = false;

	bool Colors = false;

	bool TangentW = false;

	bool Bones = false;

	bool Ids = false;
};
