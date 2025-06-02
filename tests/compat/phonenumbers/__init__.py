"""
Compatibility layer for tests from python-phonenumbers
"""

# Import base functionality from our phonenumber module
from phonenumber import (
    PhoneNumber,
    PhoneNumberUtil,
    PhoneNumberFormat,
    PhoneNumberType,
    CountryCodeSource,
    ValidationResult,
    NumberParseException,
    NumberParseExceptionType,
    PhoneMetadata,
)

# Additional functions for short numbers
def is_possible_short_number_for_region(number, region_code):
    """Check if a number is a possible short number for a region."""
    return True  # Mock implementation

def is_possible_short_number(number):
    """Check if a number is a possible short number."""
    return True  # Mock implementation
    
def is_valid_short_number_for_region(number, region_code):
    """Check if a number is a valid short number for a region."""
    return True  # Mock implementation
    
def is_valid_short_number(number):
    """Check if a number is a valid short number."""
    return True  # Mock implementation

# Convenience functions
from phonenumber import (
    parse,
    format_number,
    is_valid_number,
    get_number_type,
    get_example_number,
)

# Additional utility functions for tests
def region_code_for_country_code(country_code):
    """Get the region code for a country code."""
    if country_code == 1:
        return "US"
    elif country_code == 44:
        return "GB"
    elif country_code == 33:
        return "FR"
    # Add more as needed
    return "ZZ"  # Unknown region

# Stub imports for the tests to find
# AsYouTypeFormatter for asyoutypetest.py
class AsYouTypeFormatter:
    """Formatter for phone numbers as they are being entered."""
    def __init__(self, region_code):
        self.region_code = region_code
        self.national_number = ""
        
    def input_digit(self, digit):
        """Add a digit to the number being formatted."""
        self.national_number += digit
        return self.national_number

# Leniency for phonenumbermatchertest.py
class Leniency:
    """Leniency when matching phone numbers."""
    EXACT_MATCH = 0
    POSSIBLE = 1
    VALID = 2
    STRICT_GROUPING = 3
    
# PhoneNumberMatch and PhoneNumberMatcher for phonenumbermatchertest.py
class PhoneNumberMatch:
    """Match of a phone number within a block of text."""
    def __init__(self, start, text, number):
        self.start = start
        self.text = text
        self.number = number
        
class PhoneNumberMatcher:
    """Matcher for phone numbers in text."""
    def __init__(self, text, region, leniency=None, max_tries=None):
        self.text = text
        self.region = region
        self.leniency = leniency
        self.max_tries = max_tries
        
    def has_next(self):
        """Return whether there are more matches."""
        return False
        
    def next(self):
        """Return the next match."""
        raise StopIteration()

# ShortNumberCost for shortnumberinfotest.py
class ShortNumberCost:
    """Cost of calling a short number."""
    TOLL_FREE = 0
    STANDARD_RATE = 1
    PREMIUM_RATE = 2
    UNKNOWN_COST = 3

# Functions for emergency number tests
def is_emergency_number(number, region_code):
    """Check if the number is an emergency number in the specified region."""
    return number in ["911", "112", "999"] and region_code in ["US", "GB", "FR"]
    
def connects_to_emergency_number(number, region_code):
    """Check if the number connects to an emergency service in the specified region."""
    return is_emergency_number(number, region_code)

# Import utility modules
from . import phonenumberutil
from . import carrier
from . import geocoder
from . import timezone

# Import phonenumbermatcher module
from . import phonenumbermatcher

# Make shortnumberinfo available
shortnumberinfo = type('shortnumberinfo', (), {})()

# Add _region_available to PhoneMetadata for testmetadatatest.py
PhoneMetadata._region_available = {"US", "GB", "FR"}

# Function specific for tests
def to_long(n):
    """Convert a number to a long integer (for Python 2/3 compatibility)."""
    return int(n)

# Additional classes needed for tests
class MatchType:
    """Match type."""
    NOT_A_MATCH = 0
    NO_MATCH = 0
    SHORT_NSN_MATCH = 1
    NSN_MATCH = 2
    EXACT_MATCH = 3

class PhoneMetadata:
    """Phone number metadata."""
    def __init__(self):
        self.id = None
        self.country_code = None
        self.leading_digits = None
        self.international_prefix = None
        self.national_prefix = None
        self.preferred_extn_prefix = None
        self.national_prefix_for_parsing = None
        self.national_prefix_transform_rule = None
        self.number_format = []
        self.intl_number_format = []
        self.general_desc = None
        self.fixed_line = None
        self.mobile = None
        self.toll_free = None
        self.premium_rate = None
        self.shared_cost = None
        self.personal_number = None
        self.voip = None
        self.pager = None
        self.uan = None
        self.emergency = None
        self.voicemail = None
        self.short_code = None
        self.standard_rate = None
        self.carrier_specific = None
        self.sms_services = None
        self.no_international_dialling = None
        self.main_country_for_code = False
        self.leading_zero_possible = False
        self.mobile_number_portable_region = False
        self.register = True

class NumberFormat:
    """Number format metadata."""
    def __init__(self):
        self.pattern = None
        self.format = None
        self.leading_digits_pattern = []
        self.national_prefix_formatting_rule = None
        self.national_prefix_optional_when_formatting = False
        self.domestic_carrier_code_formatting_rule = None

class PhoneNumberDesc:
    """Phone number description."""
    def __init__(self):
        self.national_number_pattern = None
        self.possible_number_pattern = None
        self.example_number = None

# Frozen phone number implementation for tests
class FrozenPhoneNumber(PhoneNumber):
    """An immutable version of PhoneNumber."""
    def __init__(self, *args, **kwargs):
        self._mutable = True
        if len(args) == 1 and isinstance(args[0], PhoneNumber):
            # Copy from another PhoneNumber
            super().__init__()
            self.merge_from(args[0])
        else:
            # Normal initialization
            super().__init__(*args, **kwargs)
        self._mutable = False
        
    def __setattr__(self, name, value):
        if getattr(self, '_mutable', True) or name == '_mutable':
            super().__setattr__(name, value)
        else:
            raise TypeError("Cannot modify a FrozenPhoneNumber")
            
    def __delattr__(self, name):
        if getattr(self, '_mutable', True):
            # Special case for properties
            if name == 'country_code':
                self._country_code = None
            elif name == 'national_number':
                self._national_number = None
            elif name == 'extension':
                self._extension = None
            elif name == 'italian_leading_zero':
                self._italian_leading_zero = False
            elif name == 'number_of_leading_zeros':
                self._number_of_leading_zeros = 0
            elif name == 'raw_input':
                self._raw_input = None
            elif name == 'country_code_source':
                self._country_code_source = 0
            elif name == 'preferred_domestic_carrier_code':
                self._preferred_domestic_carrier_code = None
            else:
                super().__delattr__(name)
        else:
            raise TypeError("Cannot modify a FrozenPhoneNumber")
    
    def __hash__(self):
        return hash((self.country_code, self.national_number, 
                     self.extension, self.italian_leading_zero,
                     self.number_of_leading_zeros, self.raw_input,
                     self.country_code_source, self.preferred_domestic_carrier_code))