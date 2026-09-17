# The port SshUrl reads an absent port as. RFC 3986 section 3.2.3 asks a URI
# producer to leave out a port equal to the scheme's default.
_DEFAULT_PORT = 22

def socket_to_ssh_url(args):
    """
    Convert a Socket to an SshUrl.

    Args:
      args: Variable length list of arguments
        args[0] (dict): The socket, with 'address' and 'port' (required)
    Returns:
        str: The URL, ssh://host[:port], with an IPv6 address bracketed and a
          port of 22 left out
    Raises:
        ValueError: If not exactly one argument is provided, or the socket
          has no address, or its port is 0, which Port admits and a URL
          cannot name
    """
    if len(args) != 1:
        raise ValueError("Exactly one argument is required")

    socket = args[0]
    address = socket.get("address") if isinstance(socket, dict) else None
    if not address:
        raise ValueError(f"'{socket}' is not a socket with an address")

    # Only an IPv6 address contains a colon; a URL brackets it so that its
    # colons are not read as the port separator.
    host = f"[{address}]" if ":" in address else address
    port = socket.get("port")
    if port is not None and int(port) == 0:
        raise ValueError(f"'{socket}' has port 0, which an ssh URL cannot name")
    if port is None or int(port) == _DEFAULT_PORT:
        return f"ssh://{host}"
    return f"ssh://{host}:{int(port)}"
