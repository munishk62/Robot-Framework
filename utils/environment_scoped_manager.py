"""
Environment-scoped manager for handling environment-specific variables.

This module provides functionality to manage environment variables in a process-scoped manner,
preventing conflicts when multiple pipelines run in parallel on the same VM/agent.

The core design:
1. Generate environment file names based on the test environment
2. Pass environment variables through subprocess.env instead of modifying os.environ
3. Provide utilities for decrypting credentials into isolated environment files
4. Support cleanup of temporary environment files
"""

import os
import json
from pathlib import Path
from typing import Dict, Optional
from utils.logger import get_logger

logger = get_logger(__name__)


class EnvironmentScopedManager:
    """
    Manages environment-specific variables in a process-scoped manner to prevent
    conflicts when multiple pipelines run in parallel on the same VM.

    Usage:
        manager = EnvironmentScopedManager(test_env="QA29_B0")
        env_file = manager.create_scoped_env_file(credentials_dict)
        subprocess_env = manager.get_subprocess_env(env_file)
    """

    def __init__(self, test_env: str):
        """
        Initialize the environment scoped manager.

        Args:
            test_env: The test environment name (e.g., "QA29_B0")
        """
        self.test_env = test_env
        self.base_dir = Path(__file__).resolve().parent.parent
        self.env_scoped_dir = self.base_dir / ".env_scoped"

        # Ensure scoped environment directory exists
        self.env_scoped_dir.mkdir(exist_ok=True)
        logger.debug(
            f"EnvironmentScopedManager initialized for env={test_env}, "
            f"scoped_dir={self.env_scoped_dir}"
        )

    def get_scoped_env_filename(self) -> str:
        """
        Generate a scoped environment filename.

        Format: env_{test_env}.env (scoped by environment name only)

        Returns:
            str: Filename for scoped environment file
        """
        # Scope by environment name only (sufficient for parallel execution)
        # since different pipelines run different environments
        return f"env_{self.test_env}.env"

    def get_scoped_env_filepath(self) -> Path:
        """
        Get the full path to the scoped environment file.

        Returns:
            Path: Full path to the scoped environment file
        """
        return self.env_scoped_dir / self.get_scoped_env_filename()

    def _normalize_credential_value(self, key: str, value: str) -> str:
        """
        Normalize credential values for safe env file serialization.

        Args:
            key: Credential key name
            value: Credential value

        Returns:
            str: Serialized value for env file
        """
        if key != "USER_CREDENTIALS" or not isinstance(value, str):
            return value

        try:
            return json.dumps(json.loads(value), separators=(",", ":"))
        except json.JSONDecodeError:
            return value

    def create_scoped_env_file(
        self,
        credentials: Dict[str, str],
        decrypt_keys: Optional[list] = None,
    ) -> Path:
        """
        Create an environment-scoped .env file with decrypted credentials.

        This creates a scoped .env file per environment to prevent conflicts when
        multiple pipelines run in parallel on the same VM.

        Args:
            credentials: Dictionary containing credential values
                        (e.g., {"USER_CREDENTIALS": "...", "SITE_TOKEN": "...", "DB2_CONNECTION": "..."})
            decrypt_keys: Optional list of keys to process. If None, all keys in credentials are used.

        Returns:
            Path: Path to the created scoped environment file

        Raises:
            ValueError: If credentials dictionary is empty or invalid
        """
        if not credentials:
            raise ValueError("Credentials dictionary cannot be empty")

        env_file_path = self.get_scoped_env_filepath()

        # Keys to process if decrypt_keys is specified
        keys_to_process = set(decrypt_keys) if decrypt_keys else set(credentials.keys())

        try:
            logger.info(f"Creating scoped environment file: {env_file_path}")
            with open(env_file_path, "w", encoding="utf-8") as f:
                for key, value in credentials.items():
                    if key in keys_to_process:
                        normalized_value = self._normalize_credential_value(
                            key,
                            value,
                        )

                        # Write credential to file
                        f.write(f"{key}={normalized_value}\n")
                        logger.debug(f"Added {key} to scoped environment file")
                    else:
                        logger.debug(f"Skipped {key} (not in decrypt_keys)")

            # Restrict file permissions on Unix-like systems for security
            if os.name != "nt":  # Not Windows
                os.chmod(env_file_path, 0o600)
                logger.debug(f"Set restrictive permissions (0o600) on {env_file_path}")

            logger.info(
                f"Successfully created scoped environment file: {env_file_path}"
            )
            return env_file_path

        except Exception as e:
            logger.error(f"Failed to create scoped environment file: {e}")
            raise

    def get_subprocess_env(self, env_file_path: Path) -> Dict[str, str]:
        """
        Get environment dictionary for subprocess execution from a scoped .env file.

        This reads the scoped .env file and creates a subprocess environment dictionary
        without modifying the parent process's os.environ.

        Args:
            env_file_path: Path to the scoped environment file

        Returns:
            Dict[str, str]: Environment dictionary suitable for subprocess.Popen(env=...)

        Raises:
            FileNotFoundError: If the environment file doesn't exist
        """
        if not env_file_path.exists():
            raise FileNotFoundError(f"Environment file not found: {env_file_path}")

        # Start with a copy of the current environment
        subprocess_env = os.environ.copy()

        try:
            logger.debug(f"Reading scoped environment file: {env_file_path}")
            with open(env_file_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            index = 0
            while index < len(lines):
                raw_line = lines[index].rstrip("\n")
                stripped_line = raw_line.strip()
                index += 1

                if not stripped_line or stripped_line.startswith("#"):
                    continue

                if "=" not in raw_line:
                    continue

                key, value = raw_line.split("=", 1)

                if key == "USER_CREDENTIALS" and value.count("{") > value.count("}"):
                    json_parts = [value]
                    brace_delta = value.count("{") - value.count("}")

                    while index < len(lines) and brace_delta > 0:
                        continuation = lines[index].rstrip("\n")
                        json_parts.append(continuation)
                        brace_delta += continuation.count("{") - continuation.count("}")
                        index += 1

                    value = "\n".join(json_parts)

                subprocess_env[key] = value
                logger.debug(f"Added {key} to subprocess environment")

            logger.info(
                f"Successfully created subprocess environment from: {env_file_path}"
            )
            return subprocess_env

        except Exception as e:
            logger.error(f"Failed to read scoped environment file: {e}")
            raise

    def cleanup_scoped_env_file(self) -> None:
        """
        Clean up the scoped environment file after pipeline execution completes.

        This should be called in the finally block to ensure cleanup happens
        regardless of pipeline success or failure.
        """
        env_file_path = self.get_scoped_env_filepath()

        if not env_file_path.exists():
            logger.debug(f"Scoped environment file already removed: {env_file_path}")
            return

        try:
            env_file_path.unlink()
            logger.info(
                f"Successfully cleaned up scoped environment file: {env_file_path}"
            )
        except Exception as e:
            logger.warning(f"Failed to cleanup scoped environment file: {e}")

    def cleanup_old_scoped_env_files(self, older_than_minutes: int = 60) -> int:
        """
        Clean up old scoped environment files to prevent disk space issues.

        This should be called periodically (e.g., during CI pipeline cleanup stages)
        to remove orphaned environment files from previous runs.

        Args:
            older_than_minutes: Remove files older than this many minutes

        Returns:
            int: Number of files cleaned up
        """
        import time

        if not self.env_scoped_dir.exists():
            return 0

        current_time = time.time()
        cutoff_time = current_time - (older_than_minutes * 60)
        cleaned_count = 0

        try:
            for env_file in self.env_scoped_dir.glob("env_*.env"):
                file_mtime = env_file.stat().st_mtime
                if file_mtime < cutoff_time:
                    try:
                        env_file.unlink()
                        logger.info(
                            f"Cleaned up old scoped environment file: {env_file}"
                        )
                        cleaned_count += 1
                    except Exception as e:
                        logger.warning(f"Failed to cleanup {env_file}: {e}")

            logger.info(
                f"Cleaned up {cleaned_count} old scoped environment files "
                f"(older than {older_than_minutes} minutes)"
            )
            return cleaned_count

        except Exception as e:
            logger.error(f"Error during cleanup of old scoped environment files: {e}")
            return 0

    