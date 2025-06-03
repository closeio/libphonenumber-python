# Python Bindings for libphonenumber

Python bindings for Google's [libphonenumber](https://github.com/google/libphonenumber) C++ library. These bindings provide a lightweight, high-performance interface to the powerful libphonenumber library for working with international phone numbers.

> **⚠️ PROOF OF CONCEPT**: This project is currently in early development. Many tests fail and several modules are missing entirely. This is a work-in-progress implementation that demonstrates the feasibility of Cython bindings for libphonenumber, but is not yet ready for production use.

## Features

- Parse, format, and validate international phone numbers
- Determine the type of a phone number (mobile, fixed-line, toll-free, etc.)
- Get example phone numbers for any country
- Format numbers for display in different styles (E.164, international, national, RFC3966)
- Check if numbers are possible or valid
- Get region codes and country calling codes
- Support for both mutable and immutable phone number objects
- Fast C++ performance with a clean Python API

## Implementation Status

**Current State: Proof of Concept**

- ✅ Basic C++ bindings using Cython - **Core parsing and formatting works**
- ✅ Phone number parsing, formatting, and basic validation
- ✅ Some number type detection and regional information functions
- ✅ Basic enum support (PhoneNumberFormat, PhoneNumberType, etc.)
- ✅ Both mutable (PhoneNumber) and immutable (FrozenPhoneNumber) objects
- ❌ **Many tests fail** - compatibility with python-phonenumbers is incomplete
- ❌ **Missing modules**: carrier, geocoder, shortnumberinfo, timezone modules not implemented
- ❌ **Missing functions**: Many utility functions, number matchers, validators not yet bound
- 🚧 Additional utility functions and edge cases
- 🔜 Complete test compatibility and missing module implementations

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

All tests should be run inside Docker to ensure a consistent environment. We provide scripts in the `scripts/` directory:

```bash
# Run all tests
./scripts/test.sh

# Run a specific test method
./scripts/test.sh tests.phonenumberutiltest.PhoneNumberUtilTest.testGetCountryCodeForRegion

# Run tests with a filter pattern
./scripts/test.sh -f tests.phonenumberutiltest.PhoneNumberUtilTest.testIsPossibleNumber
```

#### Interactive Development with Docker

```bash
# Start a shell in the container
./scripts/run.sh bash

# Run any Python command
./scripts/run.sh python3 -c "import phonenumbers; print(phonenumbers.__version__)"

# Debug mode (supports inspecting headers even if bindings don't compile)
./scripts/debug.sh bash
```

The Docker container mounts your local code as a volume, so any changes you make on your host machine are immediately reflected in the container.

## Usage

> **Note**: These examples show the implemented functionality. Many other functions from python-phonenumbers are not yet implemented and will raise `AttributeError`.

```python
import phonenumbers

# Parse a phone number
phone = phonenumbers.parse("+1 650 253 0000", "US")

# Format it in different ways
print(phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.E164))          # +16502530000
print(phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.INTERNATIONAL))  # +1 650-253-0000
print(phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.NATIONAL))       # (650) 253-0000
print(phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.RFC3966))        # tel:+1-650-253-0000

# Validate a number
if phonenumbers.is_valid_number(phone):
    print("Valid number!")
else:
    print("Invalid number!")

# Check if a number is possible
if phonenumbers.is_possible_number(phone):
    print("Number is possible!")
```

### More advanced usage (implemented functions only)

```python
import phonenumbers

# Get an example number for a region
example = phonenumbers.get_example_number("GB")  # United Kingdom
print(example)  # +44 20 1234 5678 (example)

# Check the type of a number
mobile = phonenumbers.parse("+44 7400 123456", "GB")
if phonenumbers.number_type(mobile) == phonenumbers.PhoneNumberType.MOBILE:
    print("This is a mobile number")

# Create a number from scratch
phone = phonenumbers.PhoneNumber()
phone.country_code = 1
phone.national_number = 6502530000
print(phone)  # +1 650-253-0000

# Get region information
region = phonenumbers.region_code_for_number(phone)
print(f"This number is from: {region}")  # US

# Get country calling code for a region
country_code = phonenumbers.country_code_for_region("US")
print(f"US country calling code: {country_code}")  # 1

# Create immutable phone numbers
frozen_phone = phonenumbers.FrozenPhoneNumber(phone)
print(f"Frozen phone: {frozen_phone}")  # +1 650-253-0000

# Check if a string could be a valid number
if phonenumbers.is_possible_number_string("+1 555 123 4567", "US"):
    print("This string could be a valid number")
```

### What's NOT implemented yet

Many functions from python-phonenumbers are not yet available, including:

- `phonenumbers.carrier` module - carrier name lookup
- parts of `phonenumbers.geocoder` module - geographic location lookup  
- `phonenumbers.shortnumberinfo` module - short number validation
- `phonenumbers.timezone` module - timezone information
- Advanced number matching and comparison functions
- Many formatting and validation utilities
- AsYouType formatter
- And many more...

## Development

### Development Environment

We strongly recommend using Docker for development to ensure a consistent environment. The Docker setup uses Ubuntu 24.04 and Python 3.12, and automatically installs all dependencies needed for development including:

- libphonenumber C++ library
- ICU development libraries  
- Cython for building extensions
- pytest for testing

#### Setting Up the Development Environment

```bash
# Build the Docker image
./scripts/build.sh

# Run an interactive shell
./scripts/run.sh bash

# Run a specific command
./scripts/run.sh python3 -c "import phonenumbers; print(phonenumbers.__version__)"
```

#### Test Organization

The tests are organized as follows:

- `tests/*test.py`: Tests imported from python-phonenumbers reference implementation
- All tests use the unittest framework and test the actual C++ libphonenumber functionality

**⚠️ Important**: Most tests currently fail because many functions are not yet implemented. The test suite serves as a roadmap for what needs to be built.

#### Running Tests

Use the provided scripts to run tests in Docker:

```bash
# Run all tests (expect many failures)
./scripts/test.sh

# Run a specific test class  
./scripts/test.sh tests.phonenumberutiltest.PhoneNumberUtilTest

# Run a specific test method (these may work)
./scripts/test.sh tests.phonenumberutiltest.PhoneNumberUtilTest.testGetCountryCodeForRegion

# Run tests with a filter (use -f flag for specific methods)
./scripts/test.sh -f tests.phonenumberutiltest.PhoneNumberUtilTest.testIsPossibleNumber
```

**Note**: Many tests will fail with `AttributeError` because the functions are not implemented yet. Focus on individual test methods that correspond to implemented functionality.

#### Debugging

For debugging failed tests or development:

```bash
# Use debug mode (faster, no rebuild)
./scripts/debug.sh bash

# Run a single test with verbose output
./scripts/test.sh -v tests.phonenumberutiltest.PhoneNumberUtilTest.testFormatUSNumber

# Test specific functionality manually
./scripts/run.sh python3 -c "
import phonenumbers
phone = phonenumbers.parse('+1 650 253 0000', 'US')
print('Valid:', phonenumbers.is_valid_number(phone))
print('Region:', phonenumbers.region_code_for_number(phone))
"
```

## Roadmap

**Phase 1: Core Infrastructure (✅ Complete)**
1. ✅ Basic Cython bindings framework
2. ✅ Core phone number parsing and formatting
3. ✅ Basic validation functions

**Phase 2: Essential Functions (🚧 In Progress)**
4. 🚧 Complete all PhoneNumberUtil methods
5. 🚧 Implement missing validation and formatting functions
6. 🚧 Add number matching and comparison functions
7. 🚧 Fix failing tests from python-phonenumbers test suite

**Phase 3: Additional Modules (🔜 Future)**
8. 🔜 carrier module - carrier name lookup
9. 🔜 geocoder module - geographic location information
10. 🔜 shortnumberinfo module - short number validation
11. 🔜 timezone module - timezone information
12. 🔜 AsYouType formatter

**Phase 4: Polish and Performance (🔜 Future)**
13. 🔜 Performance optimizations and memory usage improvements
14. 🔜 Comprehensive documentation and examples
15. 🔜 Create pre-built wheels for common platforms

## License

Apache License 2.0 - Same as the libphonenumber library.

## Credits

- Google's [libphonenumber](https://github.com/google/libphonenumber) team for the amazing library
- This project is not affiliated with or endorsed by Google
- https://github.com/daviddrysdale/python-phonenumbers/, which this project's interface was developed to match