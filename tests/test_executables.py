"""
Test if all linter binaries exist
"""

import shutil
import pytest


@pytest.mark.parametrize(
    ("binary"),
    [
        "python3",
        "pylint",
        "cppcheck",
        "shellcheck",
        "hadolint",
        "yamllint",
        "flake8",
        "lint",
        "lacheck",
        "chktex",
    ],
)
def test_binaries(binary):
    """Check if binary exists"""
    assert shutil.which(binary)
