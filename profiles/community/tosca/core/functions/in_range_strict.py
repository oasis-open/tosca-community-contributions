from datetime import datetime
from numbers import Real

try:
    from packaging.version import Version
    HAS_PACKAGING = True
except ImportError:
    HAS_PACKAGING = False


def _is_numeric(value):
    """Return True for numeric values, explicitly excluding booleans."""
    return isinstance(value, Real) and not isinstance(value, bool)


def _parse_datetime(value):
    """Parse datetime objects or ISO 8601 datetime strings."""
    if isinstance(value, datetime):
        return value

    if isinstance(value, str):
        try:
            return datetime.fromisoformat(value)
        except ValueError:
            return None

    return None


def _same_datetime_flavour(*values):
    """
    Return True only if all datetime values are consistently timezone-aware
    or consistently timezone-naive.
    """
    awareness = {
        value.tzinfo is not None and value.tzinfo.utcoffset(value) is not None
        for value in values
    }

    return len(awareness) == 1


def _parse_version(value):
    """Parse a PEP 440 compliant version string."""
    if not HAS_PACKAGING:
        return None

    if not isinstance(value, str):
        return None

    try:
        return Version(value)
    except Exception:
        return None


def _normalize_values(value, low, high):
    """
    Normalize value, low and high according to the following type hierarchy:

    1. numeric
    2. datetime
    3. version
    4. string

    Return:
        tuple[str, object, object, object]

    Return None if the three values cannot be normalized to the same
    logical type.
    """

    # 1. numeric
    if all(_is_numeric(item) for item in (value, low, high)):
        return "numeric", value, low, high

    # 2. datetime
    parsed_value = _parse_datetime(value)
    parsed_low = _parse_datetime(low)
    parsed_high = _parse_datetime(high)

    if all(item is not None for item in (parsed_value, parsed_low, parsed_high)):
        if not _same_datetime_flavour(parsed_value, parsed_low, parsed_high):
            return None

        return "datetime", parsed_value, parsed_low, parsed_high

    # 3. version
    parsed_value = _parse_version(value)
    parsed_low = _parse_version(low)
    parsed_high = _parse_version(high)

    if all(item is not None for item in (parsed_value, parsed_low, parsed_high)):
        return "version", parsed_value, parsed_low, parsed_high

    # 4. string
    if all(isinstance(item, str) for item in (value, low, high)):
        return "string", value, low, high

    return None


def _extract_value_and_range(args):
    """
    Validate and extract the input structure.

    Expected input:
        [value, [min, max]]

    Return:
        tuple[object, object, object]

    Return None if the input structure is invalid.
    """
    if not isinstance(args, (list, tuple)):
        return None

    if len(args) != 2:
        return None

    value = args[0]
    range_value = args[1]

    if not isinstance(range_value, (list, tuple)):
        return None

    if len(range_value) != 2:
        return None

    low, high = range_value

    return value, low, high



def in_range_strict(args) -> bool:
    """
    Return True if value is included in the open range (min, max).

    Expected input:
        [value, [min, max]]

    Supported logical types, evaluated in this order:
        1. numeric
        2. datetime
        3. version
        4. string

    Semantics:
        min < value < max
    """
    extracted = _extract_value_and_range(args)

    if extracted is None:
        return False

    value, low, high = extracted
    normalized = _normalize_values(value, low, high)

    if normalized is None:
        return False

    _, value, low, high = normalized

    try:
        if low >= high:
            return False

        return low < value < high
    except Exception:
        return False
