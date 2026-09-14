#pragma once

#include <znx/types.hh>

namespace znx {

// ===========================================================================
// Arithmetic operators
//
// Conventions:
//   * compound assignment (`+= -= *= /=`) mutates the left operand and returns it
//     by reference so it can be chained.
//   * binary / unary operators return a new vector by value.
//   * the scalar overloads are component-wise (scalar broadcast).
//     `Scalar` is constrained to integral/floating point so these never collide
//     with the vector-vector overloads.
// ===========================================================================

/* ---- addition ---- */

// vector += vector
template <VectorLike T>
constexpr T& operator+=(T& a, const T& b) {
	for (usize i = 0; i < a.size(); ++i) {
		a[i] += b[i];
	}
	return a;
}

// vector += scalar
template <VectorLike T, typename Scalar>
	requires std::integral<Scalar> || std::floating_point<Scalar>
constexpr T& operator+=(T& v, Scalar s) {
	for (usize i = 0; i < v.size(); ++i) {
		v[i] += static_cast<std::remove_cvref_t<decltype(v[i])>>(s);
	}
	return v;
}

// vector + vector
template <VectorLike T>
[[nodiscard]] constexpr T operator+(const T& a, const T& b) {
	T w{a};
	w += b;
	return w;
}

/* ---- subtraction ---- */

// vector -= vector
template <VectorLike T>
constexpr T& operator-=(T& a, const T& b) {
	for (usize i = 0; i < a.size(); ++i) {
		a[i] -= b[i];
	}
	return a;
}

// vector -= scalar
template <VectorLike T, typename Scalar>
	requires std::integral<Scalar> || std::floating_point<Scalar>
constexpr T& operator-=(T& v, Scalar s) {
	return v += (-s);
}

// vector - vector
template <VectorLike T>
[[nodiscard]] constexpr T operator-(const T& a, const T& b) {
	T w{a};
	w -= b;
	return w;
}

// unary negation: -vector
template <VectorLike T>
[[nodiscard]] constexpr T operator-(const T& v) {
	T w{v};
	for (usize i = 0; i < w.size(); ++i) {
		w[i] = -w[i];
	}
	return w;
}

/* ---- multiplication (by a scalar) ---- */

// vector *= scalar
template <VectorLike T, typename Scalar>
	requires std::integral<Scalar> || std::floating_point<Scalar>
constexpr T& operator*=(T& v, Scalar s) {
	for (usize i = 0; i < v.size(); ++i) {
		v[i] *= static_cast<std::remove_cvref_t<decltype(v[i])>>(s);
	}
	return v;
}

// vector * scalar
template <VectorLike T, typename Scalar>
	requires std::integral<Scalar> || std::floating_point<Scalar>
[[nodiscard]] constexpr T operator*(const T& v, Scalar s) {
	T w{v};
	w *= s;
	return w;
}

// scalar * vector
template <VectorLike T, typename Scalar>
	requires std::integral<Scalar> || std::floating_point<Scalar>
[[nodiscard]] constexpr T operator*(Scalar s, const T& v) {
	return v * s;
}

/* ---- division (by a scalar) ---- */

// vector /= scalar
template <VectorLike T, typename Scalar>
	requires std::integral<Scalar> || std::floating_point<Scalar>
constexpr T& operator/=(T& v, Scalar s) {
	v *= (1 / cast<std::remove_cvref_t<decltype(v[0])>>(s));
	return v;
}

// ===========================================================================
// Products and norms
// ===========================================================================

/* ---- dot product ---- */

// a . b
template <VectorLike T>
[[nodiscard]] constexpr auto dot(const T& a, const T& b)
	-> std::remove_cvref_t<decltype(a[0])> {
	std::remove_cvref_t<decltype(a[0])> sum{};
	for (usize i = 0; i < a.size(); ++i) {
		sum += a[i] * b[i];
	}
	return sum;
}

// v . v (sum of squares)
template <VectorLike T>
[[nodiscard]] constexpr auto dot(const T& v) -> std::remove_cvref_t<decltype(v[0])> {
	return dot(v, v);
}

/* ---- magnitude ---- */

template <VectorLike T>
[[nodiscard]] auto mag(const T& v) -> std::remove_cvref_t<decltype(v[0])> {
	return SQRT(dot(v));
}

/* ---- normalization ---- */

// In place: mutates `v` and returns it.
template <VectorLike T>
T& normalize(T& v) {
	// TODO: what to do with div by zero
	v /= mag(v);
	return v;
}

// Returns a unit vector; leaves `v` unchanged.
template <VectorLike T>
[[nodiscard]] T normalized(const T& v) {
	// TODO: what to do with div by zero
	T w{v};
	w /= mag(v);
	return w;
}

} // namespace znx
