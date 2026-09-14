#include <znx/Vec3.hh>

#include <cassert>
#include <cmath>

namespace znx {
Vec3::Vec3(const f32 x, const f32 y, const f32 z) : _data{x, y, z} {}

constexpr size_t Vec3::size() const { return _data.size(); }

f32& Vec3::operator[](size_t i) {
	assert(i < 3);
	return _data[i];
}

const f32& Vec3::operator[](size_t i) const {
	assert(i < 3);
	return _data[i];
}

template <>
f32 dot<Vec3>(const Vec3& a, const Vec3& b) {
	return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
}

template <>
f32 dot<Vec3>(const Vec3& v) {
	return (v.x * v.x) + (v.y * v.y) + (v.z * v.z);
}

} // namespace znx
