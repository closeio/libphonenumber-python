import hashlib
import pathlib
import time
import urllib.request

ROOT = pathlib.Path(__file__).parents[1]
SOURCES = (
    (
        "libphonenumber",
        (
            "https://codeload.github.com/google/libphonenumber/tar.gz/"
            "refs/tags/v9.0.34"
        ),
        "5d2a61572110f0538fdb1afbc1f8381426fbfbbf544b45e8ae905297f2f5befa",
        ROOT / "vendor" / "libphonenumber-9.0.34.tar.gz",
    ),
    (
        "Abseil",
        (
            "https://codeload.github.com/abseil/abseil-cpp/tar.gz/"
            "273292d1cfc0a94a65082ee350509af1d113344d"
        ),
        "94aef187f688665dc299d09286bfa0d22c4ecb86a80b156dff6aabadc5a5c26d",
        ROOT / "vendor" / "abseil-cpp-273292d.tar.gz",
    ),
)


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        while chunk := source.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def fetch(
    name: str, url: str, expected_hash: str, destination: pathlib.Path
) -> None:
    if destination.exists() and sha256(destination) == expected_hash:
        return

    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = destination.with_suffix(".tmp")
    for attempt in range(1, 6):
        try:
            urllib.request.urlretrieve(url, temporary)
            actual_hash = sha256(temporary)
            if actual_hash != expected_hash:
                raise RuntimeError(
                    f"Unexpected {name} archive hash: {actual_hash}"
                )
            temporary.replace(destination)
            return
        except (OSError, RuntimeError):
            temporary.unlink(missing_ok=True)
            if attempt == 5:
                raise
            time.sleep(attempt * 2)


def main() -> None:
    for source in SOURCES:
        fetch(*source)


if __name__ == "__main__":
    main()
