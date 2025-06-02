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

# Keep these imports commented out until we're ready to run the full test suite
"""
from .phonenumbertest import PhoneNumberTest
from .phonenumberutiltest import PhoneNumberUtilTest
from .shortnumberinfotest import ShortNumberInfoTest
from .asyoutypetest import AsYouTypeFormatterTest
from .examplenumberstest import ExampleNumbersTest
from .phonenumbermatchertest import PhoneNumberMatchTest, PhoneNumberMatcherTest
from .geocodertest import PhoneNumberGeocoderTest
from .carriertest import PhoneNumberToCarrierMapperTest
from .timezonetest import PhoneNumberToTimeZonesMapperTest
"""

if __name__ == '__main__':
    unittest.main()
