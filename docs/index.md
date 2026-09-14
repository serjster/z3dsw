# z3dsw

`z3dsw` is a software 3D rendering engine, wired up with Conan, CMake presets,
sanitizers, static analysis, formatting and documentation tooling.

```{toctree}
:maxdepth: 2
:hidden:

self
```

## Library

The core library lives in `src/` and is exposed under the `znx::` namespace via
the `znx::znx` CMake target.

```{doxygenindex}
:project: z3dsw
```

## Building

```bash
scripts/bootstrap.sh           # one-time: set up Conan + lockfile
cmake --preset dev             # configure (uses Conan toolchain)
cmake --build --preset dev     # build
ctest --preset dev             # run tests
```
