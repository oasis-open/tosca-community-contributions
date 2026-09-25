# Convert a value to lowercase text, preserving None.
def to_lowercase(args):
    if args and args[0]:
        return args[0].lower()
    else:
        return None