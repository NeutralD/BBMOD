#include <BBMOD/Animation.hpp>
#include <utils.hpp>

SAnimation* SAnimation::FromAssimp(aiAnimation* aiAnimation, SModel* model)
{
	SAnimation* animation = new SAnimation();

	animation->Model = model;
	animation->Name = aiAnimation->mName.C_Str();
	animation->Duration = aiAnimation->mDuration;
	animation->TicsPerSecond = aiAnimation->mTicksPerSecond;

	for (size_t i = 0; i < aiAnimation->mNumChannels; ++i)
	{
		aiNodeAnim* channel = aiAnimation->mChannels[i];

		SAnimationNode* animationNode = new SAnimationNode();
		SNode* node = model->FindNodeByName(channel->mNodeName.C_Str(), model->RootNode);
		if (!node)
		{
			return nullptr;
		}
		animationNode->Index = node->Index;
		
		for (size_t j = 0; j < channel->mNumPositionKeys; ++j)
		{
			aiVectorKey& key = channel->mPositionKeys[j];
			SPositionKey* positionKey = new SPositionKey();
			positionKey->Time = key.mTime;
			positionKey->Position = key.mValue;
			animationNode->PositionKeys.push_back(positionKey);
		}

		for (size_t j = 0; j < channel->mNumRotationKeys; ++j)
		{
			aiQuatKey& key = channel->mRotationKeys[j];
			SRotationKey* rotationKey = new SRotationKey();
			rotationKey->Time = key.mTime;
			rotationKey->Rotation = key.mValue;
			animationNode->RotationKeys.push_back(rotationKey);
		}

		animation->AnimationNodes.push_back(animationNode);
	}

	return animation;
}

bool SAnimationKey::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Time);
	return true;
}

bool SPositionKey::Save(std::ofstream& file)
{
	if (!SAnimationKey::Save(file))
	{
		return false;
	}
	FILE_WRITE_VEC3(file, Position);
	return true;
}

bool SRotationKey::Save(std::ofstream& file)
{
	if (!SAnimationKey::Save(file))
	{
		return false;
	}
	FILE_WRITE_QUAT(file, Rotation);
	return true;
}

bool SAnimationNode::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Index);

	size_t positionKeyCount = PositionKeys.size();
	FILE_WRITE_DATA(file, positionKeyCount);

	for (SPositionKey* key : PositionKeys)
	{
		if (!key->Save(file))
		{
			return false;
		}
	}

	size_t rotationKeyCount = RotationKeys.size();
	FILE_WRITE_DATA(file, rotationKeyCount);

	for (SRotationKey* key : RotationKeys)
	{
		if (!key->Save(file))
		{
			return false;
		}
	}

	return true;
}


bool SAnimation::Save(std::string path)
{
	std::ofstream file(path, std::ios::out | std::ios::binary);

	if (!file.is_open())
	{
		return false;
	}

	file.write("bbanim", sizeof(char) * 7);
	FILE_WRITE_DATA(file, Version);
	FILE_WRITE_DATA(file, Duration);
	FILE_WRITE_DATA(file, TicsPerSecond);

	size_t modelNodeCount = Model->NodeCount;
	FILE_WRITE_DATA(file, modelNodeCount);

	size_t affectedNodeCount = AnimationNodes.size();
	FILE_WRITE_DATA(file, affectedNodeCount);

	for (SAnimationNode* animationNode : AnimationNodes)
	{
		if (!animationNode->Save(file))
		{
			return true;
		}
	}

	file.flush();
	file.close();

	return true;
}
