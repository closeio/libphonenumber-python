import pytest

import phonenumbers
from phonenumbers import geocoder


@pytest.mark.parametrize(
    ("value", "language", "description"),
    [
        ("+14153334444", "en", "San Francisco, CA"),
        ("+12029371478", "en", "Washington D.C."),
        ("+16502486188", "en", "California"),
        ("+442071838750", "en", "London"),
        ("+493028181234", "en", "Berlin"),
        ("+5586995672691", "en", "Piauí"),
    ],
)
def test_description_for_number(value, language, description):
    number = phonenumbers.parse(value)

    assert geocoder.description_for_number(number, language) == description
    assert (
        geocoder.description_for_valid_number(number, language) == description
    )


@pytest.mark.parametrize(
    ("value", "language", "country"),
    [
        ("+14153334444", "en", "United States"),
        ("+14165551234", "en", "Canada"),
        ("+493028181234", "de", "Deutschland"),
        ("+442071838750", "en", "United Kingdom"),
        ("+18004444444", "en", ""),
        ("+12425551234", "en", ""),
    ],
)
def test_country_name_for_number(value, language, country):
    number = phonenumbers.parse(value)

    assert geocoder.country_name_for_number(number, language) == country


def test_invalid_number_has_no_description():
    number = phonenumbers.parse("+11111111111")

    assert geocoder.description_for_number(number, "en") == ""
