# distutils: language = c++
# cython: language_level=3

"""
Python bindings for Google's libphonenumber library.
"""

from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.set cimport set as cppset
from libcpp.list cimport list as cpplist
from cython.operator cimport dereference as deref, postincrement as postinc

# Use a relative import path
from .phonenumber_defs cimport (
    PhoneNumber as CppPhoneNumber,
    PhoneNumberUtil as CppPhoneNumberUtil,
    PhoneNumberDesc as CppPhoneNumberDesc,
    NumberFormat as CppNumberFormat,
    CppPhoneNumberFormat,
    CppPhoneNumberType,
    CppCountryCodeSource,
    CppValidationResult,
    CppErrorType,
    CppMatchType,
)

# Geocoder support
cdef extern from "unicode/locid.h" namespace "icu":
    cdef cppclass Locale:
        Locale()
        Locale(const char* language)
        Locale(const char* language, const char* country)

cdef extern from "phonenumbers/geocoding/phonenumber_offline_geocoder.h" namespace "i18n::phonenumbers":
    cdef cppclass PhoneNumberOfflineGeocoder:
        PhoneNumberOfflineGeocoder()
        
        string GetDescriptionForValidNumber(const CppPhoneNumber& number, const Locale& language) const
        string GetDescriptionForValidNumber(const CppPhoneNumber& number, const Locale& language, const string& user_region) const
        string GetDescriptionForNumber(const CppPhoneNumber& number, const Locale& locale) const
        string GetDescriptionForNumber(const CppPhoneNumber& number, const Locale& language, const string& user_region) const

__version__ = "0.1.0"

# Exception class
class NumberParseException(Exception):
    """Exception when attempting to parse a putative phone number"""

    # The reason a string could not be interpreted as a phone number.

    # The country code supplied did not belong to a supported country or
    # non-geographical entity.
    INVALID_COUNTRY_CODE = 0

    # This generally indicates the string passed in had fewer than 3 digits in
    # it.  The number failed to match the regular expression
    # _VALID_PHONE_NUMBER in phonenumberutil.py.

    # This indicates the string passed is not a valid number. Either the string
    # had less than 3 digits in it or had an invalid phone-context
    # parameter. More specifically, the number failed to match the regular
    # expression _VALID_PHONE_NUMBER, RFC3966_GLOBAL_NUMBER_DIGITS, or
    # _RFC3966_DOMAINNAME in phonenumberutil.py.
    NOT_A_NUMBER = 1

    # This indicates the string started with an international dialing prefix,
    # but after this was removed, it had fewer digits than any valid phone
    # number (including country code) could have.
    TOO_SHORT_AFTER_IDD = 2

    # This indicates the string, after any country code has been stripped,
    # had fewer digits than any valid phone number could have.
    TOO_SHORT_NSN = 3

    # This indicates the string had more digits than any valid phone number
    # could have
    TOO_LONG = 4

    def __init__(self, error_type, msg):
        Exception.__init__(self, msg)
        self.error_type = error_type
        self._msg = msg

    def __reduce__(self):
        return (type(self), (self.error_type, self._msg))

    def __str__(self):
        return f"({self.error_type}) {self._msg}"

    def __repr__(self):
        return f"NumberParseException(error_type={self.error_type}, msg='{self._msg}')"

# Enum definitions
class PhoneNumberFormat:
    """Phone number format options."""
    E164 = CppPhoneNumberFormat.FORMAT_E164
    INTERNATIONAL = CppPhoneNumberFormat.FORMAT_INTERNATIONAL
    NATIONAL = CppPhoneNumberFormat.FORMAT_NATIONAL
    RFC3966 = CppPhoneNumberFormat.FORMAT_RFC3966
    
    @classmethod
    def to_string(cls, format_type):
        """Convert a PhoneNumberFormat enum value to its string name."""
        format_map = {
            cls.E164: "E164",
            cls.INTERNATIONAL: "INTERNATIONAL", 
            cls.NATIONAL: "NATIONAL",
            cls.RFC3966: "RFC3966"
        }
        if format_type in format_map:
            return format_map[format_type]
        else:
            return f"INVALID ({format_type})"

class PhoneNumberType:
    """Phone number type."""
    FIXED_LINE = CppPhoneNumberType.TYPE_FIXED_LINE
    MOBILE = CppPhoneNumberType.TYPE_MOBILE
    FIXED_LINE_OR_MOBILE = CppPhoneNumberType.TYPE_FIXED_LINE_OR_MOBILE
    TOLL_FREE = CppPhoneNumberType.TYPE_TOLL_FREE
    PREMIUM_RATE = CppPhoneNumberType.TYPE_PREMIUM_RATE
    SHARED_COST = CppPhoneNumberType.TYPE_SHARED_COST
    VOIP = CppPhoneNumberType.TYPE_VOIP
    PERSONAL_NUMBER = CppPhoneNumberType.TYPE_PERSONAL_NUMBER
    PAGER = CppPhoneNumberType.TYPE_PAGER
    UAN = CppPhoneNumberType.TYPE_UAN
    VOICEMAIL = CppPhoneNumberType.TYPE_VOICEMAIL
    UNKNOWN = CppPhoneNumberType.TYPE_UNKNOWN
    
    @classmethod
    def to_string(cls, number_type):
        """Convert a PhoneNumberType enum value to its string name."""
        type_map = {
            cls.FIXED_LINE: "FIXED_LINE",
            cls.MOBILE: "MOBILE",
            cls.FIXED_LINE_OR_MOBILE: "FIXED_LINE_OR_MOBILE",
            cls.TOLL_FREE: "TOLL_FREE",
            cls.PREMIUM_RATE: "PREMIUM_RATE",
            cls.SHARED_COST: "SHARED_COST",
            cls.VOIP: "VOIP",
            cls.PERSONAL_NUMBER: "PERSONAL_NUMBER",
            cls.PAGER: "PAGER",
            cls.UAN: "UAN",
            cls.VOICEMAIL: "VOICEMAIL",
            cls.UNKNOWN: "UNKNOWN"
        }
        if number_type in type_map:
            return type_map[number_type]
        else:
            return f"INVALID ({number_type})"

class CountryCodeSource:
    """Country code source."""
    UNSPECIFIED = CppCountryCodeSource.SOURCE_UNSPECIFIED
    FROM_NUMBER_WITH_PLUS_SIGN = CppCountryCodeSource.SOURCE_FROM_NUMBER_WITH_PLUS_SIGN
    FROM_NUMBER_WITH_IDD = CppCountryCodeSource.SOURCE_FROM_NUMBER_WITH_IDD
    FROM_NUMBER_WITHOUT_PLUS_SIGN = CppCountryCodeSource.SOURCE_FROM_NUMBER_WITHOUT_PLUS_SIGN
    FROM_DEFAULT_COUNTRY = CppCountryCodeSource.SOURCE_FROM_DEFAULT_COUNTRY
    
    @classmethod
    def to_string(cls, source_type):
        """Convert a CountryCodeSource enum value to its string name."""
        source_map = {
            cls.UNSPECIFIED: "UNSPECIFIED",
            cls.FROM_NUMBER_WITH_PLUS_SIGN: "FROM_NUMBER_WITH_PLUS_SIGN",
            cls.FROM_NUMBER_WITH_IDD: "FROM_NUMBER_WITH_IDD",
            cls.FROM_NUMBER_WITHOUT_PLUS_SIGN: "FROM_NUMBER_WITHOUT_PLUS_SIGN",
            cls.FROM_DEFAULT_COUNTRY: "FROM_DEFAULT_COUNTRY"
        }
        if source_type in source_map:
            return source_map[source_type]
        else:
            return f"INVALID ({source_type})"

class ValidationResult:
    """Validation result."""
    IS_POSSIBLE = CppValidationResult.RESULT_IS_POSSIBLE
    IS_POSSIBLE_LOCAL_ONLY = CppValidationResult.RESULT_IS_POSSIBLE_LOCAL_ONLY
    INVALID_COUNTRY_CODE = CppValidationResult.RESULT_INVALID_COUNTRY_CODE
    TOO_SHORT = CppValidationResult.RESULT_TOO_SHORT
    INVALID_LENGTH = CppValidationResult.RESULT_INVALID_LENGTH
    TOO_LONG = CppValidationResult.RESULT_TOO_LONG
    
    @classmethod
    def to_string(cls, result_type):
        """Convert a ValidationResult enum value to its string name."""
        result_map = {
            cls.IS_POSSIBLE: "IS_POSSIBLE",
            cls.IS_POSSIBLE_LOCAL_ONLY: "IS_POSSIBLE_LOCAL_ONLY",
            cls.INVALID_COUNTRY_CODE: "INVALID_COUNTRY_CODE",
            cls.TOO_SHORT: "TOO_SHORT",
            cls.INVALID_LENGTH: "INVALID_LENGTH",
            cls.TOO_LONG: "TOO_LONG"
        }
        if result_type in result_map:
            return result_map[result_type]
        else:
            return f"INVALID ({result_type})"

class MatchType:
    """Types of phone number matches."""
    INVALID_NUMBER = CppMatchType.MATCH_INVALID_NUMBER
    NOT_A_NUMBER = CppMatchType.MATCH_INVALID_NUMBER  # Alias for compatibility
    NO_MATCH = CppMatchType.MATCH_NO_MATCH
    SHORT_NSN_MATCH = CppMatchType.MATCH_SHORT_NSN_MATCH
    NSN_MATCH = CppMatchType.MATCH_NSN_MATCH
    EXACT_MATCH = CppMatchType.MATCH_EXACT_MATCH
    
    @classmethod
    def to_string(cls, match_type):
        """Convert a MatchType enum value to its string name."""
        match_map = {
            cls.INVALID_NUMBER: "NOT_A_NUMBER",  # Use the expected name
            cls.NO_MATCH: "NO_MATCH",
            cls.SHORT_NSN_MATCH: "SHORT_NSN_MATCH",
            cls.NSN_MATCH: "NSN_MATCH",
            cls.EXACT_MATCH: "EXACT_MATCH"
        }
        if match_type in match_map:
            return match_map[match_type]
        else:
            return f"INVALID ({match_type})"

# Phone number class
cdef class PhoneNumber:
    """
    Python representation of a phone number.
    """
    cdef CppPhoneNumber* _phone_number

    def __cinit__(self, country_code=None, national_number=None, extension=None,
                  italian_leading_zero=None, number_of_leading_zeros=None,
                  raw_input=None, country_code_source=None, 
                  preferred_domestic_carrier_code=None):
        self._phone_number = new CppPhoneNumber()
        
        # Set properties if provided
        if country_code is not None:
            self.country_code = country_code
        if national_number is not None:
            self.national_number = national_number
        if extension is not None:
            self.extension = str(extension)
        if italian_leading_zero is not None:
            self.italian_leading_zero = italian_leading_zero
        if number_of_leading_zeros is not None:
            self.number_of_leading_zeros = number_of_leading_zeros
        if raw_input is not None:
            self.raw_input = raw_input
        if country_code_source is not None:
            self.country_code_source = country_code_source
        if preferred_domestic_carrier_code is not None:
            self.preferred_domestic_carrier_code = preferred_domestic_carrier_code
    
    def __dealloc__(self):
        del self._phone_number
    
    @property
    def country_code(self):
        """Country calling code."""
        return self._phone_number.country_code()
    
    @country_code.setter
    def country_code(self, value):
        self._phone_number.set_country_code(value)
    
    @property
    def national_number(self):
        """National number portion."""
        return self._phone_number.national_number()
    
    @national_number.setter
    def national_number(self, value):
        self._phone_number.set_national_number(value)
    
    @property
    def extension(self):
        """Extension."""
        return self._phone_number.extension().decode('utf-8')
    
    @extension.setter
    def extension(self, value):
        self._phone_number.set_extension(value.encode('utf-8'))
    
    @property
    def italian_leading_zero(self):
        """Whether the number has an Italian leading zero."""
        return self._phone_number.italian_leading_zero()
    
    @italian_leading_zero.setter
    def italian_leading_zero(self, value):
        self._phone_number.set_italian_leading_zero(value)
    
    @property
    def number_of_leading_zeros(self):
        """Number of leading zeros."""
        return self._phone_number.number_of_leading_zeros()
    
    @number_of_leading_zeros.setter
    def number_of_leading_zeros(self, value):
        self._phone_number.set_number_of_leading_zeros(value)
    
    @property
    def raw_input(self):
        """Raw input."""
        return self._phone_number.raw_input().decode('utf-8')
    
    @raw_input.setter
    def raw_input(self, value):
        self._phone_number.set_raw_input(value.encode('utf-8'))
    
    @property
    def country_code_source(self):
        """Country code source."""
        return self._phone_number.country_code_source()
    
    @country_code_source.setter
    def country_code_source(self, value):
        self._phone_number.set_country_code_source(<CppCountryCodeSource>value)
    
    @property
    def preferred_domestic_carrier_code(self):
        """Preferred domestic carrier code."""
        return self._phone_number.preferred_domestic_carrier_code().decode('utf-8')
    
    @preferred_domestic_carrier_code.setter
    def preferred_domestic_carrier_code(self, value):
        self._phone_number.set_preferred_domestic_carrier_code(value.encode('utf-8'))
    
    def __str__(self):
        return format_number(self, PhoneNumberFormat.INTERNATIONAL)
    
    def __repr__(self):
        return f"PhoneNumber(country_code={self.country_code}, national_number={self.national_number})"
    
    def __eq__(self, other):
        if not isinstance(other, PhoneNumber):
            return False
        
        # Compare basic fields (always required)
        if (self.country_code != other.country_code or
            self.national_number != other.national_number or
            self.extension != other.extension):
            return False
        
        # Italian leading zero: special case where False==False regardless of has-state
        if self.italian_leading_zero != other.italian_leading_zero:
            return False
        if (self.italian_leading_zero or other.italian_leading_zero):
            if self._has_italian_leading_zero() != other._has_italian_leading_zero():
                return False
        
        # All other optional fields: both value and has-state must match
        return (
            self.number_of_leading_zeros == other.number_of_leading_zeros and
            self._has_number_of_leading_zeros() == other._has_number_of_leading_zeros() and
            self.raw_input == other.raw_input and
            self._has_raw_input() == other._has_raw_input() and
            self.country_code_source == other.country_code_source and
            self._has_country_code_source() == other._has_country_code_source() and
            self.preferred_domestic_carrier_code == other.preferred_domestic_carrier_code and
            self._has_preferred_domestic_carrier_code() == other._has_preferred_domestic_carrier_code()
        )
    
    def __ne__(self, other):
        return not self.__eq__(other)
    
    def merge_from(self, other):
        """Merge all fields from another PhoneNumber into this one."""
        if not isinstance(other, PhoneNumber):
            raise TypeError("Can only merge from another PhoneNumber")
        self.country_code = other.country_code
        self.national_number = other.national_number
        self.extension = other.extension
        self.italian_leading_zero = other.italian_leading_zero
        self.number_of_leading_zeros = other.number_of_leading_zeros
        self.raw_input = other.raw_input
        self.country_code_source = other.country_code_source
        self.preferred_domestic_carrier_code = other.preferred_domestic_carrier_code
    
    def _has_italian_leading_zero(self):
        return self._phone_number.has_italian_leading_zero()
    
    def _has_number_of_leading_zeros(self):
        return self._phone_number.has_number_of_leading_zeros()
    
    def _has_raw_input(self):
        return self._phone_number.has_raw_input()
    
    def _has_country_code_source(self):
        return self._phone_number.has_country_code_source()
    
    def _has_preferred_domestic_carrier_code(self):
        return self._phone_number.has_preferred_domestic_carrier_code()

# NumberFormat class
cdef class NumberFormat:
    """
    Python representation of a number formatting rule.
    """
    cdef CppNumberFormat* _number_format
    
    def __cinit__(self):
        self._number_format = new CppNumberFormat()
    
    def __dealloc__(self):
        del self._number_format
    
    @property
    def pattern(self):
        """Regex pattern for matching phone numbers."""
        if not self._number_format.has_pattern():
            return None
        return self._number_format.pattern().decode('utf-8')
    
    @pattern.setter
    def pattern(self, value):
        if value is not None:
            self._number_format.set_pattern(value.encode('utf-8'))
    
    @property
    def format(self):
        """Format string for formatting matched numbers."""
        if not self._number_format.has_format():
            return None
        return self._number_format.format().decode('utf-8')
    
    @format.setter
    def format(self, value):
        if value is not None:
            self._number_format.set_format(value.encode('utf-8'))
    
    @property
    def leading_digits_patterns(self):
        """List of leading digit patterns."""
        patterns = []
        cdef int size = self._number_format.leading_digits_pattern_size()
        for i in range(size):
            patterns.append(self._number_format.leading_digits_pattern(i).decode('utf-8'))
        return patterns
    
    def add_leading_digits_pattern(self, pattern):
        """Add a leading digits pattern."""
        self._number_format.add_leading_digits_pattern(pattern.encode('utf-8'))
    
    @property
    def national_prefix_formatting_rule(self):
        """National prefix formatting rule."""
        if not self._number_format.has_national_prefix_formatting_rule():
            return None
        return self._number_format.national_prefix_formatting_rule().decode('utf-8')
    
    @national_prefix_formatting_rule.setter
    def national_prefix_formatting_rule(self, value):
        if value is not None:
            self._number_format.set_national_prefix_formatting_rule(value.encode('utf-8'))
    
    @property
    def domestic_carrier_code_formatting_rule(self):
        """Domestic carrier code formatting rule."""
        if not self._number_format.has_domestic_carrier_code_formatting_rule():
            return None
        return self._number_format.domestic_carrier_code_formatting_rule().decode('utf-8')
    
    @domestic_carrier_code_formatting_rule.setter
    def domestic_carrier_code_formatting_rule(self, value):
        if value is not None:
            self._number_format.set_domestic_carrier_code_formatting_rule(value.encode('utf-8'))
    
    @property
    def national_prefix_optional_when_formatting(self):
        """Whether national prefix is optional when formatting."""
        if not self._number_format.has_national_prefix_optional_when_formatting():
            return False
        return self._number_format.national_prefix_optional_when_formatting()
    
    @national_prefix_optional_when_formatting.setter
    def national_prefix_optional_when_formatting(self, value):
        self._number_format.set_national_prefix_optional_when_formatting(value)
    
    def __str__(self):
        return f"NumberFormat(pattern='{self.pattern}', format='{self.format}')"
    
    def __repr__(self):
        return self.__str__()

# PhoneNumberDesc class
cdef class PhoneNumberDesc:
    """
    Python representation of a phone number description for a specific type.
    """
    cdef CppPhoneNumberDesc* _phone_number_desc
    
    def __cinit__(self):
        self._phone_number_desc = new CppPhoneNumberDesc()
    
    def __dealloc__(self):
        del self._phone_number_desc
    
    @property
    def national_number_pattern(self):
        """Regex pattern for valid national numbers."""
        if not self._phone_number_desc.has_national_number_pattern():
            return None
        return self._phone_number_desc.national_number_pattern().decode('utf-8')
    
    @national_number_pattern.setter
    def national_number_pattern(self, value):
        if value is not None:
            self._phone_number_desc.set_national_number_pattern(value.encode('utf-8'))
    
    @property
    def example_number(self):
        """Example number for this type."""
        if not self._phone_number_desc.has_example_number():
            return None
        return self._phone_number_desc.example_number().decode('utf-8')
    
    @example_number.setter
    def example_number(self, value):
        if value is not None:
            self._phone_number_desc.set_example_number(value.encode('utf-8'))
    
    @property
    def possible_lengths(self):
        """List of possible lengths for this number type."""
        lengths = []
        cdef int size = self._phone_number_desc.possible_length_size()
        for i in range(size):
            lengths.append(self._phone_number_desc.possible_length(i))
        return lengths
    
    def add_possible_length(self, length):
        """Add a possible length."""
        self._phone_number_desc.add_possible_length(length)
    
    @property
    def possible_lengths_local_only(self):
        """List of possible lengths for local-only numbers."""
        lengths = []
        cdef int size = self._phone_number_desc.possible_length_local_only_size()
        for i in range(size):
            lengths.append(self._phone_number_desc.possible_length_local_only(i))
        return lengths
    
    def add_possible_length_local_only(self, length):
        """Add a possible length for local-only numbers."""
        self._phone_number_desc.add_possible_length_local_only(length)
    
    def __str__(self):
        return f"PhoneNumberDesc(pattern='{self.national_number_pattern}', example='{self.example_number}')"
    
    def __repr__(self):
        return self.__str__()

# PhoneMetadata class - aggregates public metadata information
cdef class PhoneMetadata:
    """
    Python representation of phone metadata for a region.
    This class aggregates information from various public APIs.
    """
    cdef readonly str _region_code
    cdef readonly int _country_code
    cdef readonly list _supported_types
    cdef readonly object _example_numbers
    
    def __cinit__(self, region_code):
        self._region_code = region_code
        self._country_code = 0
        self._supported_types = []
        self._example_numbers = {}
        
        # Get country code from an example number
        try:
            example = get_example_number(region_code)
            if example:
                self._country_code = example.country_code
        except:
            pass
        
        # Get supported types
        self._supported_types = get_supported_types_for_region(region_code)
        
        # Get example numbers for each type
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef PhoneNumber example_number
        cdef bool success
        for number_type in self._supported_types:
            try:
                example_number = PhoneNumber()
                success = util.GetExampleNumberForType(
                    region_code.encode('utf-8'),
                    <CppPhoneNumberType>number_type,
                    example_number._phone_number
                )
                if success:
                    self._example_numbers[number_type] = example_number
            except:
                pass
    
    @property
    def region_code(self):
        """Region code identifier (e.g., 'US', 'GB')."""
        return self._region_code
    
    @property
    def country_code(self):
        """Country calling code (e.g., 1 for US, 44 for UK)."""
        return self._country_code
    
    @property
    def supported_types(self):
        """List of supported phone number types for this region."""
        return self._supported_types[:]  # Return a copy
    
    def get_example_number(self, number_type=None):
        """Get example number for the region or a specific type."""
        if number_type is None:
            # Return general example number
            return get_example_number(self._region_code)
        else:
            # Return example for specific type
            return self._example_numbers.get(number_type)
    
    def get_example_number_string(self, number_type=None, format_type=PhoneNumberFormat.NATIONAL):
        """Get example number as formatted string."""
        example = self.get_example_number(number_type)
        if example:
            return format_number(example, format_type)
        return None
    
    def is_valid_number_for_region(self, phone_number):
        """Check if a phone number is valid for this region."""
        cdef PhoneNumber parsed_number
        if isinstance(phone_number, str):
            try:
                parsed_number = parse(phone_number, self._region_code)
            except NumberParseException:
                return False
        else:
            parsed_number = phone_number
        
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        return util.IsValidNumberForRegion(
            deref(parsed_number._phone_number),
            self._region_code.encode('utf-8')
        )
    
    def get_number_type(self, phone_number):
        """Get the type of a phone number in this region."""
        cdef PhoneNumber parsed_number
        if isinstance(phone_number, str):
            try:
                parsed_number = parse(phone_number, self._region_code)
            except NumberParseException:
                return None
        else:
            parsed_number = phone_number
        
        return number_type(parsed_number)
    
    def __str__(self):
        return f"PhoneMetadata(region='{self._region_code}', country_code={self._country_code})"
    
    def __repr__(self):
        return self.__str__()

# Immutable phone number class
cdef class FrozenPhoneNumber:
    """
    Immutable Python representation of a phone number.
    All properties are read-only and the object is hashable.
    """
    cdef readonly int _country_code
    cdef readonly object _national_number
    cdef readonly str _extension
    cdef readonly bool _italian_leading_zero
    cdef readonly int _number_of_leading_zeros
    cdef readonly str _raw_input
    cdef readonly int _country_code_source
    cdef readonly str _preferred_domestic_carrier_code
    cdef readonly int _hash
    cdef public bool _mutable
    
    def __cinit__(self, phone_number_or_country_code=None, national_number=None, str extension="", 
                  bool italian_leading_zero=False, int number_of_leading_zeros=1,
                  str raw_input="", int country_code_source=0, 
                  str preferred_domestic_carrier_code="", **kwargs):
        # Handle keyword arguments
        if 'country_code' in kwargs:
            phone_number_or_country_code = kwargs['country_code']
        if 'extension' in kwargs:
            extension = str(kwargs['extension'])
        if 'italian_leading_zero' in kwargs:
            italian_leading_zero = kwargs['italian_leading_zero']
        if 'number_of_leading_zeros' in kwargs:
            number_of_leading_zeros = kwargs['number_of_leading_zeros']
        if 'raw_input' in kwargs:
            raw_input = kwargs['raw_input']
        if 'country_code_source' in kwargs:
            country_code_source = kwargs['country_code_source']
        if 'preferred_domestic_carrier_code' in kwargs:
            preferred_domestic_carrier_code = kwargs['preferred_domestic_carrier_code']
        
        # Handle the case where first argument is a PhoneNumber object
        if isinstance(phone_number_or_country_code, PhoneNumber):
            phone_number = phone_number_or_country_code
            self._country_code = phone_number.country_code
            self._national_number = phone_number.national_number
            self._extension = phone_number.extension
            self._italian_leading_zero = phone_number.italian_leading_zero
            self._number_of_leading_zeros = phone_number.number_of_leading_zeros
            self._raw_input = phone_number.raw_input
            self._country_code_source = phone_number.country_code_source
            self._preferred_domestic_carrier_code = phone_number.preferred_domestic_carrier_code
        # Handle the case where arguments are provided separately
        elif phone_number_or_country_code is not None and national_number is not None:
            self._country_code = phone_number_or_country_code
            self._national_number = national_number
            self._extension = extension
            self._italian_leading_zero = italian_leading_zero
            self._number_of_leading_zeros = number_of_leading_zeros
            self._raw_input = raw_input
            self._country_code_source = country_code_source
            self._preferred_domestic_carrier_code = preferred_domestic_carrier_code
        else:
            # Default values
            self._country_code = 0
            self._national_number = 0
            self._extension = extension
            self._italian_leading_zero = italian_leading_zero
            self._number_of_leading_zeros = number_of_leading_zeros
            self._raw_input = raw_input
            self._country_code_source = country_code_source
            self._preferred_domestic_carrier_code = preferred_domestic_carrier_code
        
        # Compute hash once during initialization
        self._hash = hash((
            self._country_code,
            self._national_number,
            self._extension,
            self._italian_leading_zero,
            self._number_of_leading_zeros,
            self._raw_input,
            self._country_code_source,
            self._preferred_domestic_carrier_code
        ))
        
        # Set immutability
        self._mutable = False
    
    @property
    def country_code(self):
        """Country calling code."""
        return self._country_code
    
    @property
    def national_number(self):
        """National number portion."""
        return self._national_number
    
    @property
    def extension(self):
        """Extension."""
        return self._extension
    
    @property
    def italian_leading_zero(self):
        """Whether the number has an Italian leading zero."""
        return self._italian_leading_zero
    
    @property
    def number_of_leading_zeros(self):
        """Number of leading zeros."""
        return self._number_of_leading_zeros
    
    @property
    def raw_input(self):
        """Raw input."""
        return self._raw_input
    
    @property
    def country_code_source(self):
        """Country code source."""
        return self._country_code_source
    
    @property
    def preferred_domestic_carrier_code(self):
        """Preferred domestic carrier code."""
        return self._preferred_domestic_carrier_code
    
    def __str__(self):
        # Convert to mutable PhoneNumber temporarily for formatting
        temp_number = PhoneNumber()
        temp_number.country_code = self._country_code
        temp_number.national_number = self._national_number
        temp_number.extension = self._extension
        temp_number.italian_leading_zero = self._italian_leading_zero
        temp_number.number_of_leading_zeros = self._number_of_leading_zeros
        temp_number.raw_input = self._raw_input
        temp_number.country_code_source = self._country_code_source
        temp_number.preferred_domestic_carrier_code = self._preferred_domestic_carrier_code
        return format_number(temp_number, PhoneNumberFormat.INTERNATIONAL)
    
    def __repr__(self):
        return f"FrozenPhoneNumber(country_code={self._country_code}, national_number={self._national_number})"
    
    def __hash__(self):
        return self._hash
    
    def __eq__(self, other):
        if isinstance(other, FrozenPhoneNumber):
            return (
                self._country_code == other._country_code and
                self._national_number == other._national_number and
                self._extension == other._extension and
                self._italian_leading_zero == other._italian_leading_zero and
                self._number_of_leading_zeros == other._number_of_leading_zeros and
                self._raw_input == other._raw_input and
                self._country_code_source == other._country_code_source and
                self._preferred_domestic_carrier_code == other._preferred_domestic_carrier_code
            )
        elif isinstance(other, PhoneNumber):
            return (
                self._country_code == other.country_code and
                self._national_number == other.national_number and
                self._extension == other.extension and
                self._italian_leading_zero == other.italian_leading_zero and
                self._number_of_leading_zeros == other.number_of_leading_zeros and
                self._raw_input == other.raw_input and
                self._country_code_source == other.country_code_source and
                self._preferred_domestic_carrier_code == other.preferred_domestic_carrier_code
            )
        else:
            return False
    
    def __setattr__(self, name, value):
        if name == "_mutable":
            # Allow setting _mutable
            self._mutable = value
        elif hasattr(self, '_mutable') and not self._mutable:
            raise TypeError("Can't modify immutable instance")
        else:
            # For readonly properties, this will fail anyway
            raise TypeError("Can't modify immutable instance")
    
    def __delattr__(self, name):
        if hasattr(self, '_mutable') and self._mutable:
            # Allow deletion when mutable
            pass  # Deletion will be handled by the readonly properties and cause appropriate errors
        else:
            raise TypeError("Can't modify immutable instance")
    
    @staticmethod
    def from_phone_number(PhoneNumber phone_number):
        """Create a FrozenPhoneNumber from a mutable PhoneNumber."""
        return FrozenPhoneNumber(
            country_code=phone_number.country_code,
            national_number=phone_number.national_number,
            extension=phone_number.extension,
            italian_leading_zero=phone_number.italian_leading_zero,
            number_of_leading_zeros=phone_number.number_of_leading_zeros,
            raw_input=phone_number.raw_input,
            country_code_source=phone_number.country_code_source,
            preferred_domestic_carrier_code=phone_number.preferred_domestic_carrier_code
        )
    
    def clear(self):
        """Raise TypeError - FrozenPhoneNumber cannot be cleared."""
        raise TypeError("Can't modify immutable instance")
    
    def merge_from(self, other):
        """Raise TypeError - FrozenPhoneNumber cannot be modified."""
        raise TypeError("Can't modify immutable instance")
    
    def to_phone_number(self):
        """Create a mutable PhoneNumber from this FrozenPhoneNumber."""
        phone_number = PhoneNumber()
        phone_number.country_code = self._country_code
        phone_number.national_number = self._national_number
        phone_number.extension = self._extension
        phone_number.italian_leading_zero = self._italian_leading_zero
        phone_number.number_of_leading_zeros = self._number_of_leading_zeros
        phone_number.raw_input = self._raw_input
        phone_number.country_code_source = self._country_code_source
        phone_number.preferred_domestic_carrier_code = self._preferred_domestic_carrier_code
        return phone_number

# Utility class
cdef class PhoneNumberUtil:
    """
    Python wrapper for libphonenumber's PhoneNumberUtil.
    """
    # We'll get the util instance for each method call since GetInstance() returns a reference
    
    def format(self, PhoneNumber number, int format_type):
        """Format a phone number in the specified format."""
        cdef string formatted_number
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        util.Format(deref(number._phone_number), <CppPhoneNumberFormat>format_type, &formatted_number)
        return formatted_number.decode('utf-8')
    
    def is_valid_number(self, PhoneNumber number):
        """Return whether a phone number is valid."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        return util.IsValidNumber(deref(number._phone_number))
    
    def is_valid_number_for_region(self, PhoneNumber number, region_code):
        """Return whether a phone number is valid for a specific region."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        return util.IsValidNumberForRegion(
            deref(number._phone_number), 
            region_code.encode('utf-8')
        )
    
    def parse(self, number_to_parse, default_region):
        """Parse a string into a PhoneNumber object."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef PhoneNumber phone_number = PhoneNumber()
        cdef CppErrorType error_type
        
        error_type = util.Parse(
            number_to_parse.encode('utf-8'),
            default_region.encode('utf-8'),
            phone_number._phone_number
        )
        
        if error_type != 0:  # ERROR_NO_ERROR = 0
            # Map C++ error types to Python exception error types
            python_error_type = error_type - 1  # C++ starts from 1, Python from 0 for error codes
            raise NumberParseException(python_error_type, 
                                     f"Could not parse {number_to_parse} for region {default_region}")
        
        return phone_number
    
    def get_number_type(self, PhoneNumber number):
        """Get the type of the phone number."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        return util.GetNumberType(deref(number._phone_number))
    
    def get_region_code_for_number(self, PhoneNumber number):
        """Get the region code for a phone number."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef string region
        util.GetRegionCodeForNumber(deref(number._phone_number), &region)
        return region.decode('utf-8')
    
    def get_example_number(self, region_code):
        """Get an example phone number for a region."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef PhoneNumber phone_number = PhoneNumber()
        cdef bool success
        
        success = util.GetExampleNumber(
            region_code.encode('utf-8'),
            phone_number._phone_number
        )
        
        if not success:
            raise ValueError(f"Could not get example number for region {region_code}")
        
        return phone_number
    
    def get_example_number_for_type(self, region_code, number_type):
        """Get an example phone number for a region and number type."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef PhoneNumber phone_number = PhoneNumber()
        cdef bool success
        
        success = util.GetExampleNumberForType(
            region_code.encode('utf-8'),
            <CppPhoneNumberType>number_type,
            phone_number._phone_number
        )
        
        if not success:
            raise ValueError(f"Could not get example number for region {region_code} and type {number_type}")
        
        return phone_number
    
    def format_in_original_format(self, PhoneNumber number, region_calling_from):
        """Format a phone number in its original format."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef string formatted_number
        util.FormatInOriginalFormat(
            deref(number._phone_number),
            region_calling_from.encode('utf-8'),
            &formatted_number
        )
        return formatted_number.decode('utf-8')
    
    def format_out_of_country_calling_number(self, PhoneNumber number, region_calling_from):
        """Format a phone number for out-of-country calling."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef string formatted_number
        util.FormatOutOfCountryCallingNumber(
            deref(number._phone_number),
            region_calling_from.encode('utf-8'),
            &formatted_number
        )
        return formatted_number.decode('utf-8')
    
    def get_national_significant_number(self, PhoneNumber number):
        """Get the national significant number."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef string national_number
        util.GetNationalSignificantNumber(
            deref(number._phone_number),
            &national_number
        )
        return national_number.decode('utf-8')
    
    def is_possible_number_with_reason(self, PhoneNumber number):
        """Check if a number is possible with a reason."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        return util.IsPossibleNumberWithReason(deref(number._phone_number))
    
    def truncate_too_long_number(self, PhoneNumber number):
        """Truncate a too-long number."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        return util.TruncateTooLongNumber(number._phone_number)
    
    def get_supported_regions(self):
        """Get list of supported region codes."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef cppset[string] regions
        util.GetSupportedRegions(&regions)
        
        py_regions = []
        cdef cppset[string].iterator it = regions.begin()
        while it != regions.end():
            py_regions.append(deref(it).decode('utf-8'))
            postinc(it)  # Use pre-increment operator
        return py_regions
    
    def get_supported_global_network_calling_codes(self):
        """Get list of supported global network calling codes."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef cppset[int] calling_codes
        util.GetSupportedGlobalNetworkCallingCodes(&calling_codes)
        
        py_codes = []
        cdef cppset[int].iterator it = calling_codes.begin()
        while it != calling_codes.end():
            py_codes.append(deref(it))
            postinc(it)  # Use pre-increment operator
        return py_codes
    
    def get_supported_calling_codes(self):
        """Get list of all supported calling codes."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef cppset[int] calling_codes
        util.GetSupportedCallingCodes(&calling_codes)
        
        py_codes = []
        cdef cppset[int].iterator it = calling_codes.begin()
        while it != calling_codes.end():
            py_codes.append(deref(it))
            postinc(it)  # Use pre-increment operator
        return py_codes
    
    def get_supported_types_for_region(self, region_code):
        """Get list of supported phone number types for a region."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef cppset[CppPhoneNumberType] types
        util.GetSupportedTypesForRegion(region_code.encode('utf-8'), &types)
        
        py_types = []
        cdef cppset[CppPhoneNumberType].iterator it = types.begin()
        while it != types.end():
            py_types.append(deref(it))
            postinc(it)  # Use pre-increment operator
        return py_types
    
    def get_region_code_for_country_code(self, country_code):
        """Get the primary region code for a country calling code."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef string region_code
        util.GetRegionCodeForCountryCode(country_code, &region_code)
        
        if region_code.empty():
            return None
        return region_code.decode('utf-8')
    
    def get_region_codes_for_country_calling_code(self, country_calling_code):
        """Get all region codes for a country calling code."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef cpplist[string] region_codes
        util.GetRegionCodesForCountryCallingCode(country_calling_code, &region_codes)
        
        py_codes = []
        cdef cpplist[string].iterator it = region_codes.begin()
        while it != region_codes.end():
            py_codes.append(deref(it).decode('utf-8'))
            postinc(it)
        return py_codes
    
    def is_number_match(self, first_number, second_number):
        """Compare two phone numbers for equality."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef PhoneNumber first_phone
        cdef PhoneNumber second_phone
        
        # Convert inputs to PhoneNumber objects if needed
        if isinstance(first_number, str):
            first_phone = self.parse(first_number, "US")  # Default region
        elif isinstance(first_number, (PhoneNumber, FrozenPhoneNumber)):
            if isinstance(first_number, FrozenPhoneNumber):
                first_phone = first_number.to_phone_number()
            else:
                first_phone = first_number
        else:
            raise TypeError("first_number must be a string or PhoneNumber")
        
        if isinstance(second_number, str):
            second_phone = self.parse(second_number, "US")  # Default region
        elif isinstance(second_number, (PhoneNumber, FrozenPhoneNumber)):
            if isinstance(second_number, FrozenPhoneNumber):
                second_phone = second_number.to_phone_number()
            else:
                second_phone = second_number
        else:
            raise TypeError("second_number must be a string or PhoneNumber")
        
        return util.IsNumberMatch(deref(first_phone._phone_number), deref(second_phone._phone_number))
    
    def is_number_match_with_two_strings(self, first_number, second_number):
        """Compare two phone number strings for equality."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        return util.IsNumberMatchWithTwoStrings(
            first_number.encode('utf-8'),
            second_number.encode('utf-8')
        )
    
    def is_number_match_with_one_string(self, first_number, second_number):
        """Compare a PhoneNumber with a phone number string."""
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef PhoneNumber first_phone
        
        # Convert first number to PhoneNumber if needed
        if isinstance(first_number, (PhoneNumber, FrozenPhoneNumber)):
            if isinstance(first_number, FrozenPhoneNumber):
                first_phone = first_number.to_phone_number()
            else:
                first_phone = first_number
        else:
            raise TypeError("first_number must be a PhoneNumber or FrozenPhoneNumber")
        
        return util.IsNumberMatchWithOneString(
            deref(first_phone._phone_number),
            second_number.encode('utf-8')
        )
    
    def is_number_geographical(self, number_or_type, country_calling_code=None):
        """Check if a phone number or number type is geographical.
        
        Args:
            number_or_type: PhoneNumber, FrozenPhoneNumber, or PhoneNumberType
            country_calling_code: Required if number_or_type is PhoneNumberType
        
        Returns:
            bool: True if the number is geographical, False otherwise
        """
        cdef CppPhoneNumberUtil* util = CppPhoneNumberUtil.GetInstance()
        cdef PhoneNumber phone_number
        
        if isinstance(number_or_type, (PhoneNumber, FrozenPhoneNumber)):
            # Convert to PhoneNumber if needed
            if isinstance(number_or_type, FrozenPhoneNumber):
                phone_number = number_or_type.to_phone_number()
            else:
                phone_number = number_or_type
            
            return util.IsNumberGeographical(deref(phone_number._phone_number))
        
        elif isinstance(number_or_type, int):
            # Assume it's a PhoneNumberType
            if country_calling_code is None:
                raise ValueError("country_calling_code is required when number_or_type is PhoneNumberType")
            
            return util.IsNumberGeographical(<CppPhoneNumberType>number_or_type, country_calling_code)
        
        else:
            raise TypeError("number_or_type must be PhoneNumber, FrozenPhoneNumber, or PhoneNumberType")

# Singleton instance of PhoneNumberUtil
_phone_util = PhoneNumberUtil()

# Convenience functions
def parse(number_string, region=None):
    """Parse a phone number string into a PhoneNumber object."""
    if region is None:
        # Default to US if no region specified
        region = "US"
    return _phone_util.parse(number_string, region)

def format_number(number, format_type=PhoneNumberFormat.E164):
    """Format a phone number in the specified format."""
    return _phone_util.format(number, format_type)

def is_valid_number(number):
    """Check if a phone number is valid."""
    return _phone_util.is_valid_number(number)

def number_type(number):
    """Get the type of a phone number."""
    return _phone_util.get_number_type(number)

def get_example_number(region_code):
    """Get an example phone number for a region."""
    return _phone_util.get_example_number(region_code)

def parse_frozen(number_string, region=None):
    """Parse a phone number string into a FrozenPhoneNumber object."""
    mutable_number = parse(number_string, region)
    return FrozenPhoneNumber.from_phone_number(mutable_number)

def format_frozen_number(frozen_number, format_type=PhoneNumberFormat.E164):
    """Format a frozen phone number in the specified format."""
    # FrozenPhoneNumber already implements __str__ which uses formatting
    if format_type == PhoneNumberFormat.INTERNATIONAL:
        return str(frozen_number)
    else:
        # Convert to mutable for other format types
        mutable_number = frozen_number.to_phone_number()
        return format_number(mutable_number, format_type)

def is_valid_frozen_number(frozen_number):
    """Check if a frozen phone number is valid."""
    mutable_number = frozen_number.to_phone_number()
    return is_valid_number(mutable_number)

def get_frozen_number_type(frozen_number):
    """Get the type of a frozen phone number."""
    mutable_number = frozen_number.to_phone_number()
    return number_type(mutable_number)

def get_example_frozen_number(region_code):
    """Get an example frozen phone number for a region."""
    mutable_number = get_example_number(region_code)
    return FrozenPhoneNumber.from_phone_number(mutable_number)

# Metadata convenience functions
def get_supported_regions():
    """Get list of supported region codes."""
    return _phone_util.get_supported_regions()

def get_supported_global_network_calling_codes():
    """Get list of supported global network calling codes."""
    return _phone_util.get_supported_global_network_calling_codes()

def get_supported_calling_codes():
    """Get list of all supported calling codes."""
    return _phone_util.get_supported_calling_codes()

def get_supported_types_for_region(region_code):
    """Get list of supported phone number types for a region."""
    return _phone_util.get_supported_types_for_region(region_code)

def get_metadata_for_region(region_code):
    """Get phone metadata for a specific region."""
    return PhoneMetadata(region_code)

def region_code_for_country_code(country_code):
    """Get the primary region code for a country calling code."""
    return _phone_util.get_region_code_for_country_code(country_code)

def region_codes_for_country_calling_code(country_calling_code):
    """Get all region codes for a country calling code."""
    return _phone_util.get_region_codes_for_country_calling_code(country_calling_code)

# Global geocoder instance - use a pointer since it's not copyable
cdef PhoneNumberOfflineGeocoder* _geocoder = new PhoneNumberOfflineGeocoder()

def description_for_number(number, language="en", region=None):
    """
    Returns a text description for the given phone number, in the language provided.
    
    Args:
        number: PhoneNumber or FrozenPhoneNumber object
        language: Language code (e.g., "en", "fr", "de"). Defaults to "en".
        region: Optional region code for the user. If provided, descriptions will be
               adjusted based on the user's location.
    
    Returns:
        str: Description of the phone number location, or empty string if unavailable.
    """
    # Convert FrozenPhoneNumber to PhoneNumber if needed
    cdef PhoneNumber phone_number
    if isinstance(number, FrozenPhoneNumber):
        phone_number = number.to_phone_number()
    elif isinstance(number, PhoneNumber):
        phone_number = number
    else:
        raise TypeError("Expected PhoneNumber or FrozenPhoneNumber")
    
    cdef Locale locale
    cdef string description
    cdef string user_region_str
    
    # Create locale from language code
    locale = Locale(language.encode('utf-8'))
    
    if region is not None:
        user_region_str = region.encode('utf-8')
        description = deref(_geocoder).GetDescriptionForNumber(
            deref(phone_number._phone_number), 
            locale, 
            user_region_str
        )
    else:
        description = deref(_geocoder).GetDescriptionForNumber(
            deref(phone_number._phone_number), 
            locale
        )
    
    return description.decode('utf-8')

def description_for_valid_number(number, language="en", region=None):
    """
    Returns a text description for the given phone number, assuming it's valid.
    
    This method assumes the validity of the number has already been checked.
    
    Args:
        number: PhoneNumber or FrozenPhoneNumber object (assumed to be valid)
        language: Language code (e.g., "en", "fr", "de"). Defaults to "en".
        region: Optional region code for the user. If provided, descriptions will be
               adjusted based on the user's location.
    
    Returns:
        str: Description of the phone number location, or empty string if unavailable.
    """
    # Convert FrozenPhoneNumber to PhoneNumber if needed
    cdef PhoneNumber phone_number
    if isinstance(number, FrozenPhoneNumber):
        phone_number = number.to_phone_number()
    elif isinstance(number, PhoneNumber):
        phone_number = number
    else:
        raise TypeError("Expected PhoneNumber or FrozenPhoneNumber")
    
    cdef Locale locale
    cdef string description
    cdef string user_region_str
    
    # Create locale from language code
    locale = Locale(language.encode('utf-8'))
    
    if region is not None:
        user_region_str = region.encode('utf-8')
        description = deref(_geocoder).GetDescriptionForValidNumber(
            deref(phone_number._phone_number), 
            locale, 
            user_region_str
        )
    else:
        description = deref(_geocoder).GetDescriptionForValidNumber(
            deref(phone_number._phone_number), 
            locale
        )
    
    return description.decode('utf-8')

def country_name_for_number(number, language="en"):
    """
    Returns the country name for the given phone number in the specified language.
    
    This is a convenience function that extracts just the country-level information.
    
    Args:
        number: PhoneNumber or FrozenPhoneNumber object
        language: Language code (e.g., "en", "fr", "de"). Defaults to "en".
    
    Returns:
        str: Country name for the phone number, or empty string if unavailable.
    """
    # Convert FrozenPhoneNumber to PhoneNumber if needed
    cdef PhoneNumber phone_number
    if isinstance(number, FrozenPhoneNumber):
        phone_number = number.to_phone_number()
    elif isinstance(number, PhoneNumber):
        phone_number = number
    else:
        raise TypeError("Expected PhoneNumber or FrozenPhoneNumber")
    
    # Get the region for this number
    region_code = _phone_util.get_region_code_for_number(phone_number)
    if not region_code:
        return ""
    
    # Use the region-aware geocoding to get a more focused description
    return description_for_number(number, language, region_code)

# Number matching convenience functions
def is_number_match(first_number, second_number):
    """Compare two phone numbers for equality.
    
    Args:
        first_number: PhoneNumber, FrozenPhoneNumber, or string
        second_number: PhoneNumber, FrozenPhoneNumber, or string
    
    Returns:
        int: MatchType value indicating the type of match
    """
    return _phone_util.is_number_match(first_number, second_number)

def is_number_match_with_two_strings(first_number, second_number):
    """Compare two phone number strings for equality.
    
    Args:
        first_number: String representation of a phone number
        second_number: String representation of a phone number
    
    Returns:
        int: MatchType value indicating the type of match
    """
    return _phone_util.is_number_match_with_two_strings(first_number, second_number)

def is_number_match_with_one_string(first_number, second_number):
    """Compare a PhoneNumber with a phone number string.
    
    Args:
        first_number: PhoneNumber or FrozenPhoneNumber object
        second_number: String representation of a phone number
    
    Returns:
        int: MatchType value indicating the type of match
    """
    return _phone_util.is_number_match_with_one_string(first_number, second_number)

def is_number_geographical(number_or_type, country_calling_code=None):
    """Check if a phone number or number type is geographical.
    
    Args:
        number_or_type: PhoneNumber, FrozenPhoneNumber, or PhoneNumberType
        country_calling_code: Required if number_or_type is PhoneNumberType
    
    Returns:
        bool: True if the number is geographical, False otherwise
    """
    return _phone_util.is_number_geographical(number_or_type, country_calling_code)