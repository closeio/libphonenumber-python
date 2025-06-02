"""
Geocoding functionality for phone numbers.

This module provides functions to get geographical descriptions for phone numbers,
including city names, region names, and country names.
"""

from ..phonenumber import (
    description_for_number,
    description_for_valid_number, 
    country_name_for_number
)

__all__ = [
    'description_for_number',
    'description_for_valid_number',
    'country_name_for_number'
]