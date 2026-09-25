import secrets

# Generate a cryptographically strong token from a character set.
def generate_token(args) -> str:
    if len(args) != 2:
        raise ValueError("Two arguments are required: charset and length")
    
    charset = args[0]
    length = args[1]
    
    if not isinstance(charset, str) or not charset:
        raise TypeError(
            "generate_token expects a non-empty character set string"
        )

    if (
        not isinstance(length, int)
        or isinstance(length, bool)
        or length < 0
    ):
        raise TypeError(
            "generate_token expects a non-negative integer length"
        )

    return "".join(
        secrets.choice(charset)
        for _ in range(length)
    )