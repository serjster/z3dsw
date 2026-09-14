# Unit tests (GoogleTest, provided by Conan). Degrades gracefully if Conan deps aren't
# present yet (see scripts/bootstrap.sh).
find_package(GTest QUIET)

if(NOT GTest_FOUND)
	message(
		WARNING "z3dsw: GTest not found - skipping tests. Run scripts/bootstrap.sh and "
				"configure through a preset so the Conan toolchain provides GTest.")
	return()
endif()

include(GoogleTest)

add_executable(z3dsw_tests test_vec3d.cc)

# First-party: inherit project options/warnings. GTest's includes come from an IMPORTED
# target, so CMake treats them as SYSTEM and suppresses their warnings.
target_link_libraries(z3dsw_tests PRIVATE znx::znx z3d_project_options GTest::gtest
										  GTest::gtest_main)

gtest_discover_tests(z3dsw_tests DISCOVERY_TIMEOUT 30)
