# Compatibility

`closeio-phonenumbers` implements a focused subset of the pure-Python
`phonenumbers` interface. The supported API is intentionally explicit: code
that depends on APIs not listed here should not treat this package as a
drop-in replacement.

## Core API

The following names are available from the top-level `phonenumbers` package:

| Surface | Notes |
| --- | --- |
| `PhoneNumber` | Mutable number object with compatible optional-field semantics |
| `NumberParseException` | Includes the standard parse error codes |
| `PhoneNumberFormat` | `E164`, `INTERNATIONAL`, `NATIONAL`, and `RFC3966` |
| `PhoneNumberType` | Standard values, including `UNKNOWN == 99` |
| `Leniency` | Matcher leniency constants |
| `parse` | Supports an optional region and `keep_raw_input` |
| `format_number` | Formats parsed numbers using `PhoneNumberFormat` |
| `is_possible_number` | Checks whether a number has a possible shape |
| `is_valid_number` | Validates a number against libphonenumber metadata |
| `is_valid_number_for_region` | Validates a number for a specific region |
| `number_type` | Returns a `PhoneNumberType` value |
| `is_number_type_geographical` | Checks whether a type is geographical |
| `region_code_for_number` | Returns a region code or `None` |
| `region_code_for_country_code` | Returns the primary region for a country code |
| `country_code_for_region` | Returns the calling code for a region |
| `national_significant_number` | Returns the national significant number as text |
| `PhoneNumberMatcher` | Iterates over numbers found in text |
| `PhoneNumberMatch` | Exposes match offsets, text, and the parsed number |

`PhoneNumberMatcher` reports Python character offsets, including when text
before a match contains multibyte Unicode characters.

## Geocoder

The `phonenumbers.geocoder` module provides:

- `description_for_number`
- `description_for_valid_number`
- `country_name_for_number`
- `iter_prefix_descriptions`

Descriptions are resolved offline using metadata compiled from the pinned
libphonenumber release. `iter_prefix_descriptions` streams the same compiled
prefix metadata without materializing the full data set as Python objects. It
supports exact language, calling-code, and maximum-prefix-length filters. The
geocoder is loaded only when imported.

## Timezone lookup

The `phonenumbers.timezone` module provides:

- `UNKNOWN_TIMEZONE`
- `time_zones_for_number`
- `time_zones_for_geographical_number`

The C++ library does not expose the phone-prefix timezone mapper, so this
module uses the timezone map from the pinned libphonenumber release. The map
is parsed lazily on first use.

## Unsupported APIs

APIs outside the tables above are not currently provided. Notable omissions
include:

- carrier-name lookup
- short-number metadata and validation
- `AsYouTypeFormatter`
- example-number and general metadata queries
- alternate formatting data
- immutable `FrozenPhoneNumber` objects
- the complete set of matching and comparison helpers

Import the API you need in a compatibility test before replacing the
pure-Python distribution in an existing project.

## Supported platforms

Published artifacts target:

| Python | Operating system | Architectures |
| --- | --- | --- |
| CPython 3.12–3.14 | Linux (manylinux 2.28+) | x86-64, ARM64 |
| CPython 3.12–3.14 | macOS 15+ | x86-64, Apple Silicon |

Other Python versions, operating systems, and architectures are unsupported
unless built from source and validated independently.
