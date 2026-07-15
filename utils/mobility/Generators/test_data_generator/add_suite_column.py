#!/usr/bin/env python3
"""
Add a new suite column to wfm_sit_suites.csv

Usage:
    python3 add_suite_column.py <suite_name> <tc1> <tc2> <tc3> ...

    OR

    python3 add_suite_column.py <suite_name> --file <test_cases_file.txt>

Examples:
    # Add MORRISON suite with specific test cases
    python3 add_suite_column.py MORRISON TC34001 TC34002 TC34003

    # Add NEWCLIENT suite from a file containing test case IDs (one per line)
    python3 add_suite_column.py NEWCLIENT --file test_cases.txt
"""

import csv
import sys
import os


def add_suite_column(suite_name, test_cases, csv_file_path):
    """
    Add a new suite column to the CSV file and mark specified test cases as 'Yes'

    Args:
        suite_name: Name of the new suite column
        test_cases: Set of test case IDs to mark as 'Yes'
        csv_file_path: Path to the wfm_sit_suites.csv file
    """
    # Read the CSV file
    with open(csv_file_path, "r") as f:
        reader = csv.reader(f)
        rows = list(reader)

    # Check if suite already exists
    header = rows[0]
    if suite_name in header:
        print(f"⚠️  Warning: Suite '{suite_name}' already exists in the CSV file.")
        response = input("Do you want to overwrite it? (yes/no): ").strip().lower()
        if response != "yes":
            print("❌ Operation cancelled.")
            return False

        # Find the column index and remove it
        col_index = header.index(suite_name)
        for row in rows:
            del row[col_index]
        print(f"✅ Removed existing '{suite_name}' column")

    # Add new suite name to header
    header.append(suite_name)

    # Process each data row
    marked_count = 0
    for i in range(1, len(rows)):
        tag = rows[i][0]  # First column is TAG
        if tag in test_cases:
            rows[i].append("Yes")
            marked_count += 1
        else:
            rows[i].append("No")

    # Write back to CSV
    with open(csv_file_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerows(rows)

    # Print summary
    print(f"\n✅ Successfully added '{suite_name}' column to {csv_file_path}")
    print(f"✅ Marked {marked_count} test cases as 'Yes'")
    print(f"✅ Total rows processed: {len(rows) - 1}")
    print(f"✅ Test cases marked: {marked_count}/{len(test_cases)}")

    # Show any test cases that were not found
    found_tags = set(row[0] for row in rows[1:])
    not_found = test_cases - found_tags
    if not_found:
        print(f"\n⚠️  Warning: {len(not_found)} test case(s) not found in CSV:")
        for tc in sorted(not_found):
            print(f"   - {tc}")

    return True


def read_test_cases_from_file(file_path):
    """Read test cases from a text file (one per line)"""
    test_cases = set()
    with open(file_path, "r") as f:
        for line in f:
            line = line.strip()
            # Skip empty lines and comments
            if line and not line.startswith("#"):
                test_cases.add(line)
    return test_cases


def main():
    # Default CSV file path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    default_csv_path = os.path.join(script_dir, "TestMap", "wfm_sit_suites.csv")

    # Parse arguments
    if len(sys.argv) < 3:
        print(__doc__)
        print("❌ Error: Insufficient arguments")
        print("\nUsage:")
        print("  python3 add_suite_column.py <suite_name> <tc1> <tc2> <tc3> ...")
        print("  python3 add_suite_column.py <suite_name> --file <test_cases_file.txt>")
        sys.exit(1)

    suite_name = sys.argv[1].upper()

    # Check if reading from file
    if len(sys.argv) == 4 and sys.argv[2] == "--file":
        test_cases_file = sys.argv[3]
        if not os.path.exists(test_cases_file):
            print(f"❌ Error: File '{test_cases_file}' not found")
            sys.exit(1)

        print(f"📖 Reading test cases from: {test_cases_file}")
        test_cases = read_test_cases_from_file(test_cases_file)
        print(f"📋 Found {len(test_cases)} test cases in file")
    else:
        # Read test cases from command line arguments
        test_cases = set(sys.argv[2:])
        print(f"📋 Processing {len(test_cases)} test cases from command line")

    # Validate CSV file exists
    if not os.path.exists(default_csv_path):
        print(f"❌ Error: CSV file not found at: {default_csv_path}")
        sys.exit(1)

    # Show summary before processing
    print(f"\n{'=' * 60}")
    print(f"Suite Name: {suite_name}")
    print(f"CSV File:   {default_csv_path}")
    print(f"Test Cases: {len(test_cases)}")
    print(f"{'=' * 60}\n")

    # Add the suite column
    success = add_suite_column(suite_name, test_cases, default_csv_path)

    if success:
        print("\n✨ Done!")
    else:
        print("\n❌ Failed to add suite column")
        sys.exit(1)


if __name__ == "__main__":
    main()
