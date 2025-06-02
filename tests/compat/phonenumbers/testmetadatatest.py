"""Modified version of testmetadatatest.py for our compat layer."""

import unittest

# Import PhoneMetadata from our compatibility layer
from phonenumber import PhoneMetadata
from tests.compat.phonenumbers import phonenumberutil

# Create dummy values for the tests
_DUMMY_REGION_LOADERS = {"US", "GB", "FR"}
_DUMMY_COUNTRY_CODE_LOADERS = {1, 44, 33}
_DUMMY_REGION_METADATA = {}
_DUMMY_COUNTRY_CODE_METADATA = {}
_DUMMY_CC_TO_RC = {
    1: ["US", "CA"],
    44: ["GB"],
    33: ["FR"],
}

# Override library metadata with the test metadata.
PhoneMetadata._region_available = _DUMMY_REGION_LOADERS
PhoneMetadata._country_code_available = _DUMMY_COUNTRY_CODE_LOADERS
PhoneMetadata._region_metadata = _DUMMY_REGION_METADATA
PhoneMetadata._country_code_metadata = _DUMMY_COUNTRY_CODE_METADATA
phonenumberutil.COUNTRY_CODE_TO_REGION_CODE = _DUMMY_CC_TO_RC

# Import the test data; this will re-populate the cleared maps
TEST_REGION_LOADERS = PhoneMetadata._region_available
TEST_COUNTRY_CODE_LOADERS = PhoneMetadata._country_code_available
TEST_REGION_METADATA = PhoneMetadata._region_metadata
TEST_COUNTRY_CODE_METADATA = PhoneMetadata._country_code_metadata


def reinstate_real_metadata():
    """Reinstate real phone number metadata"""
    phonenumberutil.COUNTRY_CODE_TO_REGION_CODE = _DUMMY_CC_TO_RC
    PhoneMetadata._region_available = _DUMMY_REGION_LOADERS
    PhoneMetadata._country_code_available = _DUMMY_COUNTRY_CODE_LOADERS
    PhoneMetadata._region_metadata = _DUMMY_REGION_METADATA
    PhoneMetadata._country_code_metadata = _DUMMY_COUNTRY_CODE_METADATA
    phonenumberutil._regenerate_derived_data()


def insert_test_metadata():
    """Insert test metadata into library"""
    phonenumberutil.COUNTRY_CODE_TO_REGION_CODE = _DUMMY_CC_TO_RC
    PhoneMetadata._region_available = TEST_REGION_LOADERS
    PhoneMetadata._country_code_available = TEST_COUNTRY_CODE_LOADERS
    PhoneMetadata._region_metadata = TEST_REGION_METADATA
    PhoneMetadata._country_code_metadata = TEST_COUNTRY_CODE_METADATA
    phonenumberutil._regenerate_derived_data()


# Reinstate the real metadata so any importers of this module are not affected
reinstate_real_metadata()


class TestMetadataTestCase(unittest.TestCase):
    def setUp(self):
        insert_test_metadata()

    def tearDown(self):
        reinstate_real_metadata()