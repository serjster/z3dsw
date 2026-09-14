#pragma once

#include <cmath>
#include <concepts>
#include <cstddef>
#include <cstdint>
#include <limits>
#include <numbers>
#include <type_traits>
#include <utility>

namespace znx {

/* ---- aliases ---- */
// NOLINTBEGIN(readability-identifier-naming)

using u8 = std::uint8_t;
using u16 = std::uint16_t;
using u32 = std::uint32_t;
using u64 = std::uint64_t;
using usize = std::size_t;

using i8 = std::int8_t;
using i16 = std::int16_t;
using i32 = std::int32_t;
using i64 = std::int64_t;
using isize = std::ptrdiff_t;

#ifdef __SIZEOF_INT128__
using u128 = unsigned __int128;
using i128 = __int128;
#endif

using f32 = float;
using f64 = double;

inline constexpr f32 PI = std::numbers::pi_v<f32>;
inline constexpr f32 TAU = 2.0F * PI;
inline constexpr f32 E = std::numbers::e_v<f32>;
inline constexpr f32 PHI = std::numbers::phi_v<f32>;
inline constexpr f32 EPS = std::numeric_limits<f32>::epsilon();
inline constexpr f32 INF = std::numeric_limits<f32>::infinity();
inline constexpr f32 NaN = std::numeric_limits<f32>::quiet_NaN();

[[nodiscard]] inline f32 SQRT(f32 x) { return std::sqrtf(x); }
[[nodiscard]] inline f32 CBRT(f32 x) { return std::cbrtf(x); }
[[nodiscard]] inline f32 POW(f32 x, f32 y) { return std::powf(x, y); }
[[nodiscard]] inline f32 EXP(f32 x) { return std::expf(x); }
[[nodiscard]] inline f32 LOG(f32 x) { return std::logf(x); }
[[nodiscard]] inline f32 LOG2(f32 x) { return std::log2f(x); }
[[nodiscard]] inline f32 LOG10(f32 x) { return std::log10f(x); }
[[nodiscard]] inline f32 SIN(f32 x) { return std::sinf(x); }
[[nodiscard]] inline f32 COS(f32 x) { return std::cosf(x); }
[[nodiscard]] inline f32 TAN(f32 x) { return std::tanf(x); }
[[nodiscard]] inline f32 ASIN(f32 x) { return std::asinf(x); }
[[nodiscard]] inline f32 ACOS(f32 x) { return std::acosf(x); }
[[nodiscard]] inline f32 ATAN(f32 x) { return std::atanf(x); }
[[nodiscard]] inline f32 ATAN2(f32 y, f32 x) { return std::atan2f(y, x); }
[[nodiscard]] inline f32 ABS(f32 x) { return std::fabsf(x); }
[[nodiscard]] inline f32 FLOOR(f32 x) { return std::floorf(x); }
[[nodiscard]] inline f32 CEIL(f32 x) { return std::ceilf(x); }
[[nodiscard]] inline f32 ROUND(f32 x) { return std::roundf(x); }
[[nodiscard]] inline f32 TRUNC(f32 x) { return std::truncf(x); }
[[nodiscard]] inline f32 FMA(f32 a, f32 b, f32 c) { return std::fmaf(a, b, c); }

template <typename T>
[[nodiscard]] constexpr T MIN(T a, T b) {
	return a < b ? a : b;
}
template <typename T>
[[nodiscard]] constexpr T MAX(T a, T b) {
	return a > b ? a : b;
}
template <typename T>
[[nodiscard]] constexpr T CLAMP(T x, T lo, T hi) {
	return MIN(MAX(x, lo), hi);
}
template <typename T>
[[nodiscard]] constexpr T LERP(T a, T b, T t) {
	return a + ((b - a) * t);
}

[[nodiscard]] constexpr f32 DEG2RAD(f32 deg) { return deg * (PI / 180.0F); }
[[nodiscard]] constexpr f32 RAD2DEG(f32 rad) { return rad * (180.0F / PI); }

// NOLINTEND(readability-identifier-naming)

/* ---- casts ---- */
// Short, type-safe replacement for static_cast<>: cast<f32>(x), cast<i32>(y), ...
// (GSL calls this narrow_cast; it is value-preserving only if the target can hold it.)
template <typename To, typename From>
[[nodiscard]] constexpr To cast(From&& from) {
	return static_cast<To>(std::forward<From>(from));
}

/* ---- concepts ---- */
template <typename T>
concept VectorLike = requires(const T& v, size_t i) {
	{ v.size() } -> std::convertible_to<size_t>;
	requires std::floating_point<std::remove_cvref_t<decltype(v[i])>>;
};
} // namespace znx
