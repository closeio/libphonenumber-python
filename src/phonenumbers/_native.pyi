from collections.abc import Sequence

LIBPHONENUMBER_VERSION: str

class PhoneNumber:
    def __init__(
        self,
        country_code: int | None = None,
        national_number: int | None = None,
        extension: str | None = None,
        italian_leading_zero: bool | None = None,
        number_of_leading_zeros: int | None = None,
        raw_input: str | None = None,
        country_code_source: int = 0,
        preferred_domestic_carrier_code: str | None = None,
    ) -> None: ...

    country_code: int | None
    national_number: int | None
    extension: str | None
    italian_leading_zero: bool | None
    number_of_leading_zeros: int | None
    raw_input: str | None
    country_code_source: int
    preferred_domestic_carrier_code: str | None

def parse(
    value: str, region: str | None, keep_raw_input: bool
) -> tuple[int, PhoneNumber]: ...
def format_number(number: PhoneNumber, number_format: int) -> str: ...
def is_possible_number(number: PhoneNumber) -> bool: ...
def is_valid_number(number: PhoneNumber) -> bool: ...
def is_valid_number_for_region(number: PhoneNumber, region: str) -> bool: ...
def number_type(number: PhoneNumber) -> int: ...
def is_number_type_geographical(
    number_type: int, country_code: int
) -> bool: ...
def region_code_for_number(number: PhoneNumber) -> str | None: ...
def country_code_for_region(region: str | None) -> int: ...
def region_code_for_country_code(country_code: int) -> str: ...
def region_codes_for_country_code(country_code: int) -> Sequence[str]: ...
def national_significant_number(number: PhoneNumber) -> str: ...
def find_numbers(
    text: str, region: str | None, leniency: int, max_tries: int
) -> Sequence[tuple[int, str, PhoneNumber]]: ...
def description_for_number(
    number: PhoneNumber,
    language: str,
    script: str | None,
    region: str | None,
    assume_valid: bool,
) -> str: ...
