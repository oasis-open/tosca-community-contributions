from datetime import datetime, timezone

# Return the current UTC timestamp as a timezone-aware datetime.
def now() -> datetime:
    return datetime.now(timezone.utc)
