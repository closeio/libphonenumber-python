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
)

# Convenience functions
from phonenumber import (
    parse,
    format_number,
    is_valid_number,
    get_number_type,
    get_example_number,
)

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