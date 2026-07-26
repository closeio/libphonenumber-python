# closeio-phonenumbers

Low-memory CPython bindings for Google's C++
[libphonenumber](https://github.com/google/libphonenumber) implementation.
It provides a compatibility-focused subset of the widely used `phonenumbers`
Python API, backed by libphonenumber's native parser, formatter, matcher, and
geocoder.

The distribution is named `closeio-phonenumbers`, while the installed import
package is named `phonenumbers`:

```python
import phonenumbers
```

Do not install `closeio-phonenumbers` and the pure-Python `phonenumbers`
distribution in the same environment. Both provide the same import package.

This is not yet a drop-in replacement for every `phonenumbers` API. See
[COMPATIBILITY.md](COMPATIBILITY.md) for the supported surface.

## Features

- International phone-number parsing, formatting, and validation
- Region and number-type lookup
- Phone-number extraction from Unicode text
- Offline geographic descriptions
- Lazy phone-prefix timezone lookup
- Typed Python interfaces
- Repaired wheels with non-system native dependencies bundled

## Installation

```bash
python -m pip install closeio-phonenumbers
```

Prebuilt wheels are available for the following targets:

| Python | Platform | Architectures |
| --- | --- | --- |
| CPython 3.12 | Linux (manylinux 2.28+) | x86-64, ARM64 |
| CPython 3.12 | macOS 15+ | x86-64, Apple Silicon |

Installing a wheel does not require a compiler or ICU, Protobuf, or
libphonenumber development packages.

## Usage

```python
import phonenumbers
from phonenumbers import geocoder, timezone

number = phonenumbers.parse("+1 415-333-4444")

phonenumbers.is_valid_number(number)
# True

phonenumbers.format_number(number, phonenumbers.PhoneNumberFormat.E164)
# "+14153334444"

phonenumbers.region_code_for_number(number)
# "US"

geocoder.description_for_number(number, "en")
# "San Francisco, CA"

timezone.time_zones_for_number(number)
# ("America/Los_Angeles",)
```

Find numbers in text with `PhoneNumberMatcher`:

```python
text = "Call +1 415-333-4444 or +44 20 7219 4272."
for match in phonenumbers.PhoneNumberMatcher(text, region=None):
    print(match.start, match.end, match.raw_string)
```

## Versioning and source inputs

Versions have the form `<libphonenumber version>.<binding revision>`. For
example, `9.0.34.1` is binding revision 1 over libphonenumber `9.0.34`.

The libphonenumber and fallback Abseil source archives are pinned by SHA-256.
Both archives are included in the source distribution, allowing it to build
without network access once the declared Python and system build dependencies
are installed. Geographic and timezone metadata come from the same pinned
libphonenumber release.

## Building from source

A source build requires Python 3.12, a C++17 compiler, CMake, Ninja, ICU
development headers, Protocol Buffers headers, and `protoc`. A Git checkout
also needs the pinned source archives; a source distribution already includes
them.

On Ubuntu:

```bash
sudo apt-get install \
  build-essential cmake ninja-build pkg-config python3-dev \
  libicu-dev libprotobuf-dev protobuf-compiler
python tools/fetch_libphonenumber.py
python -m pip install build pytest
python -m build --wheel
python -m pip install dist/*.whl
python -m pytest
```

On macOS:

```bash
brew install cmake icu4c ninja pkg-config protobuf
export CMAKE_PREFIX_PATH="$(brew --prefix icu4c):$(brew --prefix protobuf)"
export PKG_CONFIG_PATH="$(brew --prefix icu4c)/lib/pkgconfig:\
$(brew --prefix protobuf)/lib/pkgconfig"
python tools/fetch_libphonenumber.py
python -m pip install build pytest
python -m build --wheel
python -m pip install dist/*.whl
python -m pytest
```

Use `python -m cibuildwheel --platform linux` or `--platform macos` to
produce repaired wheels using the configuration in `pyproject.toml`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development checks and instructions
for updating the pinned libphonenumber metadata.

## License

Licensed under the Apache License 2.0. See [LICENSE](LICENSE) and
[NOTICE](NOTICE) for attribution. This project is not affiliated with or
endorsed by Google.
