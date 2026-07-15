"""Shared helpers for constraining user input to safe workspace paths."""

from __future__ import annotations

import os
import re
from pathlib import Path
from typing import Pattern

SAFE_NAME_PATTERN = re.compile(r"^[A-Za-z0-9._-]+$")

PathInput = str | os.PathLike[str] | Path

__all__ = ["ensure_safe_name", "resolve_workspace_path", "SAFE_NAME_PATTERN"]


def resolve_workspace_path(
    path_value: PathInput,
    *,
    workspace_root: Path,
    description: str,
) -> Path:
    """Resolve a supplied path while ensuring it remains inside the workspace."""
    if workspace_root is None:
        raise ValueError("workspace_root is required.")

    root = workspace_root.expanduser().resolve()
    if path_value is None:
        raise ValueError(f"{description} cannot be empty.")

    if isinstance(path_value, Path):
        candidate = path_value
    else:
        candidate_raw = os.fspath(path_value)
        if isinstance(candidate_raw, str):
            if not candidate_raw.strip():
                raise ValueError(f"{description} cannot be empty.")
        elif isinstance(candidate_raw, bytes):
            if not candidate_raw.strip():
                raise ValueError(f"{description} cannot be empty.")
        candidate = Path(candidate_raw)

    candidate = candidate.expanduser()
    if not candidate.is_absolute():
        candidate = root / candidate

    sanitized = candidate.resolve()
    try:
        sanitized.relative_to(root)
    except ValueError as exc:
        raise ValueError(
            f"{description} '{sanitized}' must reside inside the workspace at '{root}'."
        ) from exc

    return sanitized


def ensure_safe_name(
    value: str | None,
    *,
    description: str,
    pattern: Pattern[str] = SAFE_NAME_PATTERN,
) -> str:
    """Validate identifiers that should never contain path separators."""
    if value is None:
        raise ValueError(f"{description} is required.")

    cleaned = value.strip()
    if not cleaned:
        raise ValueError(f"{description} cannot be empty.")

    if not pattern.fullmatch(cleaned):
        raise ValueError(f"{description} '{value}' contains invalid characters.")

    return cleaned
