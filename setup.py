import os
from setuptools import setup, find_packages, Extension
from Cython.Build import cythonize

# Define the Cython extension
extensions = [
    Extension(
        "phonenumbers.phonenumber",
        sources=["src/phonenumbers/phonenumber.pyx"],
        include_dirs=[
            # Add libphonenumber include directories
            "/usr/local/include",
            "/opt/homebrew/include",
        ],
        libraries=["phonenumber", "geocoding"],
        library_dirs=[
            # Add libphonenumber library directories
            "/usr/local/lib",
            "/opt/homebrew/lib",
        ],
        language="c++",
        extra_compile_args=["-std=c++14"],
        extra_link_args=["-std=c++14"],
    )
]

setup(
    name="phonenumber-py",
    version="0.1.0",
    description="Python bindings for Google's libphonenumber library",
    author="Alec",
    author_email="example@example.com",
    packages=["phonenumbers", "phonenumbers.geocoder", "phonenumbers.prefix"],
    package_dir={"phonenumbers": "src/phonenumbers"},
    ext_modules=cythonize(extensions, compiler_directives={'language_level': 3}),
    python_requires=">=3.10",
    setup_requires=["cython"],
    install_requires=[],
    zip_safe=False,
)