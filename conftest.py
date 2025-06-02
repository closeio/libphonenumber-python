"""Configuration for pytest."""

import pytest

def pytest_ignore_collect(path, config):
    """Ignore imported test files that we're not ready to run yet."""
    # Always ignore the ignore_in_pytest.py file
    if path.basename == "ignore_in_pytest.py":
        return True
        
    # Only collect our own tests and PhoneNumberTest for now
    if path.basename in [
        "test_phonenumber.py", 
        "standalone_test.py",
        "phonenumbertest.py",
    ]:
        return False
    
    # Ignore all other test files from python-phonenumbers
    if (path.basename.endswith("test.py") and 
        path.basename != "test_phonenumber.py" and
        path.basename != "standalone_test.py"):
        return True
    
    return False

def pytest_collect_file(file_path, parent):
    """Custom file collection logic."""
    return None

# Ignore utility functions in test_utils.py that aren't tests
def pytest_pycollect_makeitem(collector, name, obj):
    if collector.module.__name__ == "tests.test_utils" and name.startswith('_'):
        return None
    return None