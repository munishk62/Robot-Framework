"""
Robot Framework library for accessing environment-specific locators
"""

from robot.api.deco import keyword
from utils.dynamic_locator_loader import get_dynamic_loader


class LocatorLibrary:
    """Robot Framework library for environment-specific locators."""

    def __init__(self):
        self.locator_loader = get_dynamic_loader()

    @keyword
    def get_environment_locator(self, module_name, locator_name, default=None):
        """Get an environment-specific locator value.

        Args:
            module_name: Module name (e.g., 'schedule', 'hr')
            locator_name: Locator variable name
            default: Default value if locator not found

        Returns:
            str: The locator value for the current environment

        Example:
        | ${locator}= | Get Environment Locator | schedule | ALLSCHEDULESPAGE_WEEK_STATUS_CELL_BY_INDEX |

        Note: This method provides the same behavior as the automatic loading in page objects.
        If no environment override exists, it returns the default value from the page object.
        """
        # Check if there's an environment-specific override
        if module_name in self.locator_loader.locators:
            env_locator = self.locator_loader.locators.get(module_name, {}).get(
                locator_name
            )
            if env_locator is not None:
                return env_locator

        # No environment override - fallback to provided default
        # In normal usage, the page object variables should be used directly
        # This method is mainly for debugging or dynamic access
        return default

    @keyword
    def get_current_environment_name(self):
        """Get the current environment name.

        Returns:
            str: Current environment name (e.g., 'QA28_B0')
        """
        return self.locator_loader.current_environment

    @keyword
    def reload_environment_locators(self):
        """Force reload of locators from disk.

        This can be useful if locator files are updated during test execution.
        """
        # Reset the loader to force reload
        self.locator_loader._initialized = False
        self.locator_loader.__init__()
