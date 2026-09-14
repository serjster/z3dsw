#include <gtest/gtest.h>

#include <znx/Vec3.hh>
#include <znx/linalg.hh>

using znx::f32;
using znx::Vec3;

// --- compile-time checks ---------------------------------------------------
constexpr Vec3 A{1.0F, 2.0F, 3.0F};
constexpr Vec3 B{4.0F, 5.0F, 6.0F};
static_assert(znx::dot(A, B) == 32.0F);
static_assert(znx::dot(A) == 14.0F);
static_assert((A + B)[0] == 5.0F);
static_assert((B - A)[0] == 3.0F);
static_assert((-A)[2] == -3.0F);
static_assert((A * 2.0F)[1] == 4.0F);
static_assert((2.0F * A)[1] == 4.0F);

// --- addition / subtraction ------------------------------------------------
TEST(LinAlg, AddVectors) {
	const Vec3 c = A + B;
	EXPECT_FLOAT_EQ(c[0], 5.0F);
	EXPECT_FLOAT_EQ(c[1], 7.0F);
	EXPECT_FLOAT_EQ(c[2], 9.0F);
}

TEST(LinAlg, AddAssignVector) {
	Vec3 v = A;
	v += B;
	EXPECT_FLOAT_EQ(v[0], 5.0F);
	EXPECT_FLOAT_EQ(v[1], 7.0F);
	EXPECT_FLOAT_EQ(v[2], 9.0F);
}

TEST(LinAlg, AddAssignScalar) {
	Vec3 v = A;
	v += 10.0F;
	EXPECT_FLOAT_EQ(v[0], 11.0F);
	EXPECT_FLOAT_EQ(v[1], 12.0F);
	EXPECT_FLOAT_EQ(v[2], 13.0F);
}

TEST(LinAlg, SubtractVectors) {
	const Vec3 c = B - A;
	EXPECT_FLOAT_EQ(c[0], 3.0F);
	EXPECT_FLOAT_EQ(c[1], 3.0F);
	EXPECT_FLOAT_EQ(c[2], 3.0F);
}

TEST(LinAlg, SubAssignVector) {
	Vec3 v = B;
	v -= A;
	EXPECT_FLOAT_EQ(v[0], 3.0F);
	EXPECT_FLOAT_EQ(v[1], 3.0F);
	EXPECT_FLOAT_EQ(v[2], 3.0F);
}

TEST(LinAlg, SubAssignScalar) {
	Vec3 v = A;
	v -= 1.0F;
	EXPECT_FLOAT_EQ(v[0], 0.0F);
	EXPECT_FLOAT_EQ(v[1], 1.0F);
	EXPECT_FLOAT_EQ(v[2], 2.0F);
}

TEST(LinAlg, UnaryNegate) {
	const Vec3 c = -A;
	EXPECT_FLOAT_EQ(c[0], -1.0F);
	EXPECT_FLOAT_EQ(c[1], -2.0F);
	EXPECT_FLOAT_EQ(c[2], -3.0F);
}

TEST(LinAlg, ChainingMutatingOperators) {
	Vec3 v = A;
	(v += B) -= B; // returns a reference, so it chains
	EXPECT_FLOAT_EQ(v[0], 1.0F);
	EXPECT_FLOAT_EQ(v[1], 2.0F);
	EXPECT_FLOAT_EQ(v[2], 3.0F);
}

// --- scalar multiplication / division --------------------------------------
TEST(LinAlg, ScalarMultiply) {
	const Vec3 r = A * 2.0F;
	EXPECT_FLOAT_EQ(r[0], 2.0F);
	EXPECT_FLOAT_EQ(r[1], 4.0F);
	EXPECT_FLOAT_EQ(r[2], 6.0F);

	const Vec3 l = 3.0F * A;
	EXPECT_FLOAT_EQ(l[0], 3.0F);
	EXPECT_FLOAT_EQ(l[1], 6.0F);
	EXPECT_FLOAT_EQ(l[2], 9.0F);
}

TEST(LinAlg, MultiplyAssign) {
	Vec3 v = A;
	v *= 2.0F;
	EXPECT_FLOAT_EQ(v[0], 2.0F);
	EXPECT_FLOAT_EQ(v[1], 4.0F);
	EXPECT_FLOAT_EQ(v[2], 6.0F);
}

TEST(LinAlg, ScalarDivide) {
	Vec3 v = A;
	v /= 2.0F;
	EXPECT_FLOAT_EQ(v[0], 0.5F);
	EXPECT_FLOAT_EQ(v[1], 1.0F);
	EXPECT_FLOAT_EQ(v[2], 1.5F);
}

// --- products and norms ----------------------------------------------------
TEST(LinAlg, Dot) {
	EXPECT_FLOAT_EQ(znx::dot(A, B), 32.0F);
	EXPECT_FLOAT_EQ(znx::dot(A, A), 14.0F);
}

TEST(LinAlg, DotSelf) { EXPECT_FLOAT_EQ(znx::dot(A), 14.0F); }

TEST(LinAlg, Magnitude) {
	const Vec3 v1{0.0F, 1.0F, 1.0F};
	EXPECT_FLOAT_EQ(znx::mag(v1), 1.4142135F);
	const Vec3 v2{1.0F, 1.0F, 1.0F};
	EXPECT_FLOAT_EQ(znx::mag(v2), 1.7320508F);
}

// --- normalization ---------------------------------------------------------
TEST(LinAlg, NormalizeInPlace) {
	Vec3 v{1.0F, 2.0F, 3.0F};
	znx::normalize(v);
	EXPECT_FLOAT_EQ(znx::mag(v), 1.0F);
	for (znx::usize i = 0; i < v.size(); ++i) {
		EXPECT_FLOAT_EQ(v[i], znx::cast<f32>(i + 1) / znx::SQRT(14.0F));
	}
}

TEST(LinAlg, NormalizedReturnsCopy) {
	const Vec3 v{1.0F, 2.0F, 3.0F};
	const Vec3 u = znx::normalized(v);
	EXPECT_FLOAT_EQ(znx::mag(u), 1.0F);
	for (znx::usize i = 0; i < v.size(); ++i) {
		EXPECT_FLOAT_EQ(v[i], znx::cast<f32>(i + 1)); // source untouched
		EXPECT_FLOAT_EQ(u[i], znx::cast<f32>(i + 1) / znx::SQRT(14.0F));
	}
}
