"""Utility functions for phonenumbers."""

def to_long(n):
    """Convert a number to a long integer (for Python 2/3 compatibility)."""
    return int(n)

def u(s):
    """Convert to Unicode string, for Python 2/3 compatibility."""
    return str(s)

def prnt(s):
    """Print string in unicode-friendly way."""
    print(s)