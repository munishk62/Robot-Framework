import argparse
import sys
import requests
import os
import subprocess

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../..")))
from utils.common_utility.utility import load_yaml
from pathlib import Path

parser = argparse.ArgumentParser(
    description="Run Robot Framework tests with dynamic parameters."
)
parser.add_argument(
    "--app",
    default="workcloudshift_android",
    choices=[
        "workcloudshift_android",
        "native_clock_android",
        "native_clock_ios",
        "workcloudshift_ios",
    ],
    help="App to download android app from jfrog (e.g., 'workcloudshift_android' 'native_clock_andorid','native_clock_ios','workcloudshift_ios')",
)
args = parser.parse_args()
app = args.app
jfrog_build_detail = load_yaml("utils/mobility/jFrog/build_details.yaml")
build_detail = jfrog_build_detail[app]
jfrog_detail = jfrog_build_detail["jfrog_detail"]

# Artifactory details
JFROG_URL = jfrog_detail["JFROG_URL"]
REPO_NAME = jfrog_detail["REPO_NAME"]
BASE_PATH = build_detail["BASE_PATH"]
ACCESS_TOKEN = os.getenv("JFROG_TOKEN")  # Retrieve token from environment variable

# Define target download directory
project_root_path = Path(__file__).resolve().parent.parent.parent.parent
DOWNLOAD_DIR = (
    project_root_path / "ExternalFiles" / "APK" / build_detail["DOWNLOAD_DIR_PATH"]
)
DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)
# API endpoint to list files in the Android directory
artifact_list_url = f"{JFROG_URL}/artifactory/api/storage/{REPO_NAME}/{BASE_PATH}"
# Set up headers
headers = {"Authorization": f"Bearer {ACCESS_TOKEN}", "Accept": "application/json"}


def install_apk_on_device(apk_path):
    """
    Installs the given APK on a connected Android device using adb.
    Prints status messages based on success or failure.
    """
    try:
        result = subprocess.run(
            ["adb", "devices"], capture_output=True, text=True, check=True
        )
        lines = result.stdout.strip().splitlines()
        devices = [line for line in lines[1:] if line.strip() and "device" in line]
        if not devices:
            print("No Android device connected. Please connect a device and try again.")
            return False
    except Exception as e:
        print(f"Error checking devices: {e}")
        return False

    # Install the APK
    try:
        # Security: Validate apk_path is an absolute path and exists
        safe_apk_path = Path(apk_path).resolve()
        if not safe_apk_path.exists():
            print(f"APK file does not exist: {safe_apk_path}")
            return False

        # Security: Validate the file is actually an APK file
        if not safe_apk_path.suffix.lower() == ".apk":
            print(f"File is not an APK: {safe_apk_path}")
            return False

        # Use list arguments to prevent command injection
        install_result = subprocess.run(
            ["adb", "install", "-r", str(safe_apk_path)],
            capture_output=True,
            text=True,
            shell=False,  # Explicitly disable shell to prevent injection
        )
        if install_result.returncode == 0 and "Success" in install_result.stdout:
            print("APK installed successfully.")
            return True
        else:
            print(
                f"Failed to install APK. adb output:\n{install_result.stdout}\n{install_result.stderr}"
            )
            return False
    except Exception as e:
        print(f"Error during APK installation: {e}")
        return False


# Get the list of available builds
response = requests.get(artifact_list_url, headers=headers)

if response.status_code == 200:
    data = response.json()

    # Extract timestamps from folder names
    timestamps = [
        item["uri"].strip("/")
        for item in data.get("children", [])
        if item["uri"].strip("/").isdigit()
    ]

    if not timestamps:
        print("No builds found.")
        exit(1)

    # Sort timestamps in descending order to get the latest one
    latest_timestamp = sorted(timestamps, reverse=True)[0]

    # Construct the latest APK URL
    latest_apk_url = f"{JFROG_URL}/artifactory/{REPO_NAME}/{BASE_PATH}{latest_timestamp}/{build_detail['APP_NAME']}"
    print(f"Latest APK URL: {latest_apk_url}")

    print("Downloading APP...")
    response = requests.get(latest_apk_url, headers=headers, stream=True)

    if response.status_code == 200:
        # Security: Validate output_file is within DOWNLOAD_DIR to prevent path traversal
        output_file = (DOWNLOAD_DIR / build_detail["APP_NAME"]).resolve()
        safe_download_dir = DOWNLOAD_DIR.resolve()

        if not str(output_file).startswith(str(safe_download_dir)):
            print(f"Security: File path outside allowed directory: {output_file}")
            exit(1)

        with open(output_file, "wb") as file:
            for chunk in response.iter_content(chunk_size=1024 * 1024):  # 1MB chunks
                if chunk:
                    file.write(chunk)

        print(f"Download complete: {output_file}")
        # Install the APK on the connected device
        install_apk_on_device(output_file)
    else:
        print(f"Failed to download latest APK. HTTP Status: {response.status_code}")
else:
    print(f"Failed to fetch build list. HTTP Status: {response.status_code}")
