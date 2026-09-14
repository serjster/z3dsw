#pragma once
#include <array>

#include <znx/alias.hh>
#include <znx/export.hh>
#include <znx/vec.hh>

namespace znx {
struct ZNX_EXPORT Vec3 {
	union {
		std::array<f32, 3> _data{};
		struct {
			f32 x;
			f32 y;
			f32 z;
		};
	};

	// Construction.
	Vec3() = default;
	Vec3(f32 x, f32 y, f32 z);

	// Utility
	[[nodiscard]] constexpr size_t size() const;

	// Operator overloads
	f32& operator[](size_t i);
	const f32& operator[](size_t i) const;
};

template <>
[[nodiscard]] ZNX_EXPORT f32 dot<Vec3>(const Vec3& a, const Vec3& b);

template <>
[[nodiscard]] ZNX_EXPORT f32 dot<Vec3>(const Vec3& v);

} // namespace znx
