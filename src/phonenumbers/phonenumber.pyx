# distutils: language = c++
# cython: language_level=3

"""
Python bindings for Google's libphonenumber library.
"""

from libcpp cimport bool
from libcpp.string cimport string
from cython.operator cimport dereference as deref

# Use a relative import path
from .phonenumber_defs cimport (
    PhoneNumber as CppPhoneNumber,
    PhoneNumberUtil as CppPhoneNumberUtil,
    CppPhoneNumberFormat,
    CppPhoneNumberType,
    CppCountryCodeSource,
    CppValidationResult,
)

__version__ = "0.1.0"

# Enum definitions
class PhoneNumberFormat:
    """Phone number format options."""
    E164 = CppPhoneNumberFormat.FORMAT_E164
    INTERNATIONAL = CppPhoneNumberFormat.FORMAT_INTERNATIONAL
    NATIONAL = CppPhoneNumberFormat.FORMAT_NATIONAL
    RFC3966 = CppPhoneNumberFormat.FORMAT_RFC3966

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

class CountryCodeSource:
    """Country code source."""
    UNSPECIFIED = CppCountryCodeSource.SOURCE_UNSPECIFIED
    FROM_NUMBER_WITH_PLUS_SIGN = CppCountryCodeSource.SOURCE_FROM_NUMBER_WITH_PLUS_SIGN
    FROM_NUMBER_WITH_IDD = CppCountryCodeSource.SOURCE_FROM_NUMBER_WITH_IDD
    FROM_NUMBER_WITHOUT_PLUS_SIGN = CppCountryCodeSource.SOURCE_FROM_NUMBER_WITHOUT_PLUS_SIGN
    FROM_DEFAULT_COUNTRY = CppCountryCodeSource.SOURCE_FROM_DEFAULT_COUNTRY

class ValidationResult:
    """Validation result."""
    IS_POSSIBLE = CppValidationResult.RESULT_IS_POSSIBLE
    IS_POSSIBLE_LOCAL_ONLY = CppValidationResult.RESULT_IS_POSSIBLE_LOCAL_ONLY
    INVALID_COUNTRY_CODE = CppValidationResult.RESULT_INVALID_COUNTRY_CODE
    TOO_SHORT = CppValidationResult.RESULT_TOO_SHORT
    INVALID_LENGTH = CppValidationResult.RESULT_INVALID_LENGTH
    TOO_LONG = CppValidationResult.RESULT_TOO_LONG

# Phone number class
cdef class PhoneNumber:
    """
    Python representation of a phone number.
    """
    cdef CppPhoneNumber* _phone_number

    def __cinit__(self):
        self._phone_number = new CppPhoneNumber()
    
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
    
    def __cinit__(self, int country_code, object national_number, str extension="", 
                  bool italian_leading_zero=False, int number_of_leading_zeros=1,
                  str raw_input="", int country_code_source=0, 
                  str preferred_domestic_carrier_code=""):
        self._country_code = country_code
        self._national_number = national_number
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
        if not isinstance(other, FrozenPhoneNumber):
            return False
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
        cdef bool success
        
        success = util.Parse(
            number_to_parse.encode('utf-8'),
            default_region.encode('utf-8'),
            phone_number._phone_number
        )
        
        if not success:
            raise ValueError(f"Could not parse {number_to_parse} for region {default_region}")
        
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

def get_number_type(number):
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
    return get_number_type(mutable_number)

def get_example_frozen_number(region_code):
    """Get an example frozen phone number for a region."""
    mutable_number = get_example_number(region_code)
    return FrozenPhoneNumber.from_phone_number(mutable_number)