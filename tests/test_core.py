import pytest

import phonenumbers


def test_unset_phone_number_fields_match_python_implementation():
    number = phonenumbers.PhoneNumber()

    assert number.country_code is None
    assert number.national_number is None
    assert number.extension is None
    assert number.italian_leading_zero is None
    assert number.number_of_leading_zeros is None
    assert number.raw_input is None
    assert number.country_code_source == 0
    assert number.preferred_domestic_carrier_code is None


def test_phone_number_repr_and_str_match_python_implementation():
    number = phonenumbers.PhoneNumber(
        country_code=39,
        national_number=212345678,
        extension="12",
        italian_leading_zero=False,
        number_of_leading_zeros=1,
        country_code_source=1,
        preferred_domestic_carrier_code="9",
    )

    assert repr(number) == (
        "PhoneNumber(country_code=39, national_number=212345678, "
        "extension='12', italian_leading_zero=False, "
        "number_of_leading_zeros=1, country_code_source=1, "
        "preferred_domestic_carrier_code='9')"
    )
    assert str(number) == (
        "Country Code: 39 National Number: 212345678 Leading Zero(s): False "
        "Number of leading zeros: 1 Extension: 12 Country Code Source: 1 "
        "Preferred Domestic Carrier Code: 9"
    )


def test_parse_and_keep_raw_input():
    number = phonenumbers.parse("+14153334444", keep_raw_input=True)

    assert number.raw_input == "+14153334444"
    assert number.country_code_source == 1


@pytest.mark.parametrize(
    ("override", "equal"),
    [
        ({"italian_leading_zero": False}, True),
        ({"italian_leading_zero": True}, False),
        ({"country_code_source": 0}, True),
        ({"number_of_leading_zeros": 1}, False),
        ({"raw_input": ""}, False),
        ({"extension": ""}, False),
        ({"preferred_domestic_carrier_code": ""}, False),
    ],
)
def test_phone_number_equality_matches_python_implementation(override, equal):
    number = phonenumbers.PhoneNumber(country_code=1, national_number=5)
    other = phonenumbers.PhoneNumber(
        country_code=1, national_number=5, **override
    )

    assert (number == other) is equal


def test_phone_number_type_values_match_python_implementation():
    assert phonenumbers.PhoneNumberType.FIXED_LINE == 0
    assert phonenumbers.PhoneNumberType.VOICEMAIL == 10
    assert phonenumbers.PhoneNumberType.UNKNOWN == 99


@pytest.mark.parametrize(
    ("value", "region", "e164", "region_code", "possible", "valid"),
    [
        ("+14153334444", None, "+14153334444", "US", True, True),
        ("818-934-7229", "US", "+18189347229", "US", True, True),
        ("+442072194272", None, "+442072194272", "GB", True, True),
        ("+11111111111", None, "+11111111111", None, True, False),
    ],
)
def test_parse_format_region_and_validation_contract(
    value, region, e164, region_code, possible, valid
):
    number = phonenumbers.parse(value, region)

    assert isinstance(number, phonenumbers.PhoneNumber)
    assert (
        phonenumbers.format_number(number, phonenumbers.PhoneNumberFormat.E164)
        == e164
    )
    assert phonenumbers.region_code_for_number(number) == region_code
    assert phonenumbers.is_possible_number(number) is possible
    assert phonenumbers.is_valid_number(number) is valid


@pytest.mark.parametrize(
    ("value", "region", "number_format", "expected"),
    [
        (
            "+14153458901",
            None,
            phonenumbers.PhoneNumberFormat.INTERNATIONAL,
            "+1 415-345-8901",
        ),
        (
            "+14153458901",
            None,
            phonenumbers.PhoneNumberFormat.NATIONAL,
            "(415) 345-8901",
        ),
        (
            "+5586995672691",
            None,
            phonenumbers.PhoneNumberFormat.INTERNATIONAL,
            "+55 86 99567-2691",
        ),
        (
            "+1 (833) Go-CLosE",
            None,
            phonenumbers.PhoneNumberFormat.E164,
            "+18334625673",
        ),
        (
            "+14153456789x123",
            None,
            phonenumbers.PhoneNumberFormat.INTERNATIONAL,
            "+1 415-345-6789 ext. 123",
        ),
    ],
)
def test_formatting_contract(value, region, number_format, expected):
    number = phonenumbers.parse(value, region)

    assert phonenumbers.format_number(number, number_format) == expected


def test_number_parse_exception_contract():
    with pytest.raises(
        phonenumbers.NumberParseException,
        match=(
            r"^\(1\) The string supplied did not seem to be a "
            r"phone number\.$"
        ),
    ) as exc_info:
        phonenumbers.parse("not a number")

    assert exc_info.value.error_type == 1
    assert (
        phonenumbers.phonenumberutil.NumberParseException
        is phonenumbers.NumberParseException
    )


@pytest.mark.parametrize(
    ("value", "region", "error_type"),
    [
        ("+999", "US", phonenumbers.NumberParseException.INVALID_COUNTRY_CODE),
        ("not a number", None, phonenumbers.NumberParseException.NOT_A_NUMBER),
        ("011", "US", phonenumbers.NumberParseException.TOO_SHORT_AFTER_IDD),
        ("+441", None, phonenumbers.NumberParseException.TOO_SHORT_NSN),
        ("9" * 21, "US", phonenumbers.NumberParseException.TOO_LONG),
    ],
)
def test_number_parse_exception_types(value, region, error_type):
    with pytest.raises(phonenumbers.NumberParseException) as exc_info:
        phonenumbers.parse(value, region)

    assert exc_info.value.error_type == error_type


@pytest.mark.parametrize(
    ("region", "country_code"),
    [("US", 1), ("GB", 44), ("BR", 55), (None, 0), ("ZZ", 0)],
)
def test_country_code_for_region(region, country_code):
    assert phonenumbers.country_code_for_region(region) == country_code


@pytest.mark.parametrize(
    ("country_code", "region"),
    [(1, "US"), (44, "GB"), (55, "BR"), (0, "ZZ"), (999, "ZZ")],
)
def test_region_code_for_country_code(country_code, region):
    assert phonenumbers.region_code_for_country_code(country_code) == region


def test_number_type_and_region_validation():
    us_number = phonenumbers.parse("+14153334444")
    toll_free_number = phonenumbers.parse("+18004444444")

    assert (
        phonenumbers.number_type(us_number)
        == phonenumbers.PhoneNumberType.FIXED_LINE_OR_MOBILE
    )
    assert (
        phonenumbers.number_type(toll_free_number)
        == phonenumbers.PhoneNumberType.TOLL_FREE
    )
    assert phonenumbers.is_valid_number_for_region(us_number, "US")
    assert not phonenumbers.is_valid_number_for_region(us_number, "GB")


@pytest.mark.parametrize(
    ("value", "national_number"),
    [
        ("+14153334444", "4153334444"),
        ("+442071838750", "2071838750"),
        ("+390212345678", "0212345678"),
    ],
)
def test_national_significant_number(value, national_number):
    parsed = phonenumbers.parse(value)

    assert phonenumbers.national_significant_number(parsed) == national_number


def test_phone_number_matcher_contract_and_unicode_offsets():
    text = "☎ +1 415-333-4444 café +44 20 7219 4272"

    matcher = phonenumbers.PhoneNumberMatcher(text, region=None)
    assert iter(matcher) is matcher
    assert matcher.has_next()
    first_match = matcher.next()
    assert first_match.raw_string == "+1 415-333-4444"
    assert matcher.has_next()

    matches = [first_match, *matcher]

    assert [
        (
            match.start,
            match.end,
            match.raw_string,
            phonenumbers.format_number(
                match.number, phonenumbers.PhoneNumberFormat.E164
            ),
        )
        for match in matches
    ] == [
        (2, 17, "+1 415-333-4444", "+14153334444"),
        (23, 39, "+44 20 7219 4272", "+442072194272"),
    ]
    assert not matcher.has_next()
