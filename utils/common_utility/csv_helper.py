import os
import csv
from dotenv import load_dotenv
from robot.libraries.BuiltIn import BuiltIn

load_dotenv()

base_directory = os.path.abspath("")

context = BuiltIn()


def get_users(users_file: str):
    normalised_path = os.path.normpath(os.path.join(base_directory, users_file))
    sanitised_file = os.path.abspath(normalised_path)
    users_list = []
    print(base_directory)
    print(sanitised_file)

    if not sanitised_file.startswith(base_directory):
        raise ValueError(
            f"The file path '{sanitised_file}' is outside the allowed base directory '{base_directory}'."
        )

    if not sanitised_file.lower().endswith(".csv"):
        raise ValueError(
            f"The file path '{sanitised_file}' must have a '.csv' extension."
        )

    if not os.path.exists(sanitised_file):
        raise ValueError(f"The file '{sanitised_file}' does not exist.")

    with open(sanitised_file, mode="r") as file:
        csvFile = csv.DictReader(file)

        for lines in csvFile:
            users_list.append(lines)
    context.set_variable("${user_context}", users_list)
    return users_list  # Return None if no match is found


def csv_has_column(csv_file: str, column_name: str, encoding: str = "utf-8") -> bool:
    """Return True if the given CSV file contains ``column_name`` in its header row.

    | =Arguments=  | =Description= |
    | csv_file     | Path (relative to repo root or absolute) of the CSV file. |
    | column_name  | Header / column name to look for. |
    | encoding     | File encoding (defaults to utf-8, BOM tolerated via utf-8-sig). |

    *Returns*: ``True`` if the column exists, otherwise ``False``. Returns
    ``False`` if the file does not exist or cannot be read.

    Example usage:
    | ${exists}=    Csv Has Column    path/to/file.csv    en_US
    """
    normalised_path = os.path.normpath(os.path.join(base_directory, csv_file))
    sanitised_file = os.path.abspath(normalised_path)

    if not os.path.exists(sanitised_file):
        return False

    # Use utf-8-sig to transparently strip BOM if present.
    read_encoding = "utf-8-sig" if encoding.lower().replace("-", "") in ("utf8", "utf8sig") else encoding
    try:
        with open(sanitised_file, mode="r", encoding=read_encoding, newline="") as file:
            reader = csv.reader(file)
            headers = next(reader, [])
    except (OSError, UnicodeDecodeError):
        return False
    return column_name in [h.strip() for h in headers]


def read_csv_as_translation_map(
    csv_file: str, key_column: str, value_column: str, encoding: str = "utf-8"
) -> dict:
    """Read a CSV file and return a ``{key_column: value_column}`` mapping.

    Equivalent to ``Read Csv As Dictionary`` from ``robotframework-csvlib`` but
    tolerates a UTF-8 BOM in the header (uses ``utf-8-sig`` automatically when
    ``utf-8``/``utf8`` is requested) so that the key column lookup does not
    fail with ``KeyError`` on BOM-prefixed files.

    | =Arguments=    | =Description= |
    | csv_file       | Path (relative to repo root or absolute) of the CSV file. |
    | key_column     | Column name to use as dictionary keys (e.g. ``KEY``). |
    | value_column   | Column name to use as dictionary values (e.g. ``en_US``). |
    | encoding       | File encoding (defaults to utf-8; BOM transparently stripped). |

    *Returns*: A ``dict`` mapping each row's ``key_column`` value to its ``value_column`` value.

    Example usage:
    | &{map}=    Read Csv As Translation Map    path/to/file.csv    KEY    en_US
    """
    normalised_path = os.path.normpath(os.path.join(base_directory, csv_file))
    sanitised_file = os.path.abspath(normalised_path)

    if not os.path.exists(sanitised_file):
        raise ValueError(f"The file '{sanitised_file}' does not exist.")

    read_encoding = (
        "utf-8-sig"
        if encoding.lower().replace("-", "") in ("utf8", "utf8sig")
        else encoding
    )

    result: dict = {}
    with open(sanitised_file, mode="r", encoding=read_encoding, newline="") as file:
        reader = csv.DictReader(file)
        # Strip any whitespace/BOM remnants from header names defensively.
        if reader.fieldnames:
            reader.fieldnames = [h.strip().lstrip("\ufeff") for h in reader.fieldnames]
        if key_column not in (reader.fieldnames or []):
            raise KeyError(
                f"Key column '{key_column}' not found in CSV '{sanitised_file}'. "
                f"Available columns: {reader.fieldnames}"
            )
        if value_column not in (reader.fieldnames or []):
            raise KeyError(
                f"Value column '{value_column}' not found in CSV '{sanitised_file}'. "
                f"Available columns: {reader.fieldnames}"
            )
        for row in reader:
            key = row.get(key_column)
            if key is None or key == "":
                continue
            result[key] = row.get(value_column, "")
    return result
