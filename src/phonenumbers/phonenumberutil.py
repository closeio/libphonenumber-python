from __future__ import annotations

from collections.abc import Iterator
from typing import Final

from . import _native
from .phonenumber import PhoneNumber


class NumberParseException(Exception):
    INVALID_COUNTRY_CODE: Final = 0
    NOT_A_NUMBER: Final = 1
    TOO_SHORT_AFTER_IDD: Final = 2
    TOO_SHORT_NSN: Final = 3
    TOO_LONG: Final = 4

    def __init__(self, error_type: int, msg: str) -> None:
        super().__init__(msg)
        self.error_type = error_type
        self._msg = msg

    def __reduce__(
        self,
    ) -> tuple[type[NumberParseException], tuple[int, str]]:
        return type(self), (self.error_type, self._msg)

    def __str__(self) -> str:
        return f"({self.error_type}) {self._msg}"


class PhoneNumberFormat:
    E164: Final = 0
    INTERNATIONAL: Final = 1
    NATIONAL: Final = 2
    RFC3966: Final = 3


class PhoneNumberType:
    FIXED_LINE: Final = 0
    MOBILE: Final = 1
    FIXED_LINE_OR_MOBILE: Final = 2
    TOLL_FREE: Final = 3
    PREMIUM_RATE: Final = 4
    SHARED_COST: Final = 5
    VOIP: Final = 6
    PERSONAL_NUMBER: Final = 7
    PAGER: Final = 8
    UAN: Final = 9
    VOICEMAIL: Final = 10
    UNKNOWN: Final = 99


class Leniency:
    POSSIBLE: Final = 0
    VALID: Final = 1
    STRICT_GROUPING: Final = 2
    EXACT_GROUPING: Final = 3


_PARSE_ERROR_MESSAGES: Final = {
    NumberParseException.INVALID_COUNTRY_CODE: (
        "Missing or invalid default region."
    ),
    NumberParseException.NOT_A_NUMBER: (
        "The string supplied did not seem to be a phone number."
    ),
    NumberParseException.TOO_SHORT_AFTER_IDD: (
        "Phone number too short after IDD."
    ),
    NumberParseException.TOO_SHORT_NSN: (
        "The string supplied is too short to be a phone number."
    ),
    NumberParseException.TOO_LONG: (
        "The string supplied is too long to be a phone number."
    ),
}


def parse(
    number: str,
    region: str | None = None,
    keep_raw_input: bool = False,
) -> PhoneNumber:
    native_error, parsed = _native.parse(number, region, keep_raw_input)
    if native_error:
        error_type = native_error - 1
        raise NumberParseException(
            error_type,
            _PARSE_ERROR_MESSAGES.get(error_type, "Could not parse number."),
        )
    return parsed


def format_number(number: PhoneNumber, number_format: int) -> str:
    return _native.format_number(number, number_format)


def is_possible_number(number: PhoneNumber) -> bool:
    return _native.is_possible_number(number)


def is_valid_number(number: PhoneNumber) -> bool:
    return _native.is_valid_number(number)


def is_valid_number_for_region(number: PhoneNumber, region: str) -> bool:
    return _native.is_valid_number_for_region(number, region)


def number_type(number: PhoneNumber) -> int:
    return _native.number_type(number)


def is_number_type_geographical(number_type: int, country_code: int) -> bool:
    return _native.is_number_type_geographical(number_type, country_code)


def region_code_for_number(number: PhoneNumber) -> str | None:
    return _native.region_code_for_number(number)


def country_code_for_region(region: str | None) -> int:
    return _native.country_code_for_region(region)


def region_code_for_country_code(country_code: int) -> str:
    return _native.region_code_for_country_code(country_code)


def national_significant_number(number: PhoneNumber) -> str:
    return _native.national_significant_number(number)


class PhoneNumberMatch:
    def __init__(
        self, start: int, raw_string: str, number: PhoneNumber
    ) -> None:
        if start < 0:
            raise ValueError("Start index must be >= 0")
        if raw_string is None:
            raise ValueError("Raw string cannot be None")
        if number is None:
            raise ValueError("Number cannot be None")
        self.start = start
        self.raw_string = raw_string
        self.number = number

    @property
    def end(self) -> int:
        return self.start + len(self.raw_string)

    def __repr__(self) -> str:
        return (
            f"PhoneNumberMatch(start={self.start}, "
            f"raw_string={self.raw_string!r}, numobj={self.number!r})"
        )

    def __str__(self) -> str:
        return f"PhoneNumberMatch [{self.start},{self.end}) {self.raw_string}"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, PhoneNumberMatch):
            return NotImplemented
        return (
            self.start == other.start
            and self.raw_string == other.raw_string
            and self.number == other.number
        )


class PhoneNumberMatcher(Iterator[PhoneNumberMatch]):
    def __init__(
        self,
        text: str | None,
        region: str | None,
        leniency: int = Leniency.VALID,
        max_tries: int = 65535,
    ) -> None:
        self.text = text or ""
        matches = _native.find_numbers(self.text, region, leniency, max_tries)
        text_bytes = self.text.encode()
        self._matches = [
            PhoneNumberMatch(
                len(text_bytes[:byte_start].decode()),
                raw_string,
                number,
            )
            for byte_start, raw_string, number in matches
        ]
        self._index = 0

    def __iter__(self) -> PhoneNumberMatcher:
        return self

    def __next__(self) -> PhoneNumberMatch:
        if not self.has_next():
            raise StopIteration
        match = self._matches[self._index]
        self._index += 1
        return match

    def has_next(self) -> bool:
        return self._index < len(self._matches)

    def next(self) -> PhoneNumberMatch:
        return self.__next__()
