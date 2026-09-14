#!/usr/bin/env bash
# Install Conan dependencies for a single build type, pinned by conan.lock.
# Output goes to build/conan/<Config>, which the CMake presets read their
# toolchain from (see CMakePresets.json).
#
# Usage:  scripts/conan-install.sh <Debug|Release|RelWithDebInfo|MinSizeRel>
set -euo pipefail

CONFIG="${1:-Debug}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ -f .venv/bin/activate ]; then
    # shellcheck disable=SC1091
    source .venv/bin/activate
fi

if ! command -v conan >/dev/null 2>&1; then
    echo "error: conan not found; run scripts/bootstrap.sh first" >&2
    exit 1
fi

if [ ! -f conan.lock ]; then
    echo ">> conan.lock missing; creating it"
    conan lock create . --lockfile-out=conan.lock
fi

echo ">> conan install ($CONFIG) -> build/conan/$CONFIG"
conan install . \
    -s build_type="$CONFIG" \
    --build=missing \
    --lockfile=conan.lock \
    --output-folder="build/conan/$CONFIG"
