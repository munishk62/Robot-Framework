import os
import json
import logging
from dotenv import load_dotenv
from pathlib import Path
from typing import Optional

# Import the logger utility
from utils.logger import get_logger
from utils.environment_scoped_manager import EnvironmentScopedManager

# Get logger for this module
logger = get_logger(__name__)


def _resolve_environment_file() -> Optional[Path]:
    """
    Resolve the preferred environment file path.

    Resolution order:
    1. Explicit `WFM_ENV_FILE` from process env
    2. Scoped env file for `TEST_ENVIRONMENT`
    3. Legacy `.env` fallback
    """
    explicit_env_file = os.environ.get("WFM_ENV_FILE", "").strip()
    if explicit_env_file:
        explicit_path = Path(explicit_env_file)
        if explicit_path.exists():
            return explicit_path

    test_environment = os.environ.get("TEST_ENVIRONMENT", "").strip()
    if test_environment:
        scoped_path = EnvironmentScopedManager(
            test_env=test_environment
        ).get_scoped_env_filepath()
        if scoped_path.exists():
            return scoped_path

    legacy_env_file = Path(__file__).parent.parent / ".env"
    if legacy_env_file.exists():
        return legacy_env_file

    return None


def load_env_with_multiline_json() -> None:
    """
    Custom loader for environment files that handles multi-line JSON values.
    This function specifically handles the USER_CREDENTIALS variable which may contain
    multi-line JSON, while preserving other environment variables.
    """
    if os.environ.get("USER_CREDENTIALS"):
        logger.debug(
            "USER_CREDENTIALS already present in process environment; skipping file load"
        )
        return

    env_file = _resolve_environment_file()

    if not env_file:
        logger.warning("No environment file found (.env_scoped or .env fallback)")
        return

    # Temporarily suppress dotenv's logger warnings for multi-line values (we handle them manually below)
    dotenv_logger = logging.getLogger("dotenv.main")
    original_level = dotenv_logger.level
    dotenv_logger.setLevel(logging.ERROR)

    try:
        # First load normally to get other variables
        load_dotenv(env_file)
    finally:
        # Restore original logging level
        dotenv_logger.setLevel(original_level)

    # Now handle multi-line JSON specifically for USER_CREDENTIALS
    try:
        with open(env_file, "r", encoding="utf-8") as f:
            content = f.read()

        # Find USER_CREDENTIALS assignment
        lines = content.split("\n")
        json_lines = []
        collecting_json = False
        json_start_found = False
        brace_count = 0

        for line in lines:
            line = line.strip()

            # Skip comments and empty lines
            if not line or line.startswith("#"):
                continue

            # Check if this line starts USER_CREDENTIALS assignment
            if line.startswith("USER_CREDENTIALS="):
                collecting_json = True
                # Extract the part after the = sign
                json_part = line.split("=", 1)[1].strip()

                # Remove quotes if present
                if json_part.startswith('"') and json_part.endswith('"'):
                    json_part = json_part[1:-1]
                elif json_part.startswith("'") and json_part.endswith("'"):
                    json_part = json_part[1:-1]

                json_lines.append(json_part)

                # Count braces to determine if JSON is complete
                brace_count += json_part.count("{") - json_part.count("}")

                if brace_count == 0 and "{" in json_part:
                    # Complete JSON on single line
                    break

                json_start_found = True
                continue

            # If we're collecting JSON and this looks like a continuation
            if collecting_json and json_start_found:
                # This might be a continuation of the JSON value
                json_lines.append(line)
                brace_count += line.count("{") - line.count("}")

                # If braces are balanced, we're done
                if brace_count == 0:
                    break

        # If we collected JSON lines, parse and set the environment variable
        if json_lines:
            json_str = "".join(json_lines)

            # Try to parse the JSON to validate it
            try:
                json.loads(json_str)
                os.environ["USER_CREDENTIALS"] = json_str
                logger.info(
                    "Successfully loaded multi-line USER_CREDENTIALS from %s",
                    env_file,
                )
                logger.info(
                    "Loading user credentials from environment variable USER_CREDENTIALS"
                )
            except json.JSONDecodeError as e:
                logger.error(f"Invalid JSON in USER_CREDENTIALS: {e}")
                logger.debug(f"JSON content was: {json_str}")

    except Exception as e:
        logger.error(f"Error reading environment file {env_file}: {e}")
        # Fall back to normal dotenv loading
        load_dotenv(env_file)


# Load environment variables with multi-line JSON support
load_env_with_multiline_json()


def get_credentials() -> dict:
    creds_json = os.getenv("USER_CREDENTIALS")
    if not creds_json:
        logger.error(
            "USER_CREDENTIALS environment variable is not set. Please ensure it contains valid JSON data for users."
        )
        raise ValueError(
            "USER_CREDENTIALS environment variable is not set. Please ensure it contains valid JSON data for users."
        )
    """
    Sample JSON structure expected in USER_CREDENTIALS:
    {
        "user1": {
            "username": "user1",
            "password": "password1"
        },
        "user2": {
            "username": "user2",
            "password": "password2"
        }
    }
    """
    try:
        return json.loads(creds_json)
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse USER_CREDENTIALS JSON: {e}")
        logger.debug(f"JSON content was: {creds_json}")
        raise ValueError(f"Invalid JSON in USER_CREDENTIALS: {e}")


# Expose dictionary of user credentials
ALL_CREDENTIALS = get_credentials()
