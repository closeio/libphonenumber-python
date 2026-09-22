# Contributing

Contributions are welcome. Please open an issue before implementing a large
API addition so its compatibility requirements and metadata cost can be
understood first.

## Development setup

Follow the source-build instructions in [README.md](README.md) to install the
native build dependencies and fetch the pinned source archives. Install the
development tools with:

```bash
python -m pip install -e ".[dev]"
```

Run the local checks before submitting a change:

```bash
ruff check src/phonenumbers tests tools
ruff format --check src/phonenumbers tests tools
mypy --strict src/phonenumbers
pytest
```

Changes to C++ bindings, build configuration, or packaged data should also be
verified by building and installing a wheel. CI builds and tests every
supported wheel target.

## Compatibility changes

New public APIs should include tests for both ordinary behavior and Python
semantics such as exceptions, optional fields, equality, and return types.
Update [COMPATIBILITY.md](COMPATIBILITY.md) whenever the supported surface
changes.

## Updating libphonenumber

For a new upstream release:

1. Update the libphonenumber version and SHA-256 in `CMakeLists.txt` and
   `tools/fetch_libphonenumber.py`.
2. Update the matching `python-phonenumbers` metadata version and SHA-256 in
   the same files, then compare its geocoding coverage with the generated
   native data.
3. Check whether libphonenumber changed its Abseil revision and update its
   commit and SHA-256 if needed.
4. Replace `src/phonenumbers/_data/timezones.txt` with the matching upstream
   `resources/timezones/map_data.txt`.
5. Update the source archives listed in `pyproject.toml`.
6. Set the package version to `<upstream version>.1` and review metadata
   changes with focused tests.

By submitting a contribution, you agree that it is licensed under the Apache
License 2.0.
