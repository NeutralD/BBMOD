#pragma once

#include <algorithm>
#include <cstring>
#include <iostream>

typedef float matrix_t[16];

#define MATRIX_IDENTITY \
	{ 1.0f, 0.0f, 0.0f, 0.0f, \
	  0.0f, 1.0f, 0.0f, 0.0f, \
	  0.0f, 0.0f, 1.0f, 0.0f, \
	  0.0f, 0.0f, 0.0f, 1.0f }

#define matrix_copy(from, to) \
	std::memcpy(to, from, sizeof(float) * 16)

static inline void matrix_print(const matrix_t m)
{
	for (size_t i = 0; i < 16; ++i)
	{
		std::cout << m[i] << ", ";
	}
	std::cout << std::endl;
}

static inline float matrix_determinant(const matrix_t m)
{
	return (0
		+ (m[3] * m[6] * m[9] * m[12]) - (m[2] * m[7] * m[9] * m[12]) - (m[3] * m[5] * m[10] * m[12]) + (m[1] * m[7] * m[10] * m[12])
		+ (m[2] * m[5] * m[11] * m[12]) - (m[1] * m[6] * m[11] * m[12]) - (m[3] * m[6] * m[8] * m[13]) + (m[2] * m[7] * m[8] * m[13])
		+ (m[3] * m[4] * m[10] * m[13]) - (m[0] * m[7] * m[10] * m[13]) - (m[2] * m[4] * m[11] * m[13]) + (m[0] * m[6] * m[11] * m[13])
		+ (m[3] * m[5] * m[8] * m[14]) - (m[1] * m[7] * m[8] * m[14]) - (m[3] * m[4] * m[9] * m[14]) + (m[0] * m[7] * m[9] * m[14])
		+ (m[1] * m[4] * m[11] * m[14]) - (m[0] * m[5] * m[11] * m[14]) - (m[2] * m[5] * m[8] * m[15]) + (m[1] * m[6] * m[8] * m[15])
		+ (m[2] * m[4] * m[9] * m[15]) - (m[0] * m[6] * m[9] * m[15]) - (m[1] * m[4] * m[10] * m[15]) + (m[0] * m[5] * m[10] * m[15]));
}

static inline void matrix_inverse(matrix_t m)
{
	static matrix_t n;
	matrix_copy(m, n);
	float s = 1.0f / matrix_determinant(m);
	m[0] = s * ((n[6] * n[11] * n[13]) - (n[7] * n[10] * n[13]) + (n[7] * n[9] * n[14]) - (n[5] * n[11] * n[14]) - (n[6] * n[9] * n[15]) + (n[5] * n[10] * n[15]));
	m[1] = s * ((n[3] * n[10] * n[13]) - (n[2] * n[11] * n[13]) - (n[3] * n[9] * n[14]) + (n[1] * n[11] * n[14]) + (n[2] * n[9] * n[15]) - (n[1] * n[10] * n[15]));
	m[2] = s * ((n[2] * n[7] * n[13]) - (n[3] * n[6] * n[13]) + (n[3] * n[5] * n[14]) - (n[1] * n[7] * n[14]) - (n[2] * n[5] * n[15]) + (n[1] * n[6] * n[15]));
	m[3] = s * ((n[3] * n[6] * n[9]) - (n[2] * n[7] * n[9]) - (n[3] * n[5] * n[10]) + (n[1] * n[7] * n[10]) + (n[2] * n[5] * n[11]) - (n[1] * n[6] * n[11]));
	m[4] = s * ((n[7] * n[10] * n[12]) - (n[6] * n[11] * n[12]) - (n[7] * n[8] * n[14]) + (n[4] * n[11] * n[14]) + (n[6] * n[8] * n[15]) - (n[4] * n[10] * n[15]));
	m[5] = s * ((n[2] * n[11] * n[12]) - (n[3] * n[10] * n[12]) + (n[3] * n[8] * n[14]) - (n[0] * n[11] * n[14]) - (n[2] * n[8] * n[15]) + (n[0] * n[10] * n[15]));
	m[6] = s * ((n[3] * n[6] * n[12]) - (n[2] * n[7] * n[12]) - (n[3] * n[4] * n[14]) + (n[0] * n[7] * n[14]) + (n[2] * n[4] * n[15]) - (n[0] * n[6] * n[15]));
	m[7] = s * ((n[2] * n[7] * n[8]) - (n[3] * n[6] * n[8]) + (n[3] * n[4] * n[10]) - (n[0] * n[7] * n[10]) - (n[2] * n[4] * n[11]) + (n[0] * n[6] * n[11]));
	m[8] = s * ((n[5] * n[11] * n[12]) - (n[7] * n[9] * n[12]) + (n[7] * n[8] * n[13]) - (n[4] * n[11] * n[13]) - (n[5] * n[8] * n[15]) + (n[4] * n[9] * n[15]));
	m[9] = s * ((n[3] * n[9] * n[12]) - (n[1] * n[11] * n[12]) - (n[3] * n[8] * n[13]) + (n[0] * n[11] * n[13]) + (n[1] * n[8] * n[15]) - (n[0] * n[9] * n[15]));
	m[10] = s * ((n[1] * n[7] * n[12]) - (n[3] * n[5] * n[12]) + (n[3] * n[4] * n[13]) - (n[0] * n[7] * n[13]) - (n[1] * n[4] * n[15]) + (n[0] * n[5] * n[15]));
	m[11] = s * ((n[3] * n[5] * n[8]) - (n[1] * n[7] * n[8]) - (n[3] * n[4] * n[9]) + (n[0] * n[7] * n[9]) + (n[1] * n[4] * n[11]) - (n[0] * n[5] * n[11]));
	m[12] = s * ((n[6] * n[9] * n[12]) - (n[5] * n[10] * n[12]) - (n[6] * n[8] * n[13]) + (n[4] * n[10] * n[13]) + (n[5] * n[8] * n[14]) - (n[4] * n[9] * n[14]));
	m[13] = s * ((n[1] * n[10] * n[12]) - (n[2] * n[9] * n[12]) + (n[2] * n[8] * n[13]) - (n[0] * n[10] * n[13]) - (n[1] * n[8] * n[14]) + (n[0] * n[9] * n[14]));
	m[14] = s * ((n[2] * n[5] * n[12]) - (n[1] * n[6] * n[12]) - (n[2] * n[4] * n[13]) + (n[0] * n[6] * n[13]) + (n[1] * n[4] * n[14]) - (n[0] * n[5] * n[14]));
	m[15] = s * ((n[1] * n[6] * n[8]) - (n[2] * n[5] * n[8]) + (n[2] * n[4] * n[9]) - (n[0] * n[6] * n[9]) - (n[1] * n[4] * n[10]) + (n[0] * n[5] * n[10]));
}

static inline void matrix_transpose(matrix_t m)
{
	std::swap(m[1], m[4]);
	std::swap(m[2], m[8]);
	std::swap(m[3], m[12]);
	std::swap(m[6], m[9]);
	std::swap(m[7], m[13]);
	std::swap(m[11], m[14]);
}

static inline void matrix_multiply(matrix_t m1, const matrix_t m2)
{
	static matrix_t _m1;
	matrix_copy(m1, _m1);

	m1[0] = (_m1[0] * m2[0]) + (_m1[1] * m2[4]) + (_m1[2] * m2[8]) + (_m1[3] * m2[12]);
	m1[4] = (_m1[4] * m2[0]) + (_m1[5] * m2[4]) + (_m1[6] * m2[8]) + (_m1[7] * m2[12]);
	m1[8] = (_m1[8] * m2[0]) + (_m1[9] * m2[4]) + (_m1[10] * m2[8]) + (_m1[11] * m2[12]);
	m1[12] = (_m1[12] * m2[0]) + (_m1[13] * m2[4]) + (_m1[14] * m2[8]) + (_m1[15] * m2[12]);

	m1[1] = (_m1[0] * m2[1]) + (_m1[1] * m2[5]) + (_m1[2] * m2[9]) + (_m1[3] * m2[13]);
	m1[5] = (_m1[4] * m2[1]) + (_m1[5] * m2[5]) + (_m1[6] * m2[9]) + (_m1[7] * m2[13]);
	m1[9] = (_m1[8] * m2[1]) + (_m1[9] * m2[5]) + (_m1[10] * m2[9]) + (_m1[11] * m2[13]);
	m1[13] = (_m1[12] * m2[1]) + (_m1[13] * m2[5]) + (_m1[14] * m2[9]) + (_m1[15] * m2[13]);

	m1[2] = (_m1[0] * m2[2]) + (_m1[1] * m2[6]) + (_m1[2] * m2[10]) + (_m1[3] * m2[14]);
	m1[6] = (_m1[4] * m2[2]) + (_m1[5] * m2[6]) + (_m1[6] * m2[10]) + (_m1[7] * m2[14]);
	m1[10] = (_m1[8] * m2[2]) + (_m1[9] * m2[6]) + (_m1[10] * m2[10]) + (_m1[11] * m2[14]);
	m1[14] = (_m1[12] * m2[2]) + (_m1[13] * m2[6]) + (_m1[14] * m2[10]) + (_m1[15] * m2[14]);

	m1[3] = (_m1[0] * m2[3]) + (_m1[1] * m2[7]) + (_m1[2] * m2[11]) + (_m1[3] * m2[15]);
	m1[7] = (_m1[4] * m2[3]) + (_m1[5] * m2[7]) + (_m1[6] * m2[11]) + (_m1[7] * m2[15]);
	m1[11] = (_m1[8] * m2[3]) + (_m1[9] * m2[7]) + (_m1[10] * m2[11]) + (_m1[11] * m2[15]);
	m1[15] = (_m1[12] * m2[3]) + (_m1[13] * m2[7]) + (_m1[14] * m2[11]) + (_m1[15] * m2[15]);
}
