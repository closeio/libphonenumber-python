import os
from setuptools import setup, find_packages

setup(
    name="phonenumber-py",
    version="0.1.0",
    description="Python bindings for Google's libphonenumber library",
    author="Alec",
    author_email="example@example.com",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    python_requires=">=3.10",
)