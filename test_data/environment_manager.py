"""
Environment manager for handling environment-specific values
"""

import json
import os
from pathlib import Path
import sys
from robot.api.deco import keyword

# Import the logger utility
from utils.logger import get_logger

# Get logger for this module
logger = get_logger(__name__)


class EnvironmentManager:
    """Manages environment-specific values and configurations."""

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(EnvironmentManager, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if self._initialized:
            return

        # Set default environment from environment variable or fallback to default
        self.current_environment = os.environ.get("TEST_ENVIRONMENT", "QA28")
        self.base_test_environment = os.environ.get("BASE_TEST_ENVIRONMENT", "QA29_B0")

        # Use absolute paths to ensure consistent behavior
        self.root_dir = Path(
            __file__
        ).parent.parent.parent  # Should be the repository root
        self.data_dir = Path(__file__).parent  # test_data directory
        self.env_dir = self.data_dir / "environments" / self.current_environment
        self.base_test_env_dir = (
            self.data_dir / "environments" / self.base_test_environment
        )

        logger.info(f"Environment manager initializing for: {self.current_environment}")
        logger.debug(f"Root directory: {self.root_dir}")
        logger.debug(f"Data directory: {self.data_dir}")
        logger.debug(f"Environment directory path: {self.env_dir}")
        logger.debug(f"Environment directory exists: {self.env_dir.exists()}")

        # Load constants
        self.constants = {}
        CONSTANTS_FILE_NAME = "constants.json"
        base_constants_file = self.base_test_env_dir / CONSTANTS_FILE_NAME

        # Load base constants first
        if base_constants_file.exists():
            try:
                with open(base_constants_file, "r", encoding="utf-8") as f:
                    self.constants = json.load(f)
                    logger.debug(f"Base constants loaded: {self.constants}")
            except Exception as e:
                logger.error(f"Error loading base constants: {e}")
                logger.error(f"Please check : {base_constants_file}")
                sys.exit(1)
        constants_file = self.env_dir / CONSTANTS_FILE_NAME
        logger.debug(f"Constants file path: {constants_file}")
        logger.debug(f"Constants file exists: {constants_file.exists()}")
        # Pre-load and merge environment constants to support deep overrides
        if constants_file.exists():
            try:
                with open(constants_file, "r", encoding="utf-8") as f:
                    file_content = f.read()
                    logger.debug(
                        f"Env Constants file content: {file_content[:50]}..."
                    )  # Show first 50 chars
                    env_constants = json.loads(file_content)
            except Exception as e:
                logger.error(f"Error loading environment constants: {e}")
                logger.error(f"Please check : {constants_file}")
                sys.exit(1)

            self.constants = self._deep_merge(self.constants, env_constants)
            logger.debug(f"Merged environment constants from {constants_file}")
        else:
            logger.warning(
                f"No environment-specific constants file found at: {constants_file}"
            )

        # Load config - Load base config first, then merge with env config
        self.config = {}
        CONFIG_FILE_NAME = "config.json"
        base_config_file = self.base_test_env_dir / CONFIG_FILE_NAME

        # Load base config first
        if base_config_file.exists():
            try:
                with open(base_config_file, "r", encoding="utf-8") as f:
                    self.config = json.load(f)
                    logger.debug(f"Base config loaded: {self.config}")
            except Exception as e:
                logger.error(f"Error loading base config: {e}")
                logger.error(f"Please check : {base_config_file}")
                sys.exit(1)

        config_file = self.env_dir / CONFIG_FILE_NAME
        logger.debug(f"Config file path: {config_file}")
        logger.debug(f"Config file exists: {config_file.exists()}")

        if config_file.exists():
            try:
                with open(config_file, "r", encoding="utf-8") as f:
                    env_config = json.load(f)
                    logger.debug(f"Environment config loaded: {env_config}")

                # Store enabled_configs before merge
                env_enabled_configs = env_config.get("enabled_configs", [])

                # Merge base config with environment config
                self.config = self._deep_merge(self.config, env_config)

                # Override enabled_configs with environment-specific value
                self.config["enabled_configs"] = env_enabled_configs
                logger.debug(f"Merged config with env overrides: {self.config}")
            except Exception as e:
                logger.error(f"Error loading environment config file: {e}")
                logger.error(f"Please check : {config_file}")
                sys.exit(1)
        else:
            logger.warning(
                f"No environment-specific config file found at: {config_file}"
            )

        self.enabled_configs = self.config.get("enabled_configs", [])
        self._initialized = True

    def _deep_merge(self, base, update):
        """
        Recursively merge two dictionaries with deep merge semantics.

        Parameters:
        base (dict): The base dictionary to merge into.
        update (dict): The dictionary with updates to apply.

        Returns:
        dict: The merged dictionary (modifies base in place).
        """
        for k, v in update.items():
            if isinstance(v, dict) and k in base and isinstance(base[k], dict):
                self._deep_merge(base[k], v)
            else:
                base[k] = v
        return base

    @keyword
    def get_current_environment(self):
        """Return the current environment name."""
        return self.current_environment

    @keyword
    def get_system_value(self, class_name, constant_name):
        """Get environment-specific system value for a logical constant."""
        logger.debug(
            f"Looking for system value: class={class_name}, name={constant_name}"
        )
        logger.debug(f"Available constants: {self.constants}")

        # The constants.json has a nested structure like:
        # { "DayOffReasonType": { "UNPAID_DAY_OFF": "Unpaid Day off" } }
        if class_name in self.constants and constant_name in self.constants[class_name]:
            value = self.constants[class_name][constant_name]
            logger.debug(f"Found value for {class_name}.{constant_name}: {value}")
            return value

        logger.debug(
            f"Key {class_name}.{constant_name} not found in constants, returning default: {constant_name}"
        )
        return constant_name  # Default to returning the constant name if not found

    @keyword
    def get_all_system_values(self, class_name):
        """Return a list of constant names for the given class from constants.json."""
        logger.debug(f"Fetching constants for class: {class_name}")
        logger.debug(f"Available constants: {self.constants}")

        if class_name in self.constants and isinstance(
            self.constants[class_name], dict
        ):
            constants_list = self.constants[class_name]
            logger.debug(f"Constants found for {class_name}: {constants_list}")
            return constants_list

        logger.debug(
            f"No constants found for class: {class_name}, returning empty list."
        )
        return []

    def get_config_value(self, key, default=None):
        """Get a configuration value for the current environment."""
        if key in self.config:
            return self.config.get(key)
        logger.debug(f"Config key {key} not found, returning default: {default}")
        return default

    def is_config_enabled(self, config_name):
        """Check if a specific configuration is enabled."""
        return config_name in self.enabled_configs

    def reload_constants(self):
        """Force reload of constants from disk."""
        logger.info("Reloading constants from disk...")
        constants_file = self.env_dir / "constants.json"
        if constants_file.exists():
            try:
                with open(constants_file, "r", encoding="utf-8") as f:
                    self.constants = json.load(f)
                    logger.info(f"Constants reloaded successfully: {self.constants}")
                    return True
            except Exception as e:
                logger.error(f"Error reloading constants file: {e}")
                return False
        else:
            logger.error(f"Constants file does not exist at: {constants_file}")
            return False
