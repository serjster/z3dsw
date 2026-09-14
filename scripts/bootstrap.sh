#!/usr/bin/env bash
# Bring up the local Conan configuration for z3dsw.
#
#   * creates a project-local virtualenv (./.venv)
#   * installs Conan (and cmake-format for the `format` target)
#   * detects a Conan profile and ensures the conancenter remote
#   * creates/updates the committed lockfile (conan.lock)
#   * installs the Debug and Release configurations into build/conan/<Config>
#
# Usage:  scripts/bootstrap.sh
# Env:    PYTHON (default: python3), VENV (default: .venv)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PYTHON="${PYTHON:-python3}"
VENV="${VENV:-.venv}"

if ! command -v "$PYTHON" >/dev/null 2>&1; then
    echo "error: '$PYTHON' not found; install Python 3 and retry" >&2
    exit 1
fi

if [ ! -d "$VENV" ]; then
    echo ">> creating virtualenv at $VENV"
    "$PYTHON" -m venv "$VENV"
fi

# shellcheck disable=SC1091
source "$VENV/bin/activate"

echo ">> installing tooling into $VENV"
python -m pip install --quiet --upgrade pip
python -m pip install --quiet --upgrade "conan>=2.4" "cmake-format>=0.6"

echo ">> detecting Conan profile"
conan profile detect --exist-ok

echo ">> ensuring 'conancenter' remote"
if ! conan remote list | grep -q "conancenter"; then
    conan remote add conancenter https://center2.conan.io
fi

echo ">> creating/updating lockfile (conan.lock)"
conan lock create . --lockfile-out=conan.lock

for CONFIG in Debug Release; do
    echo ">> installing dependencies ($CONFIG)"
    conan install . \
        -s build_type="$CONFIG" \
        --build=missing \
        --lockfile=conan.lock \
        --output-folder="build/conan/$CONFIG"
done

cat <<'EOF'

Bootstrap complete. Next steps:

  cmake --preset dev
  cmake --build --preset dev
  ctest --preset dev

  # optimized build
  cmake --preset release && cmake --build --preset release

The 'dev' preset enables clang-tidy and Address/UndefinedBehavior sanitizers.
Other toggles (warnings-as-errors, TSan, ...) are CMake options passed per profile.
EOF
