# Python Bindings for libphonenumber

Python bindings for Google's [libphonenumber](https://github.com/google/libphonenumber) C++ library. These bindings provide a lightweight, high-performance interface to the powerful libphonenumber library for working with international phone numbers.

> **Note:** This package currently provides a pure Python implementation that mimics the libphonenumber API. The C++ bindings are under development. The goal is to provide a seamless transition between the mock implementation and the real C++ bindings.

## Features

- Parse, format, and validate international phone numbers
- Determine the type of a phone number (mobile, fixed-line, toll-free, etc.)
- Get example phone numbers for any country
- Format numbers for display in different styles (E.164, international, national, RFC3966)
- Full access to all libphonenumber functionality
- Fast C++ performance with a clean Python API

## Implementation Status

- ✅ Pure Python API compatible with libphonenumber functionality
- 🚧 C++ bindings using Cython (in progress)
- 🔜 Performance optimizations and full test coverage

See [STATUS.md](STATUS.md) for detailed implementation status and next steps.

## Installation

### Prerequisites

- Python 3.10 or later

### Install from source

```bash
# Clone and install the package
git clone https://github.com/yourusername/libphonenumber-bindings.git
cd libphonenumber-bindings
pip install -e .
```

### Using Docker

We provide a Docker-based development and testing environment that includes all necessary dependencies.

#### Prerequisites for Docker
- Docker
- Docker Compose

#### Running Tests in Docker

All tests should be run inside Docker to ensure a consistent environment. We provide a unified script for running tests:

```bash
./run-in-docker.sh python -m tests
```

#### Interactive Development with Docker

```bash
# Start a shell in the container
./run-in-docker.sh bash
```

The Docker container mounts your local code as a volume, so any changes you make on your host machine are immediately reflected in the container.

## Usage

```python
from phonenumber import parse, format_number, PhoneNumberFormat, is_valid_number

# Parse a phone number
phone = parse("+1 650 253 0000", "US")

# Format it in different ways
print(format_number(phone, PhoneNumberFormat.E164))          # +16502530000
print(format_number(phone, PhoneNumberFormat.INTERNATIONAL))  # +1 650-253-0000
print(format_number(phone, PhoneNumberFormat.NATIONAL))       # (650) 253-0000
print(format_number(phone, PhoneNumberFormat.RFC3966))        # tel:+1-650-253-0000

# Validate a number
if is_valid_number(phone):
    print("Valid number!")
else:
    print("Invalid number!")
```

### More advanced usage

```python
from phonenumber import (
    PhoneNumberUtil, PhoneNumber, PhoneNumberType, 
    get_number_type, get_example_number
)

# Get an example number for a region
example = get_example_number("GB")  # United Kingdom
print(example)  # +44 20 1234 5678 (example)

# Check the type of a number
mobile = parse("+44 7400 123456", "GB")
if get_number_type(mobile) == PhoneNumberType.MOBILE:
    print("This is a mobile number")

# Create a number from scratch
phone = PhoneNumber()
phone.country_code = 1
phone.national_number = 6502530000
print(phone)  # +1 650-253-0000

# Get the PhoneNumberUtil singleton for advanced operations
util = PhoneNumberUtil()
region = util.get_region_code_for_number(phone)
print(f"This number is from: {region}")  # US
```

## Development

### Development Environment

We strongly recommend using Docker for development to ensure a consistent environment. The Docker setup uses Ubuntu 24.04 and Python 3.10+, and automatically installs all dependencies needed for development.

#### Setting Up the Development Environment

```bash
# Build the Docker image
docker-compose build

# Run an interactive shell
docker-compose run --rm phonenumber-py bash

# Run a specific command
docker-compose run --rm phonenumber-py python3 -c "import phonenumber; print(phonenumber.__version__)"
```

#### Test Organization

The tests are organized as follows:

- `tests/test_*.py`: Our custom tests for the package
- `tests/compat/`: Compatibility layer for running imported tests
- `tests/*test.py`: Tests imported from python-phonenumbers reference implementation

#### Running Tests

Always use the provided `run_tests.sh` script to run tests in Docker:

```bash
# Run all tests
./run_tests.sh

# Run a specific test class
./run_tests.sh -m specific phonenumbertest.PhoneNumberTest

# Run tests in verbose mode
./run_tests.sh -v

# Run tests matching a specific pattern
./run_tests.sh -k "country_code"
```

For more options, run `./run_tests.sh --help`

## Roadmap

1. Complete the C++ bindings using Cython
2. Add full support for all libphonenumber features
3. Implement performance optimizations
4. Add comprehensive tests and documentation
5. Create pre-built wheels for common platforms

## License

Apache License 2.0 - Same as the libphonenumber library.

## Credits

- Google's [libphonenumber](https://github.com/google/libphonenumber) team for the amazing library
- This project is not affiliated with or endorsed by Google