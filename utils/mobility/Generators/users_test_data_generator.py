import csv
import re
from datetime import datetime, timedelta
import os
from pathlib import Path

from Generated.Globals import PLANNING_WEEK_START, FISCAL_WEEK_START

output_dir = "Generated"
testdata_file = os.path.join(output_dir, "HNM_Dynamic_TestData.py")
hnm_users_file = os.path.join(output_dir, "HNM_Users.csv")
qa_users_file = os.path.join(output_dir, "QA_Users.csv")

BASE_DIRECTORY = Path(__file__).resolve().parent.parent.parent.__str__()
# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)


def get_run_import_tests_value(csv_file_path):
    run_import_tests_value = "FALSE"  # Default value if not found
    csv_file_path = os.path.abspath(os.path.join(BASE_DIRECTORY, csv_file_path))
    if csv_file_path.startswith(BASE_DIRECTORY):
        with open(csv_file_path, mode="r", newline="", encoding="utf-8") as file:
            reader = csv.DictReader(file)
            for row in reader:
                if "RUN_IMPORT_TESTS" in row:
                    run_import_tests_value = row["RUN_IMPORT_TESTS"]
                    break
    else:
        print(f"File path {csv_file_path} does not start with {BASE_DIRECTORY}")
    return run_import_tests_value


# Function to read file paths from HNM_TestData.csv
def get_file_paths_from_csv(csv_path):
    file_paths = {}
    csv_path = os.path.abspath(os.path.join(BASE_DIRECTORY, csv_path))
    if csv_path.startswith(BASE_DIRECTORY):
        with open(csv_path, mode="r", newline="", encoding="utf-8") as file:
            reader = csv.DictReader(file)
            for row in reader:
                if row["KEY"] in [
                    "HRBA_CSV_FILE_PATH",
                    "USERS_CSV_FILE_PATH",
                    "DYNAMIC_TESTDATA_CSV_FILE_PATH",
                ]:
                    file_paths[row["KEY"]] = row["VALUE"]
    else:
        print(f"File path {csv_path} does not start with {BASE_DIRECTORY}")
    return file_paths


def import_hrba(client_data_csv_file_path, Cli_env):
    global current_week_start
    import_hrba_data__flag = False
    client_data_csv_file_path = os.path.abspath(
        os.path.join(BASE_DIRECTORY, client_data_csv_file_path)
    )
    if client_data_csv_file_path.startswith(BASE_DIRECTORY):
        with open(
            client_data_csv_file_path, mode="r", newline="", encoding="utf-8"
        ) as file:
            reader = csv.DictReader(file)
            for row in reader:
                if row["KEY"] == "RUN_IMPORT_TESTS":
                    import_hrba_data__flag = row["VALUE"].strip().upper() == "TRUE"
                    print(import_hrba_data__flag)
                    break

        if import_hrba_data__flag:
            file_paths = get_file_paths_from_csv(client_data_csv_file_path)
            HRBA_csv_file_path = file_paths["HRBA_CSV_FILE_PATH"]
            Users_csv_path = file_paths["USERS_CSV_FILE_PATH"]
            Dynamic_TestData_csv_path = file_paths["DYNAMIC_TESTDATA_CSV_FILE_PATH"]
            # Step 1: Read the CSV file and update the employee IDs, first name, last name, 51st column, and store ID
            updated_rows = []
            employee_ids = []
            full_names = []
            Store_Id = None
            current_datetime = datetime.now().strftime("%Y%m%d%H%M%S")
            HRBA_csv_file_path = os.path.abspath(
                os.path.join(BASE_DIRECTORY, HRBA_csv_file_path)
            )
            if HRBA_csv_file_path.startswith(BASE_DIRECTORY):
                with open(
                    HRBA_csv_file_path, mode="r", newline="", encoding="utf-8"
                ) as file:
                    reader = csv.reader(file)
                    header = next(reader)
                    updated_rows.append(header)
                    for row in reader:
                        if row[0] == "HRBA":
                            employee_number = row[2][0]
                            year = current_datetime[:4]
                            month = current_datetime[4:6]
                            day = current_datetime[6:8]
                            new_employee_id = f"{employee_number}{year}{month}{day}"
                            row[2] = new_employee_id
                            if Cli_env == "HNM":
                                row[5] = f"LN_HNM {new_employee_id}"
                                row[6] = f"FN {new_employee_id}"
                            elif "VARIATION4" in Cli_env:
                                row[5] = f"EMP{new_employee_id}"
                                row[6] = f"Employee0{employee_number}"
                            else:
                                row[5] = f"{new_employee_id}"
                                row[6] = f"Associate0{employee_number}"

                            row[50] = new_employee_id
                            full_name = f"{row[5]}, {row[6]}"
                            full_names.append(full_name)
                            employee_ids.append(new_employee_id)
                            Store_Id = row[23]
                        updated_rows.append(row)

                with open(
                    HRBA_csv_file_path, mode="w", newline="", encoding="utf-8"
                ) as file:
                    writer = csv.writer(file)
                    writer.writerows(updated_rows)

            # Reusable function to update or create a variable in the HNM_Users.csv file
            def update_or_create_variable_in_csv(
                csv_path, key, user_id, full_name, first_name, last_name
            ):
                rows = []
                fieldnames = []
                csv_path = os.path.abspath(os.path.join(BASE_DIRECTORY, csv_path))
                if csv_path.startswith(BASE_DIRECTORY):
                    with open(csv_path, mode="r", newline="", encoding="utf-8") as file:
                        reader = csv.DictReader(file)
                        rows = list(reader)
                        fieldnames = reader.fieldnames

                    key_exists = False
                    for row in rows:
                        if row["KEY"] == key:
                            row["USER_ID"] = user_id
                            if Cli_env == "HNM":
                                row["PASSWORD"] = user_id + "Zebra@123"
                            else:
                                row["PASSWORD"] = user_id + "@123"
                            row["USER_FULLNAME"] = full_name
                            row["FIRST_NAME"] = first_name
                            row["LAST_NAME"] = last_name
                            key_exists = True
                            break
                    if not key_exists:
                        new_row = {
                            "KEY": key,
                            "USER_ID": user_id,
                            "USER_FULLNAME": full_name,
                            "FIRST_NAME": first_name,
                            "LAST_NAME": last_name,
                        }
                        rows.append(new_row)

                    with open(csv_path, mode="w", newline="", encoding="utf-8") as file:
                        writer = csv.DictWriter(file, fieldnames=fieldnames)
                        writer.writeheader()
                        writer.writerows(rows)

                    print(f"{key} updated or created successfully in {csv_path}.")

            # Step 2: Update the HNM_Users.csv file with the new IDs
            if Cli_env == "HNM":
                update_or_create_variable_in_csv(
                    Users_csv_path,
                    "ESS-USER1",
                    employee_ids[0],
                    full_names[0],
                    f"LN_HNM {employee_ids[0]}",
                    f"FN {employee_ids[0]}",
                )
                update_or_create_variable_in_csv(
                    Users_csv_path,
                    "ESS-USER2",
                    employee_ids[1],
                    full_names[1],
                    f"LN_HNM {employee_ids[1]}",
                    f"FN {employee_ids[1]}",
                )

                print("HNM_Users.csv file updated successfully.")
            elif "VARIATION4" in Cli_env:
                update_or_create_variable_in_csv(
                    Users_csv_path,
                    "ESS-USER1",
                    employee_ids[0],
                    full_names[0],
                    "Employee01",
                    f"EMP{employee_ids[0]}",
                )
                update_or_create_variable_in_csv(
                    Users_csv_path,
                    "ESS-USER2",
                    employee_ids[1],
                    full_names[1],
                    "Employee02",
                    f"EMP{employee_ids[1]}",
                )

                print("Users.csv file updated successfully.")
            else:
                update_or_create_variable_in_csv(
                    Users_csv_path,
                    "ESS-USER1",
                    employee_ids[0],
                    full_names[0],
                    "Associate01",
                    employee_ids[0],
                )
                update_or_create_variable_in_csv(
                    Users_csv_path,
                    "ESS-USER2",
                    employee_ids[1],
                    full_names[1],
                    "Associate02",
                    employee_ids[1],
                )

                print("Users.csv file updated successfully.")

            # Step 5: Update the HNM_Dynamic_TestData.py with Store id from HRBA file
            def update_store_id_in_hnm(file_path, new_Store_Id):
                file_path = os.path.abspath(os.path.join(BASE_DIRECTORY, file_path))
                if file_path.startswith(BASE_DIRECTORY):
                    with open(file_path, "r") as file:
                        content = file.read()
                    print(content)
                    updated_content = re.sub(
                        r'ID_Store\s*=\s*".*?"', f'ID_Store = "{new_Store_Id}"', content
                    )
                    print(updated_content)
                    with open(file_path, "w") as file:
                        file.write(updated_content)

            update_store_id_in_hnm(Dynamic_TestData_csv_path, Store_Id)
            print(
                f"Updated ID_Store with respect to HRBA File to {Store_Id} in {Dynamic_TestData_csv_path}"
            )

            # Step 3: Generate dynamic work pattern name and update HNM.py
            def generate_dynamic_work_pattern_name(prefix="SANWP"):
                current_date_time = datetime.now().strftime("%Y%m%d%H%M")
                work_pattern_name = f"{prefix}{current_date_time}"
                return work_pattern_name

            def update_work_pattern_name_in_hnm(file_path, new_work_pattern_name):
                file_path = os.path.abspath(os.path.join(BASE_DIRECTORY, file_path))
                if file_path.startswith(BASE_DIRECTORY):
                    with open(file_path, "r") as file:
                        content = file.read()
                    updated_content = re.sub(
                        r'Final_workpattern\s*=\s*".*?"',
                        f'Final_workpattern = "{new_work_pattern_name}"',
                        content,
                    )
                    with open(file_path, "w") as file:
                        file.write(updated_content)

            new_work_pattern_name = generate_dynamic_work_pattern_name()
            update_work_pattern_name_in_hnm(
                Dynamic_TestData_csv_path, new_work_pattern_name
            )
            print(
                f"Updated Final_workpattern to {new_work_pattern_name} in {Dynamic_TestData_csv_path}"
            )

            # Step 4: Generate dynamic DLLISTNAME and update HNM.py
            def generate_dynamic_dl_list_name(prefix="DLLIST"):
                current_date_time = datetime.now().strftime("%Y%m%d%H%M")
                dl_list_name = f"{prefix}{current_date_time}"
                return dl_list_name

            def update_dl_list_name_in_hnm(file_path, new_dllistname):
                file_path = os.path.abspath(os.path.join(BASE_DIRECTORY, file_path))
                if file_path.startswith(BASE_DIRECTORY):
                    with open(file_path, "r") as file:
                        content = file.read()
                    updated_content = re.sub(
                        r'Final_DL_Name\s*=\s*".*?"',
                        f'Final_DL_Name = "{new_dllistname}"',
                        content,
                    )
                    with open(file_path, "w") as file:
                        file.write(updated_content)

            new_dl_list_name = generate_dynamic_dl_list_name()
            update_dl_list_name_in_hnm(Dynamic_TestData_csv_path, new_dl_list_name)
            print(
                f"Updated Final_DL_Name to {new_dl_list_name} in {Dynamic_TestData_csv_path}"
            )

            # VDI Operations
            def get_values_from_csv(csv_path):
                values = {}
                csv_path = os.path.abspath(os.path.join(BASE_DIRECTORY, csv_path))
                if csv_path.startswith(BASE_DIRECTORY):
                    with open(csv_path, mode="r", newline="", encoding="utf-8") as file:
                        reader = csv.DictReader(file)
                        for row in reader:
                            if Cli_env != "HNM":
                                # VDP is required
                                if row["KEY"] in [
                                    "PLANNING_WEEK_START",
                                    "VDI_CSV_FILE_PATH",
                                    "VDP_CSV_FILE_PATH",
                                ]:
                                    values[row["KEY"]] = row["VALUE"]
                            else:
                                # VDP is not required
                                if row["KEY"] in [
                                    "PLANNING_WEEK_START",
                                    "VDI_CSV_FILE_PATH",
                                ]:
                                    values[row["KEY"]] = row["VALUE"]

                return values

            def get_start_date(planning_week_start):
                return datetime.strptime(planning_week_start, "%Y%m%d")

            def generate_dates(start_date):
                dates = []
                current_date = start_date
                while len(dates) < 12:
                    if (
                        Cli_env in ["HNM", "HNMDRYRUN"] and current_date.weekday() == 2
                    ):  # Skip Wednesdays if HNM or HNMDRYRUN
                        current_date += timedelta(days=1)
                        continue
                    dates.append(current_date.strftime("%Y%m%d"))
                    current_date += timedelta(days=1)
                return dates

            def update_csv(
                dates,
                csv_file_path,
            ):
                if not os.path.exists(csv_file_path):
                    raise FileNotFoundError(
                        f"No such file or directory: '{csv_file_path}'"
                    )
                csv_file_path = os.path.abspath(
                    os.path.join(BASE_DIRECTORY, csv_file_path)
                )
                if csv_file_path.startswith(BASE_DIRECTORY):
                    with open(csv_file_path, "r") as file:
                        reader = csv.reader(file)
                        rows = list(reader)

                    date_index = 0
                    print("<<<" + Cli_env)  # Ensure Cli_env is a string
                    if Cli_env == "HNM":
                        for i in range(1, 85):  # Start from row 2 (index 1) to row 85
                            if (i - 1) % 7 == 0 and i != 1:
                                date_index += 1
                            if date_index < len(dates):
                                rows[i][5] = dates[date_index]
                    else:
                        for i in range(
                            1, len(rows)
                        ):  # Start from row 2 (index 1) to the end of the file
                            if (
                                rows[i][0] in ["VDI", "VDP"]
                            ):  # Ensure the row starts with 'VDI':  # Ensure the row starts with 'VDI'
                                if date_index < len(dates):
                                    rows[i][5] = dates[date_index]
                                    date_index += 1

                    with open(csv_file_path, "w", newline="", encoding="utf-8") as file:
                        writer = csv.writer(file)
                        writer.writerows(rows)

            # Path to the CSV file containing the required values
            csv_path = client_data_csv_file_path
            values = get_values_from_csv(csv_path)

            planning_week_start = values["PLANNING_WEEK_START"]
            current_date = datetime.now()

            # Define the start day of the week (0 = Monday, 1 = Tuesday, ..., 6 = Sunday)

            days_since = current_date.weekday() - (int(str(FISCAL_WEEK_START)) - 2)
            current_week_start = current_date - timedelta(days=days_since)

            # Subtract 7 days to get the previous week's start date
            if Cli_env not in ["HNM", "HNMDRYRUN"]:
                planning_week_start = (current_week_start - timedelta(days=7)).strftime(
                    "%Y%m%d"
                )
                print(f"Current week start date - 7 days: {planning_week_start}")
            else:
                planning_week_start = PLANNING_WEEK_START

            print(f"planning week: {planning_week_start}")

            print(f"Current week start date - 7 days: {planning_week_start}")
            if "VDI_CSV_FILE_PATH" in values:
                vdi_csv_file_path = values["VDI_CSV_FILE_PATH"]
            else:
                raise KeyError("VDI_CSV_FILE_PATH is missing in the values dictionary")

            if Cli_env != "HNM":
                if "VDP_CSV_FILE_PATH" in values:
                    vdp_csv_file_path = values["VDP_CSV_FILE_PATH"]
                else:
                    raise KeyError(
                        "VDP_CSV_FILE_PATH is missing in the values dictionary"
                    )

            start_date = get_start_date(planning_week_start)
            dates = generate_dates(start_date)
            update_csv(dates, vdi_csv_file_path)
            if Cli_env != "HNM":
                update_csv(dates, vdp_csv_file_path)
                print(
                    f"VDI And VDP CSV file updated successfully with dates starting from {planning_week_start}."
                )
            else:
                print(
                    f"VDI CSV file updated successfully with dates starting from {planning_week_start}."
                )
        else:
            return
    else:
        print(
            f"File path {client_data_csv_file_path} does not start with {BASE_DIRECTORY}"
        )
        return


# Function to generate HNM_Dynamic_TestData.py if it does not exist
def generate_testdata_file(file_path):
    csv_path = os.path.abspath(os.path.join(BASE_DIRECTORY, file_path))
    if csv_path.startswith(BASE_DIRECTORY):
        with open(csv_path, "w") as file:
            file.write('Final_workpattern = ""\n')
            file.write('Final_DL_Name = ""\n')
            file.write('ID_Store = ""\n')
        print(f"{csv_path} created.")
    else:
        print(f"{csv_path} already exists.")


# Function to generate HNM_Users.csv with only the template first row and first column
def generate_users_file(file_path):
    csv_path = os.path.abspath(os.path.join(BASE_DIRECTORY, file_path))
    # if csv_path.startswith(BASE_DIRECTORY):
    if not os.path.exists(csv_path):
        with open(csv_path, "w", newline="", encoding="utf-8") as file:
            writer = csv.writer(file)
            writer.writerow(
                [
                    "KEY",
                    "USER_ID",
                    "PASSWORD",
                    "USER_FULLNAME",
                    "FIRST_NAME",
                    "LAST_NAME",
                ]
            )
            writer.writerow(["ESS-USER1"])
            writer.writerow(["ESS-USER2"])
        print(f"{csv_path} created.")
    else:
        print(f"{csv_path} already exists.")
