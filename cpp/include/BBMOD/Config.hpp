#pragma once

#include <BBMOD/common.hpp>

#include <assimp/matrix4x4.h>

/** A value used to tell that no normals should be generated
 * if the model doesn't have any. */
#define BBMOD_NORMALS_NONE 0

/** A value used to tell that flat normals should be generated
 * if the model doesn't have any. */
#define BBMOD_NORMALS_FLAT 1

/** A value used to tell that smooth normals should be generated
 * if the model doesn't have any. */
#define BBMOD_NORMALS_SMOOTH 2

/** Configuration structure. */
struct SConfig
{
	/** Convert data to left-handed. */
	bool LeftHanded = true;

	/** Invert vertex winding order. */
	bool InvertWinding = false;

	/** Disable saving vertex normals. This also automatically disable
	 * tangent vector and bitangent sign. */
	bool DisableNormals = false;

	/** Disable saving texture coordinates. */
	bool DisableTextureCoords = false;

	/** Disable saving vertex colors. */
	bool DisableVertexColors = true;

	/** Disable saving tangent vector and bitangent sign. */
	bool DisableTangentW = false;

	/** Disable saving bones and animations. */
	bool DisableBones = false;

	/** Flip texture coordinates horizontally. */
	bool FlipTextureHorizontally = false;

	/** Flip texture coordinates vertically. */
	bool FlipTextureVertically = true;

	/** Flip normal vectors. */
	bool FlipNormals = false;

	/**
	 * Configures generation of normal vectors.
	 * 
	 * @see BBMOD_NORMALS_NONE
	 * @see BBMOD_NORMALS_FLAT
	 * @see BBMOD_NORMALS_SMOOTH
	 */
	size_t GenNormals = BBMOD_NORMALS_SMOOTH;

	/** Global transformation of model and animation data. */
	aiMatrix4x4 Transform;
};
