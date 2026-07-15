"""
Dynamic locator loader that automatically overrides variables based on environment.
This eliminates the need to wrap each locator in a function call.
"""

import json
import os
from pathlib import Path

# Import the logger utility
from utils.logger import get_logger

# Get logger for this module
logger = get_logger(__name__)


class DynamicLocatorLoader:
    """Loads environment-specific locators and injects them into module globals."""

    _instance = None
    _initialized = False

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(DynamicLocatorLoader, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        if self._initialized:
            return

        # Set default environment from environment variable or fallback to default
        self.current_environment = os.environ.get("TEST_ENVIRONMENT", "QA28_B0")

        # Use absolute paths to ensure consistent behavior
        self.root_dir = Path(__file__).parent.parent  # Should be the repository root
        self.env_dir = (
            self.root_dir / "test_data" / "environments" / self.current_environment
        )

        logger.debug(
            f"Dynamic locator loader initializing for: {self.current_environment}"
        )
        logger.debug(f"Environment directory path: {self.env_dir}")

        # Load locators
        self.locators = {}
        locators_file = self.env_dir / "locators.json"

        if locators_file.exists():
            try:
                with open(locators_file, "r", encoding="utf-8") as f:
                    self.locators = json.load(f)
                    logger.debug(f"Loaded locators from: {locators_file}")
            except Exception as e:
                logger.error(f"Error loading locators file: {e}")
                self.locators = {}
        else:
            logger.debug(f"No locators file found: {locators_file}")
            self.locators = {}

        DynamicLocatorLoader._initialized = True

    def inject_locators_for_module(self, module_name, module_globals, default_locators):
        """
        Inject environment-specific locators into a module's global namespace.

        Args:
            module_name: Name of the module (e.g., 'schedule', 'hr')
            module_globals: The module's globals() dictionary
            default_locators: Dictionary of default locator values
        """
        if module_name not in self.locators:
            logger.debug(
                f"No environment-specific locators found for module: {module_name}"
            )
            return

        env_locators = self.locators[module_name]
        overridden_count = 0

        for locator_name, env_value in env_locators.items():
            if locator_name in default_locators:
                # Override the default value with environment-specific value
                module_globals[locator_name] = env_value
                overridden_count += 1
                logger.debug(
                    f"Overridden {locator_name} for environment {self.current_environment}"
                )

        if overridden_count > 0:
            logger.info(
                f"Module '{module_name}': Overridden {overridden_count} locator(s) for environment {self.current_environment}"
            )


# Global instance
_loader = None


def get_dynamic_loader():
    """Get the global dynamic locator loader instance."""
    global _loader
    if _loader is None:
        _loader = DynamicLocatorLoader()
    return _loader


def apply_environment_locators(module_name, module_globals):
    """
    Apply environment-specific locators to a module.

    Usage in page files:
    from test_data.dynamic_locator_loader import apply_environment_locators

    # Define your default locators normally
    LOCATOR1 = "//default[@xpath1]"
    LOCATOR2 = "//default[@xpath2]"

    # At the end of the file, apply environment overrides
    apply_environment_locators("schedule", globals())
    """
    loader = get_dynamic_loader()

    # Extract locator variables (uppercase variables that don't start with _)
    default_locators = {
        name: value
        for name, value in module_globals.items()
        if isinstance(name, str)
        and name.isupper()
        and not name.startswith("_")
        and isinstance(value, str)
    }

    loader.inject_locators_for_module(module_name, module_globals, default_locators)
