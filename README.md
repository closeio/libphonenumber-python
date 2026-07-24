# closeio-phonenumbers

Low-memory Python bindings for Google's C++
[libphonenumber](https://github.com/google/libphonenumber). The installed
module is named `phonenumbers`, so the Close application can migrate without
rewriting its phone-number call sites.

This project intentionally targets the API surface used by Close and
`tz-trout`; it is not yet a complete replacement for the upstream pure-Python
`phonenumbers` package. See [STATUS.md](STATUS.md) for the compatibility matrix
and the plan for expanding parity.

## Why the C++ implementation

Close uses parsing, formatting, validation, matching, offline geocoding, and
phone-prefix timezone lookup. The Rust `phonenumber` crate only implements the
core parsing and validation subset. It has neither geocoder data nor timezone
data, so Rust bindings would require two additional data implementations and
would not deliver a single low-memory replacement.

The C++ port provides the core implementation, matcher, and offline geocoder.
This package adds the missing timezone mapper using Google's pinned 86 KB
prefix map. The map is loaded lazily and occupies a small fraction of the
memory used by the pure-Python geocoder objects.

## Reproducibility

Version `9.0.34.1` means binding revision 1 over libphonenumber metadata
`9.0.34`. CMake verifies pinned archives for that release and its fallback
Abseil revision. Both archives are included in the sdist, so an sdist build
needs no network once its declared build and system dependencies are installed.
Linux uses the pinned Abseil fallback; macOS uses the ABI-compatible Abseil
installed with Homebrew's Protobuf. `auditwheel` or `delocate` bundles remaining
non-system native libraries into each wheel, so target systems do not install
`libphonenumber-dev`, ICU or Protobuf development packages, or a compiler.

The package distribution is named `closeio-phonenumbers` because the
`phonenumbers` project name is owned on PyPI. It still installs the
`phonenumbers` import package. Do not install it alongside the pure-Python
`phonenumbers` distribution.

## Supported artifacts

Release tags build and publish wheels for:

- CPython 3.12
- Linux x86-64 and ARM64 (manylinux 2.28 or newer)
- macOS 15 or newer, on x86-64 and Apple Silicon

This is the current Close production and development runtime. Add and test a
new wheel target before changing Close's Python version or supported platform.

## Usage

```python
import phonenumbers
from phonenumbers import geocoder, timezone

number = phonenumbers.parse("+1 415-333-4444")

phonenumbers.format_number(number, phonenumbers.PhoneNumberFormat.E164)
# "+14153334444"

geocoder.description_for_number(number, "en")
# "San Francisco, CA"

timezone.time_zones_for_number(number)
# ("America/Los_Angeles",)
```

## Local build

A source build requires a C++17 compiler, CMake, Ninja, ICU development
headers, Protocol Buffers headers, and `protoc`. On Ubuntu:

```bash
sudo apt-get install \
  build-essential libicu-dev libprotobuf-dev protobuf-compiler
python tools/fetch_libphonenumber.py
python -m pip install build
python -m build --wheel
python -m pip install dist/*.whl
pytest
```

On macOS, install the native dependencies with Homebrew:

```bash
brew install icu4c pkg-config protobuf
export CMAKE_PREFIX_PATH="$(brew --prefix icu4c):$(brew --prefix protobuf)"
export PKG_CONFIG_PATH="$(brew --prefix icu4c)/lib/pkgconfig:$(brew --prefix protobuf)/lib/pkgconfig"
python tools/fetch_libphonenumber.py
python -m pip install build
python -m build --wheel
python -m pip install dist/*.whl
pytest
```

Use `python -m cibuildwheel --platform linux` or `--platform macos` to
produce the same repaired wheels as CI.
