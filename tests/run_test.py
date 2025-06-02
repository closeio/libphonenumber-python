#!/usr/bin/env python
"""
Test runner for individual tests.

Usage:
    python run_test.py test_name
    
Example:
    python run_test.py phonenumbertest.PhoneNumberTest
"""

import sys
import os
import importlib
import unittest

# Add the test directory to the path
test_dir = os.path.dirname(os.path.abspath(__file__))
if test_dir not in sys.path:
    sys.path.insert(0, test_dir)

# Add the project root to the path
project_root = os.path.abspath(os.path.join(test_dir, '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

# Import the test utilities
from test_utils import setup_test_environment

def main():
    """Run the specified test."""
    if len(sys.argv) < 2:
        print("Usage: python run_test.py test_name")
        print("Example: python run_test.py phonenumbertest.PhoneNumberTest")
        return
    
    # Set up the test environment
    setup_test_environment()
    
    # Get the test name
    test_name = sys.argv[1]
    
    # Split into module and test class
    if '.' in test_name:
        module_name, class_name = test_name.split('.', 1)
    else:
        module_name, class_name = test_name, None
    
    try:
        # Import the module
        module = importlib.import_module(module_name)
        
        # If a class name is specified, run just that class
        if class_name:
            test_class = getattr(module, class_name)
            suite = unittest.TestLoader().loadTestsFromTestCase(test_class)
        else:
            # Otherwise run all tests in the module
            suite = unittest.TestLoader().loadTestsFromModule(module)
        
        # Run the tests
        result = unittest.TextTestRunner(verbosity=2).run(suite)
        
        # Return 0 if all tests passed, 1 otherwise
        sys.exit(not result.wasSuccessful())
    
    except ImportError:
        print(f"Error: Could not import module '{module_name}'")
        sys.exit(1)
    except AttributeError:
        print(f"Error: Could not find test class '{class_name}' in module '{module_name}'")
        sys.exit(1)

if __name__ == "__main__":
    main()