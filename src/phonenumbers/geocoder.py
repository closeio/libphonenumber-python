from collections.abc import Iterator

from . import _native
from .phonenumber import PhoneNumber


def description_for_number(
    numobj: PhoneNumber,
    lang: str,
    script: str | None = None,
    region: str | None = None,
) -> str:
    return _native.description_for_number(numobj, lang, script, region, False)


def description_for_valid_number(
    numobj: PhoneNumber,
    lang: str,
    script: str | None = None,
    region: str | None = None,
) -> str:
    return _native.description_for_number(numobj, lang, script, region, True)


def country_name_for_number(
    numobj: PhoneNumber,
    lang: str,
    script: str | None = None,
    region: str | None = None,
) -> str:
    country_code = numobj.country_code
    if country_code is None:
        return ""

    region_codes = _native.region_codes_for_country_code(country_code)
    if len(region_codes) > 1:
        valid_regions = [
            region_code
            for region_code in region_codes
            if _native.is_valid_number_for_region(numobj, region_code)
        ]
        if len(valid_regions) != 1:
            return ""

    return _native.description_for_number(numobj, lang, script, "ZZ", True)


def iter_prefix_descriptions(
    language: str,
    *,
    calling_code: int | None = None,
    max_prefix_length: int | None = None,
) -> Iterator[tuple[str, str]]:
    """Lazily iterate over compiled geocoding prefix descriptions.

    Language tags are matched exactly against the compiled metadata. Prefixes
    include the country calling code and are returned as digit strings.
    """
    return _native.iter_prefix_descriptions(
        language, calling_code, max_prefix_length
    )


__all__ = [
    "country_name_for_number",
    "description_for_number",
    "description_for_valid_number",
    "iter_prefix_descriptions",
]
