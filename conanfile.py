from conan import ConanFile
from conan.tools.cmake import CMakeDeps, CMakeToolchain


class Z3dswConan(ConanFile):
    name = "z3dsw"
    version = "0.1.0"
    description = "z3dsw - an educational software 3d rendering engine"
    license = "MIT"
    settings = "os", "compiler", "build_type", "arch"

    # Dependencies managed by Conan. gtest is the only one we need for now;
    # add more here (e.g. "fmt/11.0.2", "spdlog/1.14.1") as the project grows.
    options = {"with_tests": [True, False]}
    default_options = {"with_tests": True}

    # Reproducibility: a committed conan.lock pins the resolved graph.
    # Create/refresh it with: scripts/bootstrap.sh  (conan lock create .)

    def requirements(self):
        if self.options.with_tests:
            self.requires("gtest/1.14.0", test=True)

    def generate(self):
        # CMakeDeps -> find_package(GTest) config files (GTestConfig.cmake, ...).
        deps = CMakeDeps(self)
        deps.generate()

        # CMakeToolchain -> conan_toolchain.cmake in the install output folder.
        # We deliberately do NOT use cmake_layout(): the CMake presets control
        # where things land (build/conan/<Config> for Conan, build/<preset> for
        # the CMake build tree), which keeps the two from clashing.
        tc = CMakeToolchain(self)
        tc.cache_variables["Z3D_ENABLE_TESTING"] = str(bool(self.options.with_tests))
        tc.generate()
