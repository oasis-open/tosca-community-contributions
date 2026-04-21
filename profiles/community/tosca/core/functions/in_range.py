from datetime import datetime
from typing import Any

try:
    from packaging.version import Version
    HAS_PACKAGING = True
except ImportError:
    HAS_PACKAGING = False


def _parse_timestamp(value):
    if isinstance(value, datetime):
        return value
    if isinstance(value, str):
        try:
            return datetime.fromisoformat(value)
        except ValueError:
            return None
    return None


def _parse_version(value):
    if not HAS_PACKAGING:
        return None
    try:
        return Version(value)
    except Exception:
        return None


def in_range(value: Any, low: Any, high: Any) -> bool:
    """
    Returns True if low <= value <= high.

    Supported types:
    - int
    - float
    - str
    - datetime / ISO timestamp string
    - semantic version string

    Returns False if:
    - incompatible types
    - invalid interval
    - parsing error
    """

    # Reject reversed interval
    try:
        if low > high:
            return False
    except Exception:
        return False

    # Numeric comparison
    if all(isinstance(x, (int, float)) for x in (value, low, high)):
        return low <= value <= high

    # Timestamp comparison
    v_ts = _parse_timestamp(value)
    l_ts = _parse_timestamp(low)
    h_ts = _parse_timestamp(high)

    if all(x is not None for x in (v_ts, l_ts, h_ts)):
        return l_ts <= v_ts <= h_ts

    # Semantic version comparison
    if HAS_PACKAGING:
        v_ver = _parse_version(value)
        l_ver = _parse_version(low)
        h_ver = _parse_version(high)

        if all(x is not None for x in (v_ver, l_ver, h_ver)):
            return l_ver <= v_ver <= h_ver

    # String comparison fallback
    if all(isinstance(x, str) for x in (value, low, high)):
        return low <= value <= high

    return False

