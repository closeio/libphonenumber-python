# Compatibility and release plan

## Shippable scope

The first release is considered compatible when the native and pure-Python
implementations produce the same result for every Close and `tz-trout` call
site below. The checked rows are implemented and covered by focused contract
tests.

| Surface | Consumer | Status |
| --- | --- | --- |
| `PhoneNumber`, including unset-field semantics | Close, tz-trout | ✅ |
| `PhoneNumberType` values, including `UNKNOWN == 99` | timezone mapper | ✅ |
| `parse`, `NumberParseException` | Close, tz-trout | ✅ |
| `format_number`, `PhoneNumberFormat` | Close | ✅ |
| `is_possible_number`, `is_valid_number` | Close | ✅ |
| `region_code_for_number` | Close, tz-trout | ✅ |
| `region_code_for_country_code` | tz-trout | ✅ |
| `country_code_for_region` | Close | ✅ |
| `national_significant_number` | Close area-code lookup | ✅ |
| `PhoneNumberMatcher` and Unicode offsets | Close text extraction | ✅ |
| `geocoder.description_for_number` | Close locality and notifications | ✅ |
| `timezone.time_zones_for_number` | tz-trout | ✅ |
| Linux CPython 3.12 x86-64 wheel | Close production | CI gate |
| Linux CPython 3.12 ARM64 wheel | Close development and CI | CI gate |
| macOS CPython 3.12 x86-64 wheel | Local development | CI gate |
| macOS CPython 3.12 Apple Silicon wheel | Local development | CI gate |
| Wheel has no external non-system library dependency | Close images | CI gate |

`geocoder`, `timezone`, and their data remain lazy. Importing the top-level
package must not initialize either data set.

## Deliberate architecture

- Pin libphonenumber and its fallback Abseil revision by archive hash in CMake.
  Core and geocoder metadata therefore cannot change during an application
  image build, and both source archives are included in the sdist.
- Use the pinned Abseil fallback on Linux. On macOS, use the ABI-compatible
  Abseil installed with Homebrew's Protobuf rather than mixing incompatible
  header and runtime versions.
- Statically link libphonenumber and its geocoder into the extension. Repair
  release wheels with `auditwheel` on Linux and `delocate` on macOS so ICU,
  Protobuf, and other non-system runtime dependencies are bundled rather than
  installed on target systems.
- Ship Google's timezone prefix map as package data. The C++ port has no
  timezone mapper; pretending this can be bound from C++ would leave tz-trout
  broken. The small map is parsed lazily by `phonenumbers.timezone`.
- Publish as the `closeio-phonenumbers` distribution while retaining the
  `phonenumbers` import name. This avoids attempting to publish over the
  existing PyPI project.

The Rust crate can be reconsidered only if it gains maintained geocoder and
phone-prefix timezone implementations. Until then, Rust would duplicate both
missing subsystems and has no long-term advantage for this use case.

## Parity expansion plan

The package does not claim drop-in parity with every public API in
pure-Python `phonenumbers`. Reach that point in independently releasable
stages:

1. **Close contract (this release)**
   - Run this repository's contract tests on both wheel architectures.
   - Run the Close phone-number, geocoder, GraphQL, notification, and timezone
     suites against the built wheel.
   - Run the full tz-trout suite against the built wheel.
   - Generate a differential corpus from production-shaped countries,
     extensions, invalid input, Unicode text, and known regressions; compare
     results with pure-Python `phonenumbers` pinned to the same metadata
     version.
2. **Core public API**
   - Add remaining format variants, number matching, examples, and metadata
     queries only with differential tests.
   - Match Python exception types, enum integer values, optional-field state,
     mutation, equality, repr, and pickle behavior rather than exposing raw
     C++ semantics.
3. **Additional datasets**
   - Bind or compactly implement carrier and short-number APIs.
   - Keep each dataset lazy and add an RSS budget so broader parity cannot
     silently erase the memory improvement.
4. **Interactive formatting and advanced matching**
   - Add `AsYouTypeFormatter`, alternate formats, advanced candidate/grouping
     behavior, and less-used leniency modes.
5. **Platform expansion**
   - Add a wheel only when it has a native CI runner, repaired-library audit,
     and install test. Python upgrades require wheels before Close changes its
     runtime.

No stage is complete by copying upstream tests and skipping failures. The
compatibility matrix must name every intentionally unsupported API.

## Release and rollout gates

1. Make the repository public, reserve `closeio-phonenumbers` on PyPI, and
   configure the `pypi` trusted-publisher environment.
2. Build the x86-64 and ARM64 manylinux and macOS wheels plus the sdist from a
   version tag. Verify the sdist builds without network access after build
   dependencies are installed. Inspect Linux wheels with `auditwheel show` and
   macOS wheels with `delocate-listdeps`; installing a wheel in a clean target
   must not invoke a compiler or install OS packages.
3. Release a tz-trout version whose dependency changes from `phonenumbers` to
   `closeio-phonenumbers`. Its full test suite must pass without the original
   distribution installed.
4. Update Close to the exact tz-trout and native-package versions with hashes.
   Do not add `libphonenumber-dev` or `libicu-dev` to the application image.
5. Verify that `pip check` passes and only one distribution provides the
   `phonenumbers` import package.
6. Compare import time, startup time, and peak/RSS memory with the current
   package. Exercise parsing, matching, geocoder, and timezone paths before and
   after measurement.
7. Canary one web deployment, monitor import and parsing exceptions, then roll
   out. Rollback is a requirements-only change to the prior tz-trout and
   pure-Python package pins.

## Updating metadata

For each Google libphonenumber release:

1. Change the upstream version and archive hash in `CMakeLists.txt`, the fetch
   tool, and the sdist include list.
2. Check whether libphonenumber changed its Abseil pin. If so, update and verify
   the Abseil commit, archive hash, fetch entry, and sdist include.
3. Replace `_data/timezones.txt` with `resources/timezones/map_data.txt` from
   the same upstream tag.
4. Regenerate differential expectations and review every behavior change.
5. Increment the first three package version components to match upstream and
   reset the binding revision component to `1`.
6. Build all four wheels and repeat every release gate above.
