#include <znx/Vec3d.hh>

#include <cassert>

namespace znx {
Vec3d::Vec3d(const float x, const float y, const float z) : _data{x, y, z}, x(_data[0]), y(_data[1]), z(_data[2]) {}

float& Vec3d::operator[](size_t i) {
	assert(i < 3);
	return _data[i];
}

const float& Vec3d::operator[](size_t i) const {
	assert(i < 3);
	return _data[i];
}
} // namespace znx
