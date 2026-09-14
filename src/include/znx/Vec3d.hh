#pragma once
#include <array>
#include <cstddef>

namespace znx {
class Vec3d {
private:
	std::array<float, 3> _data{};

public:
	Vec3d() = default;
	Vec3d(float x, float y, float z);

	float& operator[](size_t i);

	const float& operator[](size_t i) const;

	float& x = _data[0];
	float& y = _data[1];
	float& z = _data[2];
};
} // namespace znx
