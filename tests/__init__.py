"""Test initialization for libphonenumber-bindings."""

import unittest
import sys
import os

# Use our test utilities to set up the environment
from .test_utils import setup_test_environment

# Apply the test environment setup
setup_test_environment()

# Make our local test available
from .test_phonenumber import TestPhoneNumber

# Import the test classes from the python-phonenumbers project
try:
    from .phonenumbertest import PhoneNumberTest
    from .phonenumberutiltest import PhoneNumberUtilTest
    # These tests might require more implementation
    # Uncomment as we implement more functionality
    # from .shortnumberinfotest import ShortNumberInfoTest
    # from .asyoutypetest import AsYouTypeFormatterTest
    # from .examplenumberstest import ExampleNumbersTest
    # from .phonenumbermatchertest import PhoneNumberMatchTest, PhoneNumberMatcherTest
    # from .geocodertest import PhoneNumberGeocoderTest
    # from .carriertest import PhoneNumberToCarrierMapperTest
    # from .timezonetest import PhoneNumberToTimeZonesMapperTest
except ImportError as e:
    print(f"Warning: Could not import some test classes: {e}")

if __name__ == '__main__':
    unittest.main()
