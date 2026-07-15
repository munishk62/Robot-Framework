import csv
import os
import sys
from pathlib import Path

import pandas as pd

output_dir = "Generated"
output_file = os.path.join(output_dir, "Globals.py")


BASE_DIRECTORY = Path(__file__).resolve().parent.parent.parent.__str__()

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)


def get_client_testdata(client_name, file_path):
    df = pd.read_csv(file_path, index_col=0)
    if client_name in df.columns:
        client_data = df[client_name].to_dict()
        client_data = {**client_data}
        for key, value in client_data.items():
            # print(f"Setting variable '{key}' with value '{value}' for client '{client_name}'")
            if str(value) == "nan":
                client_data[key] = None
        return client_data
    else:
        print(f"Client '{client_name}' not found in the test data file '{file_path}'")


# Read the CSV and generate Globals.py
def generate_globals(input_csv, environment=None, client_name=None):
    print(
        f"Generating Globals.py from {input_csv}\nBASE_DIRECTORY: {BASE_DIRECTORY}\noutput_file: {output_file}"
    )
    csv_path = os.path.abspath(os.path.join(BASE_DIRECTORY, input_csv))
    csv_config_csv_path = os.path.abspath(
        os.path.join(
            BASE_DIRECTORY, "TestData", "Web", "{}_test_data.csv".format(environment)
        )
    )
    IS_CSV_FILE = os.path.exists(csv_path)
    IS_CONFIG_CSV_FILE = os.path.exists(csv_config_csv_path)
    if csv_path.startswith(BASE_DIRECTORY):
        if IS_CSV_FILE:
            with open(csv_path, mode="r", newline="", encoding="utf-8") as csvfile:
                reader = csv.DictReader(csvfile)
                with open(output_file, mode="w", encoding="utf-8") as pyfile:
                    pyfile.write(
                        "# Globals.py - Auto-generated file DO NOT MODIFY THIS FILE\n\n"
                    )
                    for row in reader:
                        # Only process rows with SCOPE == "GLOBAL"
                        if row["SCOPE"] == "GLOBAL":
                            key = row["KEY"].strip()
                            value = row["VALUE"].strip()
                            if key and value:
                                # Write the variable in Python syntax
                                pyfile.write(f'{key} = "{value}"\n')
        else:
            print(f"CSV file not found: {csv_path}")
            sys.exit(
                f"Stopping execution: The specified CSV file was not found at {csv_path}. Please check your --profile argument and ensure the file exists."
            )
        if IS_CONFIG_CSV_FILE:
            value = get_client_testdata(client_name, csv_config_csv_path)
            if value is not None:
                with open(output_file, mode="a", encoding="utf-8") as pyfile:
                    pyfile.write("# CLIENT_DATA FROM CST CSV\n")
                    for key, value in value.items():
                        key = str(key).strip().upper()
                        pyfile.write(f'{key} = "{value}"\n')

                # print(value)
                # Read the output_file and check for duplicate keys and values and print both the line numbers
                # Read the output_file and check for duplicate keys and values and print both the line numbers
                with open(output_file, mode="r", encoding="utf-8") as pyfile:
                    lines = pyfile.readlines()
                    keys = {}  # Dict to store key:line_number
                    values = {}  # Dict to store value:line_number
                    file_content = []
                    for line_number, line in enumerate(lines, 1):
                        if "=" in line and not line.strip().startswith("#"):
                            key = line.split("=")[0].strip()
                            if key in keys:
                                print(
                                    f"Duplicate key found: '{key}' at lines {keys[key]} and {line_number}"
                                )
                                print("\t" + lines[keys[key] - 1].strip())
                                print("\t" + lines[line_number - 1].strip())
                            keys[key] = line_number
                    # allowed_duplicate_value = ['"false"', '"none"']
                    # for line_number, line in enumerate(lines, 1):
                    #     if "=" in line and not line.strip().startswith("#"):
                    #         value = line.split("=")[1].strip()
                    #         if value in values and value.lower() not in allowed_duplicate_value:
                    #             print(f"Duplicate value found: '{value}' at lines {values[value]} and {line_number}")
                    #             print("\t"+lines[values[value] - 1].strip())
                    #             print("\t"+lines[line_number - 1].strip())
                    #         values[value] = line_number

        else:
            print(f"CSV file not found: {csv_config_csv_path}")
            sys.exit(1)
        print(f"Globals.py file has been generated at: {output_file}")
