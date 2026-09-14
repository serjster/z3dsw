add_executable(z3dsw main.cpp)

target_link_libraries(z3dsw PRIVATE znx::znx z3d_project_options)

set_target_properties(z3dsw PROPERTIES OUTPUT_NAME z3dsw)
