import re

# The host and optional port of an SshUrl. Validation of the URL itself is the
# SshUrl type's; this only takes a valid one apart.
_SSH_URL = re.compile(r"^ssh://(\[[0-9A-Fa-f:.]+\]|[^\[\]/:@?#]+)(?::([0-9]+))?$")

# The port SshUrl reads an absent port as.
_DEFAULT_PORT = 22

def ssh_url_to_socket(args):
    """
    Convert an SshUrl to a Socket.

    Args:
      args: Variable length list of arguments
        args[0] (str): The URL, in the form ssh://host[:port] (required)
    Returns:
        dict: The socket, with 'address' holding the URL's host (an IPv6
          literal without its brackets) and 'port' the URL's port, or 22
          where the URL gives none
    Raises:
        ValueError: If not exactly one argument is provided, or the
          argument is not an ssh URL of that form
    """
    if len(args) != 1:
        raise ValueError("Exactly one argument is required")

    url = args[0]
    match = _SSH_URL.match(url) if isinstance(url, str) else None
    if not match:
        raise ValueError(f"'{url}' is not an ssh URL of the form ssh://host[:port]")

    host, port = match.groups()
    if host.startswith("["):
        host = host[1:-1]
    return {
        "address": host,
        "port": int(port) if port is not None else _DEFAULT_PORT,
    }
