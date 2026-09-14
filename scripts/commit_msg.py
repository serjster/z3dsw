#!/usr/bin/env python3
"""Validate messages against the z3dsw commit message convention.

    <Prefix>: <imperative subject>

    <optional body, wrapped at 100 columns>

Prefixes: App Lib Render Math Test Docs Build CI Repo Deps Release

The header is limited to 72 columns (aim for <= 50). Merge, revert and
autosquash (fixup!/squash!/amend!) commits are ignored.

Used in three places:
  * as a git commit-msg hook (pre-commit):   commit_msg.py <message-file>
  * from CI:                                 commit_msg.py --stdin
  * ad hoc:                                  commit_msg.py --message "App: foo"

Bypass a single local commit with `git commit --no-verify`.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

PREFIXES = (
    "App",
    "Lib",
    "Render",
    "Math",
    "Test",
    "Docs",
    "Build",
    "CI",
    "Repo",
    "Deps",
    "Release",
)

HEADER_MAX = 72
HEADER_SOFT = 50
BODY_MAX = 100

HEADER_RE = re.compile(r"^(?P<prefix>[A-Za-z]+):\s?(?P<subject>.*)$")
SKIP_RE = re.compile(r"^(Merge |Revert |fixup! |squash! |amend! )")


def validate(text: str) -> tuple[list[str], list[str]]:
    """Return (errors, warnings) for a raw commit message."""
    lines = [ln for ln in text.splitlines() if not ln.startswith("#")]
    while lines and lines[-1].strip() == "":
        lines.pop()
    if not lines:
        return [], []

    header = lines[0]
    if SKIP_RE.match(header):
        return [], []

    errors: list[str] = []
    warnings: list[str] = []

    if len(header) > HEADER_MAX:
        errors.append(f"header is {len(header)} chars (max {HEADER_MAX})")
    elif len(header) > HEADER_SOFT:
        warnings.append(f"header is {len(header)} chars (aim for <= {HEADER_SOFT})")

    match = HEADER_RE.match(header)
    if not match:
        errors.append("header must look like '<Prefix>: <subject>'")
    else:
        prefix = match.group("prefix")
        subject = match.group("subject").strip()
        if prefix not in PREFIXES:
            errors.append(f"unknown prefix '{prefix}:' (allowed: {', '.join(PREFIXES)})")
        if not subject:
            errors.append("subject is empty")
        elif subject.endswith("."):
            errors.append("subject must not end with a period")

    if len(lines) > 1 and lines[1].strip() != "":
        errors.append("line 2 must be blank (a blank line separates header from body)")

    for lineno, line in enumerate(lines[2:], start=3):
        if len(line) > BODY_MAX:
            errors.append(f"line {lineno} is {len(line)} chars (max {BODY_MAX})")

    return errors, warnings


def _report(errors: list[str], warnings: list[str]) -> int:
    for warning in warnings:
        print(f"commit-msg: warning: {warning}", file=sys.stderr)
    for error in errors:
        print(f"commit-msg: error: {error}", file=sys.stderr)
    if errors:
        print(
            "\nFormat:   <Prefix>: <subject>\n"
            f"Prefixes: {', '.join(PREFIXES)}\n"
            "Example:  Render: add perspective-correct texture sampling",
            file=sys.stderr,
        )
        return 1
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Validate a commit message.")
    parser.add_argument("file", nargs="?", help="commit message file (git hook mode)")
    parser.add_argument("--stdin", action="store_true", help="read the message from stdin")
    parser.add_argument("--message", help="validate the given message string")
    args = parser.parse_args(argv)

    if args.stdin:
        text = sys.stdin.read()
    elif args.message is not None:
        text = args.message
    elif args.file:
        text = Path(args.file).read_text(encoding="utf-8", errors="replace")
    else:
        parser.error("provide a message file, --message, or --stdin")
        return 2

    errors, warnings = validate(text)
    return _report(errors, warnings)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
