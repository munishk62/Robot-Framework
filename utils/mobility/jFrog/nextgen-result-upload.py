import os
import sys
import argparse
import datetime
from pathlib import Path
import requests

# Load env token
jfrog_token = os.getenv("JFROG_TOKEN")
if not jfrog_token:
    print("❌ JFROG_TOKEN not set in environment.")
    sys.exit(1)

ARTIFACTORY_BASE_URL = "https://artifactory-apac.zebra.com/artifactory"

# Determine RF_LOGS latest folder
project_root_path = Path(__file__).resolve().parent.parent.parent.parent
rf_logs_base = project_root_path / "RF_LOGS" / "ESS_Mobility"

if not rf_logs_base.exists():
    print(f"❌ Directory does not exist: {rf_logs_base}")
    sys.exit(1)

directories = [d for d in rf_logs_base.iterdir() if d.is_dir()]
if not directories:
    print(f"❌ No directories found in: {rf_logs_base}")
    sys.exit(1)
latest_folder = max(directories, key=lambda d: d.stat().st_mtime)
RESULT_DIR = latest_folder / "CI_ATS"

if not RESULT_DIR.exists():
    print(f"❌ Directory not found: {RESULT_DIR}")
    sys.exit(1)

# Parse CLI arguments
parser = argparse.ArgumentParser(description="Upload to Artifactory using REST API.")
parser.add_argument("--profile", required=True, help="Profile variation")
parser.add_argument("--platform", required=True, help="Platform variation")
args = parser.parse_args()

# Generate remote path with timestamp
timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
remote_path = f"ref-gen-dev/WFM-MOBILITY/automation/ESS/{args.profile}_{args.platform}/{timestamp}/"
profile = {args.profile}
platform = {args.platform}
print(f"📂 Uploading contents of: {RESULT_DIR}")
print(f"☁️  Target: {remote_path}")


# Upload all files recursively
def upload_file(file_path: Path):
    # Security: Validate file_path is within RESULT_DIR to prevent path traversal
    safe_file_path = file_path.resolve()
    safe_result_dir = RESULT_DIR.resolve()

    if not str(safe_file_path).startswith(str(safe_result_dir)):
        print(f"❌ Security: File path outside allowed directory: {file_path}")
        return False

    rel_path = file_path.relative_to(RESULT_DIR)
    url = f"{ARTIFACTORY_BASE_URL}/{remote_path}{rel_path.as_posix()}"
    headers = {"Authorization": f"Bearer {jfrog_token}"}

    # Security: Use the validated safe_file_path for file operations
    with open(safe_file_path, "rb") as f:
        response = requests.put(url, data=f, headers=headers)

    if response.status_code in (200, 201):
        print(f"✅ Uploaded: {rel_path}")
    else:
        print(
            f"❌ Failed to upload {rel_path}: {response.status_code} - {response.text}"
        )
        return False
    return True


all_success = True
for root, _, files in os.walk(RESULT_DIR):
    for file in files:
        individual_file_path = Path(root) / file
        if not upload_file(individual_file_path):
            all_success = False

if all_success:
    print("🎉 All files uploaded successfully.")
    print(f"📂 Remote path: {ARTIFACTORY_BASE_URL}/{remote_path}")
    print(
        f'##JFROG_RESULT## <a href="{ARTIFACTORY_BASE_URL}/{remote_path}" target="_blank">📄{profile}-{platform}</a>'
    )
else:
    print("⚠️ Some files failed to upload.")
    sys.exit(1)
