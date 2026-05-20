import random
import string

def unique_name(args):
    chars = string.ascii_lowercase + string.digits
    name = ''.join(random.choices(chars, k=10))
    return name
