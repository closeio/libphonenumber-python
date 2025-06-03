"""
Phone number utility functions.

This module provides utility functions for working with phone numbers,
including geographical checks and other utility operations.
"""

from .phonenumber import (
    is_number_geographical,
    is_number_match,
    is_number_match_with_two_strings,
    is_number_match_with_one_string,
    parse,
    format_number,
    is_valid_number,
    number_type,
    get_example_number,
    PhoneNumberUtil,
    PhoneNumberFormat,
    PhoneNumberType,
    MatchType,
    ValidationResult,
    CountryCodeSource,
    NumberParseException,
)

# Re-export the singleton instance
_phone_util = PhoneNumberUtil()

# Export all the main functions
__all__ = [
    'is_number_geographical',
    'is_number_match',
    'is_number_match_with_two_strings', 
    'is_number_match_with_one_string',
    'parse',
    'format_number',
    'is_valid_number',
    'number_type',
    'get_example_number',
    'PhoneNumberUtil',
    'PhoneNumberFormat',
    'PhoneNumberType',
    'MatchType',
    'ValidationResult',
    'CountryCodeSource',
    'NumberParseException',
]