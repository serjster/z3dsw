#include <gtest/gtest.h>

#include <iterator>
#include <numeric>
#include <tuple>
#include <type_traits>

#include <znx/Vec3.hh>

using znx::f32;
using znx::Vec3;

static_assert(std::tuple_size_v<Vec3> == 3);
static_assert(std::is_same_v<std::tuple_element_t<0, Vec3>, f32>);

TEST(Vec3, DefaultIsZero) {
	const Vec3 v;
	EXPECT_FLOAT_EQ(v[0], 0.0F);
	EXPECT_FLOAT_EQ(v[1], 0.0F);
	EXPECT_FLOAT_EQ(v[2], 0.0F);
}

TEST(Vec3, ConstructAndIndex) {
	const Vec3 v{1.0F, 2.0F, 3.0F};
	EXPECT_FLOAT_EQ(v[0], 1.0F);
	EXPECT_FLOAT_EQ(v[1], 2.0F);
	EXPECT_FLOAT_EQ(v[2], 3.0F);
	EXPECT_EQ(v.size(), 3U);
}

TEST(Vec3, NamedComponents) {
	const Vec3 v{4.0F, 5.0F, 6.0F};
	EXPECT_FLOAT_EQ(v.x, 4.0F);
	EXPECT_FLOAT_EQ(v.y, 5.0F);
	EXPECT_FLOAT_EQ(v.z, 6.0F);
}

TEST(Vec3, MutableAccess) {
	Vec3 v;
	v[0] = 7.0F;
	v[2] = 9.0F;
	v.y = 8.0F;
	EXPECT_FLOAT_EQ(v[0], 7.0F);
	EXPECT_FLOAT_EQ(v[1], 8.0F);
	EXPECT_FLOAT_EQ(v[2], 9.0F);
}

TEST(Vec3, LayoutAndValueSemantics) {
	static_assert(std::is_trivially_copyable_v<Vec3>);
	EXPECT_EQ(sizeof(Vec3), 3U * sizeof(f32));

	Vec3 a{1.0F, 2.0F, 3.0F};
	Vec3 b;
	b = a;
	b[0] = 9.0F;
	EXPECT_FLOAT_EQ(a[0], 1.0F); // copy is independent
	EXPECT_FLOAT_EQ(b[0], 9.0F);
}

TEST(Vec3, ZeroConstant) {
	EXPECT_FLOAT_EQ(Vec3::ZERO[0], 0.0F);
	EXPECT_FLOAT_EQ(Vec3::ZERO.x, 0.0F);
	EXPECT_FLOAT_EQ(Vec3::ZERO.y, 0.0F);
	EXPECT_FLOAT_EQ(Vec3::ZERO.z, 0.0F);
}

TEST(Vec3, RangeForSum) {
	const Vec3 v{1.0F, 2.0F, 3.0F};
	f32 sum = 0.0F;
	for (const f32 c : v) {
		sum += c;
	}
	EXPECT_FLOAT_EQ(sum, 6.0F);
}

TEST(Vec3, RangeForMutates) {
	Vec3 v{1.0F, 2.0F, 3.0F};
	for (f32& c : v) {
		c *= 10.0F;
	}
	EXPECT_FLOAT_EQ(v[0], 10.0F);
	EXPECT_FLOAT_EQ(v[1], 20.0F);
	EXPECT_FLOAT_EQ(v[2], 30.0F);
}

TEST(Vec3, IteratorsWithStl) {
	const Vec3 v{1.0F, 2.0F, 3.0F};
	EXPECT_FLOAT_EQ(std::accumulate(v.begin(), v.end(), 0.0F), 6.0F);
	EXPECT_EQ(std::distance(v.begin(), v.end()), 3);
}

TEST(Vec3, StructuredBindingsReference) {
	Vec3 v{1.0F, 2.0F, 3.0F};
	auto& [x, y, z] = v;
	x = 10.0F;
	z = 30.0F;
	EXPECT_FLOAT_EQ(v[0], 10.0F);
	EXPECT_FLOAT_EQ(v[1], 2.0F);
	EXPECT_FLOAT_EQ(v[2], 30.0F);
	EXPECT_FLOAT_EQ(y, 2.0F);
}

TEST(Vec3, StructuredBindingsCopy) {
	const Vec3 v{4.0F, 5.0F, 6.0F};
	auto [x, y, z] = v;
	EXPECT_FLOAT_EQ(x, 4.0F);
	EXPECT_FLOAT_EQ(y, 5.0F);
	EXPECT_FLOAT_EQ(z, 6.0F);
}

TEST(Vec3, ConstexprUsage) {
	constexpr Vec3 v{1.0F, 2.0F, 3.0F};
	static_assert(v[0] == 1.0F);
	static_assert(v[2] == 3.0F);
	static_assert(Vec3::ZERO[1] == 0.0F);
	EXPECT_FLOAT_EQ(v[1], 2.0F);
}
