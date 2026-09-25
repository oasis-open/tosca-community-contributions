from datetime import datetime, timezone

# Return the current UTC timestamp as an RFC 3339 string, which is the form the
# TOSCA timestamp type takes. 'args' is empty, since the signature declares no
# arguments; it is accepted because a function's implementation is always
# called with the argument list.
def now(args) -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
