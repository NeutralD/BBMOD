#include <BBMOD/Bone.hpp>
#include <utils.hpp>

bool SBone::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Index);
	FILE_WRITE_MATRIX(file, OffsetMatrix);
	return true;
}
