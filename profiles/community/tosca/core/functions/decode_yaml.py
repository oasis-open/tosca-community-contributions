# Requires a YAML parser (PyYAML). Unlike the other functions in this
# profile, which use the Python standard library only, this one depends on
# a package a processor must make available to function implementations.
import yaml

def decode_yaml(args):
    """
    Decode a YAML string.

    Note that the YAML scalar resolution rules are version-dependent:
    unquoted tokens such as `no`, `on`, and `y` resolve to booleans under
    YAML 1.1, which is what PyYAML implements. Quote values whose string
    form matters.

    Args:
      args: Variable length list of arguments
        args[0] (str): The YAML string to decode (required)
    Returns:
        dict/list/scalar: The decoded YAML document
    Raises:
        ValueError: If no arguments provided
        yaml.YAMLError: If the YAML string is invalid
    """
    # Check if at least one argument provided
    if len(args) != 1:
        raise ValueError("Exactly one argument is required")

    # First argument is the YAML string
    yaml_string = args[0]

    # Return the decoded YAML string. safe_load is used rather than load
    # so that tags cannot instantiate arbitrary objects.
    return yaml.safe_load(yaml_string)
