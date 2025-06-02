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
)

# Re-export the singleton
PhoneNumberUtil = BasePhoneNumberUtil