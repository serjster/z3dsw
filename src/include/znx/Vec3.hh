#pragma once
#include <array>
#include <cassert>
#include <cstddef>
#include <tuple>
#include <type_traits>

#include <znx/export.hh>
#include <znx/linalg.hh>
#include <znx/types.hh>

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

	// Constants
	static const Vec3 ZERO;

	// Construction.
	constexpr Vec3() = default;
	constexpr Vec3(f32 x, f32 y, f32 z) : _data{x, y, z} {}

	// Utility
	[[nodiscard]] constexpr usize size() const { return _data.size(); }

	// Iteration
	[[nodiscard]] constexpr auto begin() { return _data.begin(); }
	[[nodiscard]] constexpr auto end() { return _data.end(); }
	[[nodiscard]] constexpr auto begin() const { return _data.begin(); }
	[[nodiscard]] constexpr auto end() const { return _data.end(); }

	// Operator overloads
	constexpr f32& operator[](const usize i) {
		assert(i < 3);
		return _data[i];
	}
	constexpr const f32& operator[](const usize i) const {
		assert(i < 3);
		return _data[i];
	}
};

inline constexpr Vec3 Vec3::ZERO{};

// Structured bindings (tuple protocol): `auto [x, y, z] = v;` or `auto& [x, y, z] = v;`.
template <usize I>
[[nodiscard]] constexpr f32& get(Vec3& v) {
	static_assert(I < 3, "Vec3 element index out of range");
	return v._data[I];
}

template <usize I>
[[nodiscard]] constexpr const f32& get(const Vec3& v) {
	static_assert(I < 3, "Vec3 element index out of range");
	return v._data[I];
}

template <usize I>
[[nodiscard]] constexpr f32&&
get(Vec3&& v) { // NOLINT(cppcoreguidelines-rvalue-reference-param-not-moved)
	static_assert(I < 3, "Vec3 element index out of range");
	return std::move(v._data[I]);
}

template <usize I>
[[nodiscard]] constexpr const f32&& get(const Vec3&& v) {
	static_assert(I < 3, "Vec3 element index out of range");
	return std::move(v._data[I]);
}

} // namespace znx

namespace std {
template <>
struct tuple_size<znx::Vec3> : integral_constant<size_t, 3> {};

template <size_t I>
struct tuple_element<I, znx::Vec3> : type_identity<znx::f32> {
	static_assert(I < 3, "Vec3 element index out of range");
};
} // namespace std
