#include <gtest/gtest.h>

#include <znx/Vec3d.hh>

TEST(Vec3d, ConstructAndIndex) {
	const znx::Vec3d v{1.0F, 2.0F, 3.0F};
	EXPECT_FLOAT_EQ(v[0], 1.0F);
	EXPECT_FLOAT_EQ(v[1], 2.0F);
	EXPECT_FLOAT_EQ(v[2], 3.0F);
}

TEST(Vec3d, NamedComponents) {
	const znx::Vec3d v{4.0F, 5.0F, 6.0F};
	EXPECT_FLOAT_EQ(v.x, 4.0F);
	EXPECT_FLOAT_EQ(v.y, 5.0F);
	EXPECT_FLOAT_EQ(v.z, 6.0F);
}

TEST(Vec3d, MutableAccess) {
	znx::Vec3d v{0.0F, 0.0F, 0.0F};
	v[0] = 7.0F;
	v[2] = 9.0F;
	EXPECT_FLOAT_EQ(v[0], 7.0F);
	EXPECT_FLOAT_EQ(v[1], 0.0F);
	EXPECT_FLOAT_EQ(v[2], 9.0F);
}
