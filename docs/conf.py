# Sphinx configuration for z3dsw.
# Modern stack: MyST (Markdown) + Breathe (pulls Doxygen XML) + Furo theme.
# Build via the CMake 'docs-sphinx' target, or manually:
#   pip install -r docs/requirements.txt
#   sphinx-build -b html docs build/docs/sphinx/html
import os

project = "z3dsw"
copyright = "2025, z3dsw authors"
author = "z3dsw authors"
version = os.environ.get("Z3D_VERSION", "0.1.0")
release = version

extensions = [
    "myst_parser",
    "breathe",
]

# Breathe: consume the XML produced by the 'docs-doxygen' target.
# The CMake target exports DOXYGEN_XML_DIR; fall back to a sane local path.
_xml = os.environ.get("DOXYGEN_XML_DIR", os.path.join("..", "build", "docs", "doxygen", "xml"))
breathe_projects = {"z3dsw": _xml}
breathe_default_project = "z3dsw"

templates_path = []
exclude_patterns = ["_build", "requirements.txt"]

html_theme = "furo"
html_static_path = []
html_title = f"z3dsw {version}"

myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "tasklist",
]
