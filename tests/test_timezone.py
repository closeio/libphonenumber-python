import pytest

import phonenumbers
from phonenumbers import timezone


@pytest.mark.parametrize(
    ("value", "timezones"),
    [
        ("+14153334444", ("America/Los_Angeles",)),
        ("+12029371478", ("America/New_York",)),
        ("+15053334444", ("America/Denver",)),
        ("+18643334444", ("America/New_York",)),
        ("+442071838750", ("Europe/London",)),
        ("+493028181234", ("Europe/Berlin",)),
        ("+976136234567", ("Asia/Choibalsan", "Asia/Ulaanbaatar")),
        ("+18880000000", (timezone.UNKNOWN_TIMEZONE,)),
        ("+80012345678", (timezone.UNKNOWN_TIMEZONE,)),
    ],
)
def test_time_zones_for_number(value, timezones):
    number = phonenumbers.parse(value)

    assert timezone.time_zones_for_number(number) == timezones


def test_unset_number_has_unknown_timezone():
    assert timezone.time_zones_for_number(phonenumbers.PhoneNumber()) == (
        timezone.UNKNOWN_TIMEZONE,
    )
