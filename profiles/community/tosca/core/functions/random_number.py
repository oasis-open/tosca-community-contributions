import random

# Return a pseudorandom float in the half-open interval [0.0, 1.0). 'args' is
# empty, since the signature declares no arguments; it is accepted because a
# function's implementation is always called with the argument list.
def random_number(args) -> float:
    return random.random()
