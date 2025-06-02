"""
Functions in this file are used by run_test.py but should be ignored by pytest.
"""

def run_specific_test(test_class):
    """
    Run a specific test class.
    
    Args:
        test_class: The test class to run
    """
    import unittest
    from .test_utils import setup_test_environment
    setup_test_environment()
    unittest.main(defaultTest=test_class.__name__)