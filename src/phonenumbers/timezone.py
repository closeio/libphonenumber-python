from __future__ import annotations

from functools import cache
from importlib import resources
from typing import Final

from .phonenumber import PhoneNumber
from .phonenumberutil import (
    PhoneNumberFormat,
    PhoneNumberType,
    format_number,
    is_number_type_geographical,
    number_type,
)

UNKNOWN_TIMEZONE: Final = "Etc/Unknown"
_UNKNOWN_TIME_ZONES: Final = (UNKNOWN_TIMEZONE,)


@cache
def _timezone_data() -> tuple[dict[str, tuple[str, ...]], int]:
    data: dict[str, tuple[str, ...]] = {}
    longest_prefix = 0
    path = resources.files("phonenumbers").joinpath("_data", "timezones.txt")
    with path.open(encoding="utf-8") as timezone_file:
        for line in timezone_file:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            prefix, raw_timezones = line.split("|", maxsplit=1)
            data[prefix] = tuple(raw_timezones.split("&"))
            longest_prefix = max(longest_prefix, len(prefix))
    return data, longest_prefix


def _lookup(number: str) -> tuple[str, ...]:
    data, longest_prefix = _timezone_data()
    for prefix_length in range(min(len(number), longest_prefix), 0, -1):
        if timezones := data.get(number[:prefix_length]):
            return timezones
    return _UNKNOWN_TIME_ZONES


def time_zones_for_geographical_number(
    numobj: PhoneNumber,
) -> tuple[str, ...]:
    e164_number = format_number(numobj, PhoneNumberFormat.E164)
    if not e164_number.startswith("+"):
        raise RuntimeError("Expected E.164 number to start with +")
    return _lookup(e164_number[1:])


def time_zones_for_number(numobj: PhoneNumber) -> tuple[str, ...]:
    phone_number_type = number_type(numobj)
    if phone_number_type == PhoneNumberType.UNKNOWN:
        return _UNKNOWN_TIME_ZONES
    country_code = numobj.country_code
    if country_code is None:
        return _UNKNOWN_TIME_ZONES
    if not is_number_type_geographical(phone_number_type, country_code):
        return _lookup(str(country_code))
    return time_zones_for_geographical_number(numobj)


__all__ = [
    "UNKNOWN_TIMEZONE",
    "time_zones_for_geographical_number",
    "time_zones_for_number",
]
