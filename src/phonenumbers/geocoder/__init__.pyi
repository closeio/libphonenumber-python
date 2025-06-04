"""Type stubs for phonenumbers.geocoder module."""

from .. import PhoneNumber

def description_for_number(
    number: PhoneNumber, 
    language: str = "en", 
    region: str | None = None
) -> str: ...

def description_for_valid_number(
    number: PhoneNumber, 
    language: str = "en", 
    region: str | None = None
) -> str: ...

def country_name_for_number(number: PhoneNumber, language: str = "en") -> str: ...