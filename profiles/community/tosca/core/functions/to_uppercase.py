def to_uppercase(args):
    """
    Convert a string to upper case.

    Args:
      args: Variable length list of arguments
        args[0] (str): The string to convert (required)
    Returns:
        str: The converted string; an empty string for an empty string
    Raises:
        ValueError: If not exactly one argument is provided, or the argument
          has no value
    """
    if len(args) != 1:
        raise ValueError("Exactly one argument is required")
    if args[0] is None:
        raise ValueError("The argument has no value")
    return args[0].upper()
