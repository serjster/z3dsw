find_package(GTest REQUIRED)
include(GoogleTest)

add_executable(z3dsw_tests test_linalg.cc test_vec3d.cc)

target_link_libraries(z3dsw_tests PRIVATE GTest::gtest GTest::gtest_main
										  znx::znx z3d_project_options)

# In a coverage build, require a fixture whose cleanup step (registered by
# z3d_prepare_coverage) writes the report after every test has run.
if(Z3D_ENABLE_COVERAGE AND Z3D_GCOVR)
	gtest_discover_tests(z3dsw_tests DISCOVERY_TIMEOUT 30
						 PROPERTIES FIXTURES_REQUIRED z3d_coverage)
else()
	gtest_discover_tests(z3dsw_tests DISCOVERY_TIMEOUT 30)
endif()
