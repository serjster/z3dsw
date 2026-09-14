#include <iostream>

#include <znx/Vec3.hh>

int main() {
	const znx::Vec3 v{1.0F, 2.0F, 3.0F};
	std::cout << "z3dsw Vec3d: " << v[0] << ", " << v[1] << ", " << v[2] << '\n';
	return 0;
}
