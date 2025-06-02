"""Phone number timezone functionality."""

# List of unknown time zones for testing
_UNKNOWN_TIME_ZONE_LIST = ["Etc/Unknown"]

def time_zones_for_geographical_number(number):
    """Get time zones for a geographical phone number."""
    return ["America/Los_Angeles"]  # Mock implementation for tests

def time_zones_for_number(number):
    """Get time zones for a phone number."""
    return time_zones_for_geographical_number(number)