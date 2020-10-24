#pragma once

#include <BBMOD/common.hpp>
#include <BBMOD/Model.hpp>

#include <assimp/vector3.h>
#include <assimp/quaternion.h>
#include <assimp/anim.h>

#include <vector>
#include <string>
#include <fstream>

struct SAnimationKey
{
	virtual bool Save(std::ofstream& file);

	double Time = 0.0;
};

struct SPositionKey : public SAnimationKey
{
	SPositionKey()
		: Position(aiVector3D())
		, SAnimationKey()
	{
	}

	bool Save(std::ofstream& file);

	aiVector3D Position;
};

struct SRotationKey : public SAnimationKey
{
	SRotationKey()
		: Rotation(aiQuaternion())
		, SAnimationKey()
	{
	}

	bool Save(std::ofstream& file);

	aiQuaternion Rotation;
};

struct SAnimationNode
{
	bool Save(std::ofstream& file);

	float Index = 0.0f;

	std::vector<SPositionKey*> PositionKeys;

	std::vector<SRotationKey*> RotationKeys;
};

struct SAnimation
{
	static SAnimation* FromAssimp(aiAnimation* animation, SModel* model, const struct SConfig& config);

	bool Save(std::string path);

	uint8_t Version = BBMOD_VERSION;

	std::string Name;

	double Duration = 0.0;

	double TicsPerSecond = 20.0;

	std::vector<SAnimationNode*> AnimationNodes;

	SModel* Model = nullptr;
};
