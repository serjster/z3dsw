#pragma once

#include <concepts>
#include <type_traits>

#include <znx/alias.hh>

namespace znx {
template <typename T>
concept VectorLike = requires(const T& v, size_t i) {
	{ v.size() } -> std::convertible_to<size_t>;
	requires std::floating_point<std::remove_cvref_t<decltype(v[i])>>;
};

template <VectorLike T>
[[nodiscard]] auto dot(const T& a, const T& b) -> std::remove_cvref_t<decltype(a[0])> {
	std::remove_cvref_t<decltype(a[0])> sum{};
	for (size_t i = 0; i < a.size(); ++i) {
		sum += a[i] * b[i];
	}
	return sum;
}

template <VectorLike T>
[[nodiscard]] auto dot(const T& v) -> std::remove_cvref_t<decltype(v[0])> {
	return dot(v, v);
}

template <VectorLike T>
[[nodiscard]] auto mag(const T& v) -> std::remove_cvref_t<decltype(v[0])> {
	return SQRT(dot(v));
}

} // namespace znx
