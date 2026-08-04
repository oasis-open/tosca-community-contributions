# Requires a YAML parser (PyYAML). Unlike the other functions in this
# profile, which use the Python standard library only, this one depends on
# a package a processor must make available to function implementations.
import yaml

def validate_yaml(args):
    """
    Check if a string contains a well-formed YAML document.

    Args:
      args: list of arguments
        args[0] (str): The YAML string to validate (required)
    Returns:
      True/False
    Raises:
      ValueError: If no arguments provided
    """
    # Make sure exactly one argument is provided
    if len(args) != 1:
        raise ValueError("Exactly one argument is required")
    yaml_string = args[0]

    # Parse the YAML string. safe_load is used rather than load so that
    # tags cannot instantiate arbitrary objects. It also accepts a single
    # document only, so a multi-document stream is reported as invalid.
    try:
        yaml.safe_load(yaml_string)
        return True
    except yaml.YAMLError:
        return False
