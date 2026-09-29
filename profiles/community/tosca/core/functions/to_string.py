def to_string(args):
    """
    Convert an integer to a string.

    Args:
      args: Variable length list of arguments
        args[0] (int): The integer to convert (required)
    Returns:
        str: The integer's decimal representation
    Raises:
        ValueError: If not exactly one argument is provided, or the argument
          has no value
    """
    if len(args) != 1:
        raise ValueError("Exactly one argument is required")
    if args[0] is None:
        raise ValueError("The argument has no value")
    return str(args[0])
