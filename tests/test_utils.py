"""Test utilities for libphonenumber-bindings."""

import sys
import os
import importlib
from unittest import mock

# Add the compatibility directory to the Python path
COMPAT_DIR = os.path.join(os.path.dirname(__file__), 'compat')
sys.path.insert(0, COMPAT_DIR)

def setup_test_environment():
    """
    Set up the test environment by adding necessary paths.
    
    This adds both our implementation and the compatibility layer to the Python path.
    """
    # Add project root to path
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    if project_root not in sys.path:
        sys.path.insert(0, project_root)
    
    # Add compatibility directory to path
    if COMPAT_DIR not in sys.path:
        sys.path.insert(0, COMPAT_DIR)
    
    # Pre-load the phonenumbers module from our compatibility layer
    try:
        import phonenumbers
        import phonenumbers.util
        import phonenumbers.phonenumberutil
    except ImportError:
        print("Warning: Could not import phonenumbers compatibility layer")
    
# Define a dummy test function to make pytest happy
def test_dummy():
    """A dummy test that always passes."""
    assert True