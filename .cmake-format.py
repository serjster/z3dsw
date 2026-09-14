# cmake-format configuration for z3dsw.
# Used by the `format` / `format-check` / `cmake-lint` CMake targets.
# Docs: https://cmake-format.readthedocs.io
with section("format"):
    line_width = 120
    tab_size = 4
    use_tabchars = False
    line_ending = "unix"
    dangle_parens = True
    max_subgroups_hwrap = 2
    separate_ctrl_name_with_space = False
    separate_fn_name_with_space = False
    enable_sort = False
    autosort = False
    require_valid_layout = False
    command_case = "canonical"
    keyword_case = "upper"

with section("markup"):
    bullet_char = "*"
    enum_char = "."
    first_comment_is_literal = False
    literal_comment_pattern = None
    fence_pattern = "^\\s*([`~]{3}[`~]*)(.*)$"
    ruler_pattern = "^\\s*[^\\w\\s]{3}.*[^\\w\\s]{3}$"

with section("misc"):
    per_command = {}
