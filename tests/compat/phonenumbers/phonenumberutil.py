"""Phone number utility functions."""

from phonenumber import (
    PhoneNumberUtil as BasePhoneNumberUtil,
    PhoneNumberFormat,
    PhoneNumberType,
    parse,
    format_number,
    is_valid_number,
    get_number_type,
    get_example_number,
    NumberParseExceptionType,
)

# Re-export the singleton
PhoneNumberUtil = BasePhoneNumberUtil

# Country code to region code mapping
COUNTRY_CODE_TO_REGION_CODE = {
    1: ["US", "CA"],
    44: ["GB"],
    33: ["FR"],
}

# Create NumberParseException class for tests
class NumberParseException(Exception):
    """Exception when parsing a phone number."""
    def __init__(self, error_type, msg=""):
        super().__init__(msg)
        self.error_type = error_type
        self.message = msg
        
# Function to regenerate derived data
def _regenerate_derived_data():
    """Regenerate derived data used by the phonenumberutil module."""
    # This would recalculate any lookup tables or caches
    # For our stub implementation, this is a no-op
    pass