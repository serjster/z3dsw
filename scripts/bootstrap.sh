#!/usr/bin/env bash
# Bring up the local Conan configuration for z3dsw.
#
#   * creates a project-local virtualenv (./.venv) via uv (preferred) or python -m venv
#   * installs Conan, cmake-format, pre-commit and shellcheck (via uv or pip) and verifies they are on PATH
#   * detects a Conan profile and ensures the conancenter remote
#   * creates/updates the committed lockfile (conan.lock)
#   * installs the Debug and Release configurations into build/conan/<Config>
#   * installs the git hooks and commit template (when inside a git repo)
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

TOOLING=("conan>=2.4" "cmake-format>=0.6" "pre-commit>=3.7" "shellcheck-py>=0.10")

if command -v uv >/dev/null 2>&1; then
    echo ">> creating/updating virtualenv at $VENV (uv)"
    uv venv --allow-existing --python "$PYTHON" "$VENV"
else
    if [ ! -d "$VENV" ]; then
        echo ">> creating virtualenv at $VENV"
        "$PYTHON" -m venv "$VENV"
    fi
fi

# shellcheck disable=SC1091
source "$VENV/bin/activate"

echo ">> installing tooling into $VENV"
if command -v uv >/dev/null 2>&1; then
    uv pip install --quiet --upgrade "${TOOLING[@]}"
else
    python -m pip install --quiet --upgrade pip
    python -m pip install --quiet --upgrade "${TOOLING[@]}"
fi

for TOOL in conan cmake-format pre-commit shellcheck; do
    if ! command -v "$TOOL" >/dev/null 2>&1; then
        echo "error: '$TOOL' not found on PATH after installing tooling" >&2
        exit 1
    fi
done

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

# ---------------------------------------------------------------------------
# Git hooks (pre-commit framework) + commit template
# ---------------------------------------------------------------------------
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo ">> installing git hooks + commit template"
    git config commit.template .gitmessage
    if pre-commit install >/dev/null 2>&1; then
        echo "   installed pre-commit and commit-msg hooks"
    else
        echo "   warning: 'pre-commit install' failed; run it manually" >&2
    fi
else
    echo ">> not a git repository; skipping hook install"
    echo "   later: git init && pre-commit install"
fi

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
