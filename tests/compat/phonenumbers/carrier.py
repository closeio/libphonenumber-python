"""Phone carrier information."""

# Dummy carrier data for tests
CARRIER_DATA = {}

def name_for_number(number, language):
    """Get carrier name for a phone number."""
    return "Verizon"  # Mock implementation for tests

def name_for_valid_number(number, language):
    """Get carrier name for a valid phone number."""
    return name_for_number(number, language)

def safe_display_name(number, language):
    """Get safe display name for a phone number."""
    return name_for_number(number, language)