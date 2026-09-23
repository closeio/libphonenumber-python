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
        ("+33105123456", "en", "France"),
        ("+3726123456", "en", "Estonia"),
        ("+6043812345", "en", "Malaysia"),
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


def test_iter_prefix_descriptions_is_lazy():
    descriptions = geocoder.iter_prefix_descriptions("en")

    assert iter(descriptions) is descriptions
    assert next(descriptions) == ("1201", "New Jersey")


def test_iter_prefix_descriptions_filters_calling_code_and_length():
    descriptions = dict(
        geocoder.iter_prefix_descriptions(
            "en", calling_code=1, max_prefix_length=4
        )
    )

    assert descriptions["1307"] == "Wyoming"
    assert descriptions["1415"] == "California"
    assert "1307232" not in descriptions
    assert all(len(prefix) <= 4 for prefix in descriptions)
    assert list(descriptions) == sorted(descriptions, key=int)


@pytest.mark.parametrize(
    ("calling_code", "removed_prefix"),
    [(33, "33105"), (60, "60438"), (372, "3726")],
)
def test_iter_prefix_descriptions_matches_native_metadata(
    calling_code, removed_prefix
):
    descriptions = dict(
        geocoder.iter_prefix_descriptions("en", calling_code=calling_code)
    )

    assert removed_prefix not in descriptions


def test_iter_prefix_descriptions_preserves_language_tag():
    descriptions = dict(
        geocoder.iter_prefix_descriptions(
            "zh_Hant", calling_code=886, max_prefix_length=4
        )
    )

    assert descriptions["8862"] == "臺北"


def test_iter_prefix_descriptions_unknown_language_is_empty():
    assert list(geocoder.iter_prefix_descriptions("not-a-language")) == []
