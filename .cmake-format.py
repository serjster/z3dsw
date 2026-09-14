# cmake-format configuration for z3dsw.
# Used by the `format` / `format-check` / `cmake-lint` CMake targets.
# Docs: https://cmake-format.readthedocs.io
with section("format"):
    line_width = 90
    tab_size = 4
    use_tabchars = True
    line_ending = "unix"
    # Wrapped statements keep the closing ')' on the last argument line instead of
    # spending a whole line on it.
    dangle_parens = False
    max_subgroups_hwrap = 2
    separate_ctrl_name_with_space = False
    separate_fn_name_with_space = False
    enable_sort = True
    autosort = True
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

with section("parse"):
    # cmake-format's built-in add_library parser keeps the name/type flags together but
    # wraps the source list greedily (packing several files onto one line). Replacing the
    # command spec lets us force the whole command vertical once it exceeds three
    # positional args (name + type + one source), so each source gets its own line as soon
    # as there is more than one source. Change 3 -> 1 to always split (even single source).
    # Tradeoff: overriding the spec disables alphabetical sorting of add_library sources.
    additional_commands = {"add_library": {"pargs": "*"}}
    override_spec = {"add_library/parg0.max_pargs_hwrap": 3}
