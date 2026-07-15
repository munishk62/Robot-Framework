"""
Test Data Library for Robot Framework automation.

"""

import sys
import importlib
from pathlib import Path
from robot.api.deco import keyword
from test_data.constants import date_helper
from test_data.constants import time_helper
from robot.libraries.BuiltIn import BuiltIn

# Add the project root and the web directory to sys.path
project_root = Path(__file__).parent.parent.parent
web_dir = Path(__file__).parent.parent

if str(project_root) not in sys.path:
    sys.path.insert(0, str(project_root))

# Import environment manager directly
from test_data.environment_manager import EnvironmentManager

# Provider class mapping - easier to maintain as new providers are added
PROVIDER_MAPPING = {
    "user": ("test_data.providers.user_provider", "UserProvider"),
    "day_off": ("test_data.providers.day_off_provider", "DayOffDataProvider"),
    "time_off": ("test_data.providers.time_off_provider", "TimeOffDataProvider"),
    "sm_day_off": ("test_data.providers.sm_day_off_provider", "SMDayOffDataProvider"),
    "clock_native_register": (
        "test_data.providers.clock_native_register_provider",
        "ClockNativeRegisterDataProvider",
    ),
    "generic": ("test_data.providers.generic_provider", "GenericDataProvider"),
    # Add new providers here as they're created:
    # 'provider_name': ('module_path', 'ClassName'),
}


class TestDataLibrary:
    """
    This library provides comprehensive test data management capabilities for the WFM test automation framework.
    It acts as a centralized hub for accessing various data providers, managing environment configurations,
    and handling user credentials.

    == Table of contents ==

    %TOC%

    = Overview =

    The TestDataLibrary offers:
    - Unified access to multiple data providers (user, day off, time off, etc.)
    - Environment-aware configuration management
    - Dynamic entity discovery and keyword registration
    - Date utility functions for test data calculations

    = Providers =

    The library supports multiple specialized providers:
    - User Provider: Manages user credentials and authentication data
    - Day Off Provider: Handles day off request test data
    - Time Off Provider: Manages time off request scenarios
    - Generic Provider: Auto-discovers and serves any entity data

    = Usage Examples =

    Basic user data retrieval:
    | ${user}=    Get User    testuser123
    | Log    User: ${user}[username]

    Environment configuration access:
    | ${env}=    Get Current Environment
    | ${config}=    Get Config Value    app_url

    Date calculations for planning:
    | ${date}=    Calculate Date From Week Day Offset    1_3
    | ${week_start}=    Get Planning Week Start

    Entity data with templates:
    | ${day_off}=    Get Day Off Data    test_id=TC001    template_name=vacation
    | ${entities}=    Get Available Entities

    = Configuration =

    The library automatically configures itself based on:
    - Environment variables for credentials
    - config.json files for environment-specific settings
    - Auto-discovery of entity data templates

    = Week Day Offset Notation =

    week_day offset notation (e.g., '1_4') to represent dates relative to the current week start.
    Here, first number is the week offset (0=current week, 1=next week, -1=previous week) and second number is the day of the week
    (0=first day of week, 6=7th day of week).
    - 1_4 means next week ahead, 5th day of that week.
    - 1_6 means next week, 7th (last) day of that week.
    - 0_0 means current week, first day of the week.
    - -1_3 means previous week, 4th day of that week.
    - -1_0 means previous week, first day of that week.

    Note the first day of week is determined by the FISCAL_WEEK_START_DAY setting in config.json where values can be 1 to 7, 1=Sunday, 2=Monday, ..., 7=Saturday.

    """

    ROBOT_LIBRARY_SCOPE = "SUITE"

    def __init__(self):
        self.env_manager = EnvironmentManager()
        self._providers = {}
        self._auto_register_entity_keywords()

    def _auto_register_entity_keywords(self):
        """Automatically register keywords for all discovered entities."""
        try:
            generic_provider = self._get_provider("generic")

            # Register a keyword for each discovered entity
            for entity_name in generic_provider.get_available_entities():
                # Create the keyword method name
                keyword_method_name = f"get_{entity_name}_data"

                # Create a lambda function that captures the entity name
                keyword_func = self._create_entity_keyword(entity_name)

                # Add the @keyword decorator and register it
                keyword_func = keyword(keyword_func)
                setattr(self, keyword_method_name, keyword_func)

        except Exception as e:
            print(f"Warning: Could not auto-register entity keywords: {e}")

    def _create_entity_keyword(self, entity_name):
        """Create a keyword function for a specific entity."""

        def keyword_function(test_id=None, template_name="default", **overrides):
            f"""Get {entity_name} data."""
            return self._get_provider("generic")._get_entity_data(
                entity_name,
                self._get_provider("generic").discovered_entities[entity_name],
                test_id,
                template_name,
                **overrides,
            )

        # Set the function name for better error messages
        keyword_function.__name__ = f"get_{entity_name}_data"
        return keyword_function

    def _get_provider(self, provider_type):
        """Lazy-load providers only when needed using the provider mapping"""
        if provider_type not in self._providers:
            if provider_type not in PROVIDER_MAPPING:
                raise ValueError(f"Unknown provider type: {provider_type}")

            module_path, class_name = PROVIDER_MAPPING[provider_type]

            # Dynamically import the provider module and class
            try:
                module = importlib.import_module(module_path)
                provider_class = getattr(module, class_name)
                self._providers[provider_type] = provider_class()
            except (ImportError, AttributeError) as e:
                raise ImportError(f"Failed to load provider '{provider_type}': {e}")

        return self._providers[provider_type]

    # User provider keywords
    @keyword
    def get_user(self, user_key=None, mask_password=True, **kwargs):
        """
        Retrieves user data based on user key from credentials or templates.

        This keyword provides access to user authentication data, supporting both
        credential-based lookup and template-based generation. Passwords are
        automatically masked for security unless explicitly disabled.

        | =Arguments= | =Description= |
        | user_key | Specific user key to fetch from credentials. If None, uses template data. |
        | mask_password | Whether to mask password in the returned data for security. |
        | **kwargs | Additional parameters to customize the user data generation. |

        *Returns*: Dictionary containing user data with keys like 'username', 'password', etc.

        Examples:
        | ${user}=    Get User    testuser123
        | ${user}=    Get User    mask_password=False
        | ${user}=    Get User    role=admin    department=IT
        """
        return self._get_provider("user").get_user(user_key, mask_password, **kwargs)

    @keyword
    def get_available_users(self):
        """
        Retrieves a list of all available user IDs from the credentials system.

        This keyword is useful for discovering what users are available for testing
        and can be used to iterate through different user scenarios.

        *Returns*: List of available user ID strings from the credentials system.

        Examples:
        | ${users}=    Get Available Users
        | Log List    ${users}
        | FOR    ${user_id}    IN    @{users}
        |     ${user}=    Get User    ${user_id}
        |     Log    Testing with user: ${user}[username]
        | END
        """
        return self._get_provider("user").get_available_users()

    # Day off provider keywords
    @keyword
    def get_day_off_data(self, test_id=None, template_name="default", **overrides):
        """
        Generates day off request test data using templates and optional overrides.

        This keyword provides realistic day off request data that can be customized
        for specific test scenarios using templates and parameter overrides.

        | =Arguments= | =Description= |
        | test_id | Optional test ID for tracking and reproducibility. |
        | template_name | Name of the template to use for data generation. |
        | **overrides | Key-value pairs to override specific template values. |

        *Returns*: Dictionary containing day off request data including dates, reasons, status, etc.

        Examples:
        | ${day_off}=    Get Day Off Data
        | ${day_off}=    Get Day Off Data    template_name=vacation
        | ${day_off}=    Get Day Off Data    test_id=TC001    reason=Medical Leave
        """
        return self._get_provider("day_off").get_day_off_data(
            test_id, template_name, **overrides
        )

    # Time off provider keywords
    @keyword
    def get_time_off_data(self, test_id=None, template_name="default", **overrides):
        """
        Generates time off request test data using templates and optional overrides.

        This keyword provides realistic time off request data for partial day scenarios,
        including start times, durations, and reasons that can be customized per test.

        | =Arguments= | =Description= |
        | test_id | Optional test ID for tracking and reproducibility. |
        | template_name | Name of the template to use for data generation. |
        | **overrides | Key-value pairs to override specific template values. |

        *Returns*: Dictionary containing time off request data including times, duration, reasons, etc.

        Examples:
        | ${time_off}=    Get Time Off Data
        | ${time_off}=    Get Time Off Data    template_name=medical
        | ${time_off}=    Get Time Off Data    start_time=14:00    duration=2
        """
        return self._get_provider("time_off").get_time_off_data(
            test_id, template_name, **overrides
        )

    # Clock Native Register provider keywords
    @keyword
    def get_native_clock_register_data(
        self, test_id=None, template_name="default", **overrides
    ):
        """
        Generates native clock register test data using templates and optional overrides.

        This keyword provides realistic clock registration data including device location
        and location services settings that can be customized per test.

        | =Arguments= | =Description= |
        | test_id | Optional test ID for tracking and reproducibility. |
        | template_name | Name of the template to use for data generation. |
        | **overrides | Key-value pairs to override specific template values. |

        *Returns*: Dictionary containing native clock registration data including
        device location and related settings.

        Examples:
        | ${register_data}=    Get Native Clock Register Data
        | ${register_data}=    Get Native Clock Register Data    template_name=custom
        | ${register_data}=    Get Native Clock Register Data    device_location=Back End
        | ${register_data}=    Get Native Clock Register Data    enable_location_services=${True}
        """
        return self._get_provider("clock_native_register").get_native_clock_register_data(
            test_id, template_name, **overrides
        )

    # Generic provider keywords - Auto-discovers entities
    @keyword
    def get_shift_data(self, test_id=None, template_name="default", **overrides):
        """
        Generates shift scheduling test data using templates and optional overrides.

        This keyword provides realistic shift data including times, positions, and
        scheduling details that can be customized for various testing scenarios.

        | =Arguments= | =Description= |
        | test_id | Optional test ID for tracking and reproducibility. |
        | template_name | Name of the template to use for data generation. |
        | **overrides | Key-value pairs to override specific template values. |

        *Returns*: Dictionary containing shift data including start/end times, position, etc.

        Examples:
        | ${shift}=    Get Shift Data
        | ${shift}=    Get Shift Data    template_name=morning
        | ${shift}=    Get Shift Data    start_time=06:00    position=Cashier
        """
        return self._get_provider("generic").get_shift_data(
            test_id, template_name, **overrides
        )

    @keyword
    def get_available_entities(self):
        """
        Retrieves a list of all discovered entities available for data generation.

        This keyword returns all entity types that have been auto-discovered by the
        generic provider, which can be used for dynamic test data generation.

        *Returns*: List of entity names that can be used with data generation keywords.

        Examples:
        | ${entities}=    Get Available Entities
        | Log List    ${entities}
        | Should Contain    ${entities}    user
        | Should Contain    ${entities}    shift
        """
        return self._get_provider("generic").get_available_entities()

    @keyword
    def get_entity_templates(self, entity_name):
        """
        Retrieves available templates for a specific entity type.

        This keyword returns all template names available for a given entity,
        allowing tests to choose appropriate data variations for their scenarios.

        | =Arguments= | =Description= |
        | entity_name | Name of the entity to get templates for. |

        *Returns*: List of template names available for the specified entity.

        Examples:
        | ${templates}=    Get Entity Templates    user
        | Log List    ${templates}
        | ${templates}=    Get Entity Templates    day_off
        | Should Contain    ${templates}    vacation
        """
        return self._get_provider("generic").get_entity_templates(entity_name)

    @keyword
    def get_generic_entity_data(
        self, entity_name, test_id=None, template_name="default", **overrides
    ):
        """
        Generates data for any entity using the generic provider.

        This is a fallback method for entities that don't have dedicated keywords,
        providing access to any discovered entity through a unified interface.

        | =Arguments= | =Description= |
        | entity_name | Name of the entity to generate data for. |
        | test_id | Optional test ID for tracking and reproducibility. |
        | template_name | Name of the template to use for data generation. |
        | **overrides | Key-value pairs to override specific template values. |

        *Returns*: Dictionary containing entity data based on the specified template and overrides.

        Examples:
        | ${data}=    Get Generic Entity Data    employee
        | ${data}=    Get Generic Entity Data    schedule    template_name=weekend
        | ${data}=    Get Generic Entity Data    request    status=pending
        """
        provider = self._get_provider("generic")
        # Call the dynamically created method
        method_name = f"get_{entity_name}_data"
        if hasattr(provider, method_name):
            return getattr(provider, method_name)(test_id, template_name, **overrides)
        else:
            raise ValueError(
                f"Entity '{entity_name}' not found. Available entities: {provider.get_available_entities()}"
            )

    # Environment manager keywords
    @keyword
    def get_current_environment(self):
        """
        Retrieves the name of the currently active environment.

        This keyword returns the environment name that the test framework is currently
        configured to use, which determines which configuration values are loaded.

        *Returns*: String containing the current environment name (e.g., 'dev', 'test', 'prod').

        Examples:
        | ${env}=    Get Current Environment
        | Log    Currently testing in: ${env}
        | Run Keyword If    '${env}' == 'prod'    Fail    Cannot run destructive tests in production
        """
        return self.env_manager.get_current_environment()

    @keyword
    def get_system_value(self, class_name, constant_name):
        """
        Retrieves a system value for a logical constant from environment configuration.

        This keyword provides access to system-level configuration values that are
        organized by class and constant name, allowing for structured configuration access.

        | =Arguments= | =Description= |
        | class_name | Name of the configuration class containing the constant. |
        | constant_name | Name of the specific constant to retrieve. |

        *Returns*: The configured value for the specified class and constant.

        Examples:
        | ${timeout}=    Get System Value    timeouts    login_timeout
        | ${url}=    Get System Value    endpoints    api_base_url
        """
        return self.env_manager.get_system_value(class_name, constant_name)

    @keyword
    def get_all_system_values(self, class_name):
        """
        Retrieves all system values for a specified class from environment configuration.

        This keyword provides access to all configuration values within a class,
        returning them as a dictionary for comprehensive access to related settings.

        | =Arguments= | =Description= |
        | class_name | Name of the configuration class to retrieve all values from. |

        *Returns*: Dictionary containing all constants and their values for the specified class.

        Examples:
        | ${all_timeouts}=    Get All System Values    timeouts
        | Log Dictionary    ${all_timeouts}
        """
        return self.env_manager.get_all_system_values(class_name)

    @keyword
    def get_config_value(self, key, default=None):
        """
        Retrieves a configuration value by key with optional default fallback.

        This keyword provides access to environment-specific configuration values,
        returning the default value if the key is not found in the current environment.

        | =Arguments= | =Description= |
        | key | Configuration key to look up. |
        | default | Default value to return if key is not found. |

        *Returns*: The configuration value for the key, or the default value if not found.

        Examples:
        | ${url}=    Get Config Value    app_url
        | ${timeout}=    Get Config Value    page_timeout    30
        | ${debug}=    Get Config Value    debug_mode    False
        """
        return self.env_manager.get_config_value(key, default)

    @keyword
    def is_config_enabled(self, key):
        """
        Checks if a configuration setting is enabled by evaluating if config.json has the key in enabled_configs list

        | =Arguments= | =Description= |
        | key | Configuration key to check for enabled status. |

        *Returns*: Boolean True if the configuration is enabled, False otherwise.

        Examples:
        | ${headless}=    Is Config Enabled    headless_mode
        | Run Keyword If    ${headless}    Log    Running in headless mode
        | ${debug}=    Is Config Enabled    debug_logging
        """
        return self.env_manager.is_config_enabled(key)

    # Date utility keywords that leverage config.json settings
    @keyword
    def get_planning_week_start(self, date_format="%Y-%m-%d"):
        """
        Calculates the planning week start date based on fiscal week configuration.

        This keyword determines the start of the current planning week based on the
        FISCAL_WEEK_START_DAY setting in config.json, providing consistent date
        calculations across the test suite.

        | =Arguments= | =Description= |
        | date_format | Output date format string (default: %Y-%m-%d). |

        *Returns*: Planning week start date in the specified format.

        Examples:
        | ${week_start}=    Get Planning Week Start
        | ${week_start}=    Get Planning Week Start    %m/%d/%Y
        | Log    Planning week starts on: ${week_start}
        """
        # Get the fiscal week start day from config (1=Sun, 7=Saturday)
        fiscal_week_start_day = int(self.get_config_value("FISCAL_WEEK_START_DAY", 1))
        # Get a global/suite/test variable; returns default if not set
        is_planning_week_enabled = BuiltIn().get_variable_value("${PLANNING_WEEK_ENABLED}", False)

        if is_planning_week_enabled:
            base_date = self.get_config_value("PLANNING_WEEK_BASE_DATE", None)
            return date_helper.get_planning_week_start(fiscal_week_start_day, date_format, base_date)
        else:
            return date_helper.get_planning_week_start(fiscal_week_start_day, date_format)

    @keyword
    def calculate_date_from_week_day_offset(
        self, weekday_offset, date_format="%Y-%m-%d"
    ):
        """
        Calculates a specific date from a week-day offset format.

        This keyword converts week-day offset notation into actual dates, using the fiscal week start configuration
        for consistent date calculations across tests.

        | =Arguments= | =Description= |
        | weekday_offset | Week-day offset string, refer `Week Day Offset Notation`. |
        | date_format | Output date format string (default: %Y-%m-%d). |

        *Returns*: Calculated date in the specified format.

        Examples:
        | ${date}=    Calculate Date From Week Day Offset    1_3
        | ${date}=    Calculate Date From Week Day Offset    2_1    %m/%d/%Y
        | Log    Target date is: ${date}
        """
        fiscal_week_start_day = int(self.get_config_value("FISCAL_WEEK_START_DAY", 1))
        # Get a global/suite/test variable; returns default if not set
        is_planning_week_enabled = BuiltIn().get_variable_value("${PLANNING_WEEK_ENABLED}", False)

        if is_planning_week_enabled:
            base_date = self.get_config_value("PLANNING_WEEK_BASE_DATE", None)
            return date_helper.calculate_date_from_week_day_offset(
                weekday_offset, fiscal_week_start_day, date_format, base_date
            )
        else:
            return date_helper.calculate_date_from_week_day_offset(
                weekday_offset, fiscal_week_start_day, date_format
            )

    @keyword
    def calculate_date_from_week_day_offset_in_multiple_formats(
        self, weekday_offset, *date_formats
    ):
        """
        Calculates a specific date from a week-day offset and returns it in multiple date formats.

        This keyword converts week-day offset notation into actual dates, using the fiscal week start configuration
        for consistent date calculations across tests.

        | =Arguments= | =Description= |
        | weekday_offset | Week-day offset format string, refer `Week Day Offset Notation`. |
        | date_formats | Variable number of output date format strings (e.g., '%Y-%m-%d', '%d/%m/%Y'). |

        *Returns*: Calculated date in the specified formats.

        Examples:
        | ${format1}    ${format2}=    Calculate Date From Week Day Offset In Multiple Formats    1_3    %m/%d/%Y    %B %d, %Y
        | Should give  ${format1} = 11/26/2025	${format2} = November 26, 2025
        | ${format3}=    Calculate Date From Week Day Offset In Multiple Formats    2_1    %m/%d/%Y    %B %d, %Y   %d-%m-%Y
        | ${format3} = ['12/01/2025', 'December 01, 2025', '01-12-2025']
        | Log    Target date is: ${date}
        """
        fiscal_week_start_day = int(self.get_config_value("FISCAL_WEEK_START_DAY", 1))
        # Get a global/suite/test variable; returns default if not set
        is_planning_week_enabled = BuiltIn().get_variable_value("${PLANNING_WEEK_ENABLED}", False)

        if is_planning_week_enabled:
            base_date = self.get_config_value("PLANNING_WEEK_BASE_DATE", None)
            return date_helper.calculate_date_from_week_day_offset_in_multiple_formats(
                weekday_offset, fiscal_week_start_day, *date_formats, base_date=base_date
            )
        else:
            return date_helper.calculate_date_from_week_day_offset_in_multiple_formats(
                weekday_offset, fiscal_week_start_day, *date_formats
            )

    @keyword
    def convert_24hr_time_to_12hr(self, time_24hr_str, am_pm_format="AM/PM"):
        """
        Converts a time string from 24-hour format to 12-hour AM/PM format.

        This keyword is useful for converting time representations in test data
        to ensure compatibility with systems that use 12-hour time formats.

        | =Arguments= | =Description= |
        | time_24hr_str | Time string in 24-hour format (e.g., '14:30'). |
        | am_pm_format | Custom time suffix format -  Valid values: "AM/PM", "am/pm", "A/P", "a/p"  Default "AM/PM"|

        *Returns*: Time string converted to 12-hour AM/PM format (e.g., '02:30 PM').

        Examples:
        | ${time_12hr}=    Convert 24hr Time To 12hr    14:30    A/P
        | ${time_12hr}=    Convert 24hr Time To 12hr    14:30    am/pm
        | Log    Converted time: ${time_12hr}
        | ${time_12hr}=    Convert 24hr Time To 12hr    09:15
        | Log    Converted time: ${time_12hr}
        """
        return time_helper.convert_24hr_time_to_12hr(time_24hr_str, am_pm_format)

    @keyword
    def convert_ui_time_to_24hr(self, time_string):
        """
        Converts time from UI format (12hr or 24hr) to 24hr format for verification/comparison.

        This keyword intelligently detects the time format and converts accordingly:
        - If time is in 12hr format (contains 'a' or 'p'): Converts to 24hr format
        - If time is already in 24hr format: Returns as-is
        - Handles overnight shifts with dash prefix for both formats (e.g., "- 05:00p" → "17:00", "- 16:00" → "16:00")

        | =Arguments= | =Description= |
        | time_string | Time string in either 12hr UI format (e.g., "08:00a", "- 05:00p") or 24hr format (e.g., "08:00", "- 16:00") |

        *Returns*: Time string in 24hr format (HH:MM)

        Examples:
        | ${time_24hr}=    Convert UI Time To 24hr    08:00a
        | ${time_24hr}=    Convert UI Time To 24hr    - 05:00p
        | ${time_24hr}=    Convert UI Time To 24hr    08:00
        | ${time_24hr}=    Convert UI Time To 24hr    - 16:00
        | Log    Converted time: ${time_24hr}
        """
        return time_helper.convert_ui_time_to_24hr(time_string)

    @keyword
    def convert_time_to_minutes(self, time_str):
        """
        Converts a time string (12hr or 24hr format) to minutes since midnight.

        This keyword handles time strings in 24-hour format (e.g., '08:00', '14:30') or 12-hour format
        with AM/PM or localized suffixes (e.g., '08:00 AM', '02:30 PM', '08:00 a', '02:30 p').
        It automatically detects the format and converts to total minutes since midnight.

        | =Arguments= | =Description= |
        | time_str | Time string in 24hr format (HH:MM) or 12hr format (HH:MM AM/PM or HH:MM a/p). |

        *Returns*: Integer representing total minutes since midnight (e.g., 480 for 08:00).

        Examples:
        | ${minutes}=    Convert Time To Minutes    08:00
        | # Returns 480
        | ${minutes}=    Convert Time To Minutes    02:30 PM
        | # Returns 870
        | ${minutes}=    Convert Time To Minutes    08:00 a
        | # Returns 480
        """
        time_str_upper = time_str.upper()
        has_am = "AM" in time_str_upper or "A" in time_str_upper
        has_pm = "PM" in time_str_upper or "P" in time_str_upper
        if has_am or has_pm:
            # 12hr format
            time_part = (
                time_str_upper.replace("AM", "")
                .replace("PM", "")
                .replace("A", "")
                .replace("P", "")
                .strip()
            )
            parts = time_part.split(":")
            hour = int(parts[0])
            minute = int(parts[1])
            if has_pm and hour != 12:
                hour += 12
            elif has_am and hour == 12:
                hour = 0
        else:
            # 24hr format
            parts = time_str.split(":")
            hour = int(parts[0])
            minute = int(parts[1])
        total_minutes = hour * 60 + minute
        return total_minutes

    @keyword
    def calculate_week_start(self, date_string):
        """
        Calculates the start date of the week for a given date.

        Single source of truth: Fetches FISCAL_WEEK_START_DAY from config.json.
        This keyword will fail if config is missing - by design to catch configuration errors early.

        This keyword determines the fiscal week start date for any given date based on
        the FISCAL_WEEK_START_DAY setting in config.json. This ensures all date
        calculations are consistent with the environment's fiscal calendar.

        | =Arguments= | =Description= |
        | date_string | Date in YYYY-MM-DD format. |

        *Returns*: Week start date in YYYY-MM-DD format.

        *Raises*: ValueError if FISCAL_WEEK_START_DAY is not found in config.

        Examples:
        | ${week_start}=    Calculate Week Start    2024-11-25
        | Log    Week starts on: ${week_start}
        | ${week_start}=    Calculate Week Start    ${current_date}

        Note: This keyword requires FISCAL_WEEK_START_DAY to be configured in config.json.
        If the config is missing, run: python -m dev_utils.env_config_sync.cli --env <ENV_NAME>
        """
        return date_helper.calculate_week_start(date_string)

    @keyword
    def calculate_week_start_date_from_week_day_offset(
        self, weekday_offset, date_format="%Y-%m-%d"
    ):
        """
        Calculates the start date of a week from a week-day offset format.

        This keyword uses the planning week start (based on FISCAL_WEEK_START_DAY in config.json)
        as the base and then applies the week offset to return the corresponding week start date.

        | =Arguments= | =Description= |
        | weekday_offset | Week-day offset string, refer `Week Day Offset Notation`. |
        | date_format | Output date format string (default: %Y-%m-%d). |

        *Returns*: Calculated week start date in the specified format.

        Examples:
        | ${week_start}=    Calculate Week Start Date From Week Day Offset    1_3
        | ${week_start}=    Calculate Week Start Date From Week Day Offset    2_1    %m/%d/%Y
        | Log    Target week starts on: ${week_start}
        """
        fiscal_week_start_day = int(self.get_config_value("FISCAL_WEEK_START_DAY", 1))
        # Get a global/suite/test variable; returns default if not set
        is_planning_week_enabled = BuiltIn().get_variable_value("${PLANNING_WEEK_ENABLED}", False)

        if is_planning_week_enabled:
            base_date = self.get_config_value("PLANNING_WEEK_BASE_DATE", None)
            return date_helper.calculate_week_start_date_from_weekday_offset(
                weekday_offset, fiscal_week_start_day, date_format,base_date
            )
        else:
            return date_helper.calculate_week_start_date_from_weekday_offset(
                weekday_offset, fiscal_week_start_day, date_format
            )

    @keyword
    def get_current_week_day_offset(self, week_offset=0):
        """
        Gets the current day in week_day format (e.g., '0_3' for current week, Wednesday).

        This keyword automatically calculates which day of the planning week today is,
        returning it in the week_day format used throughout the framework. You can
        optionally offset to future or past weeks while keeping the same day of week.

        | =Arguments= | =Description= |
        | week_offset | Number of weeks to offset from current week (default: 0 for current week). |

        *Returns*: String in weekday_offset format refer `Week Day Offset Notation`

        Examples:
        | ${today}=    Get Current Week Day Offset
        | # Returns '0_3' if today is Wednesday of current planning week
        | ${next_week_same_day}=    Get Current Week Day Offset    week_offset=1
        | # Returns '1_3' for Wednesday of next planning week
        | ${last_week_same_day}=    Get Current Week Day Offset    week_offset=-1
        | # Returns '-1_3' for Wednesday of last planning week
        """
        from datetime import datetime

        # Get fiscal week start day from config
        fiscal_week_start_day = int(self.get_config_value("FISCAL_WEEK_START_DAY", 1))

        # Get current date
        current_date = datetime.now()

        # Get a global/suite/test variable; returns default if not set
        is_planning_week_enabled = BuiltIn().get_variable_value("${PLANNING_WEEK_ENABLED}", False)
        if is_planning_week_enabled:
            base_date = self.get_config_value("PLANNING_WEEK_BASE_DATE", None)
        else:
            base_date = None

        # Get planning week start
        week_start_str = date_helper.get_planning_week_start(
            fiscal_week_start_day, "%Y-%m-%d",base_date
        )
        week_start_date = datetime.strptime(week_start_str, "%Y-%m-%d")

        # Calculate raw day offset from the planning week start.
        days_diff = (current_date - week_start_date).days

        # Normalize so the day-segment is always within [0, 6].
        # Python's divmod uses floor semantics, so it works correctly for
        # negative day differences as well:
        #   divmod(-18, 7) == (-3, 3)  -> "-3_3"  (today is 18 days before base)
        #   divmod( 10, 7) == ( 1, 3)  -> "1_3"   (today is 10 days after base start)
        #   divmod(  3, 7) == ( 0, 3)  -> "0_3"   (within current planning week)
        week_shift, day_of_week = divmod(days_diff, 7)
        final_week_offset = int(week_offset) + week_shift

        # Return in week_day format
        return f"{final_week_offset}_{day_of_week}"

    @keyword
    def combine_week_offset_and_day_no(self, week_no_or_offset,day_no):
        """
        Combines week offset and day number into week_day offset format (e.g., '1_4').

        This keyword constructs a week_day offset string from separate week offset
        and day number inputs, allowing for flexible date calculations in tests.

        | =Arguments= | =Description= |
        | week_no_or_offset | The week no as 2,3,4 or week_offset e.g. 2_0, 3_0 etc. |
        | day_no | Day number within the week (0=first day, 6=seventh day, default: 0). |

        *Returns*: String in weekday_offset format refer `Week Day Offset Notation`

        Examples:
        | ${offset}=    Combine Week Offset And Day No    week_no_or_offset=1    day_no=4
        | # Returns '1_4' for 5th day of next  week
        | ${offset}=    Combine Week Offset And Day No    week_no_or_offset=2_0    day_no=3
        | # Returns '2_3' for 4th day of 3rd  week
        """
        return date_helper.combine_week_offset_and_day_offset(week_no_or_offset,day_no)

    @keyword
    def convert_minutes_to_timeformat(self, total_minutes, in_12hr_format=False, am_pm_format="AM/PM"):
        """
        Converts total minutes since midnight to a time string in HH:MM format.

        This keyword is useful for converting minute-based time representations
        back into standard time strings for display or further processing.

        | =Arguments= | =Description= |
        | total_minutes | Integer representing total minutes since midnight. |
        | in_12hr_format | Whether to return time in 12-hour format with AM/PM (default: False for 24-hour format). |
        | am_pm_format | Custom time suffix format. The AM/PM notation style when in_12hr_format=True.
                                     Valid values:
                                     - With space & leading zero: "AM/PM" (default), "am/pm", "A/P", "a/p"
                                     - Without space, with leading zero: "AMPM", "ampm", "AP", "ap"
                                     - With space, no leading zero: "-AM/PM", "-am/pm", "-A/P", "-a/p"
                                     - Without space, no leading zero: "-AMPM", "-ampm", "-AP", "-ap"
                                     Defaults to "AM/PM"
                                     Use "-" prefix to omit leading zero ("5:00" vs "05:00") |


        *Returns*: Time string in HH:MM format.

        Examples:
        | ${time_str}=    Convert Minutes To Timeformat    480
        | # Returns '08:00'
        | ${time_str}=    Convert Minutes To Timeformat    870
        | # Returns '14:30'
        | ${time_str}=    Convert Minutes To Timeformat    870    in_12hr_format=True    am_pm_format=A/P
        """
        return time_helper.convert_minutes_to_timeformat(total_minutes, in_12hr_format, am_pm_format)

    @keyword
    def calculate_fiscal_week_number_from_week_day_offset(self, weekday_offset):
        """
        Calculate the fiscal week number (1-52) from a week_day offset format.

        This keyword takes a week_day offset (e.g., '8_0') and returns the corresponding
        fiscal week number within the fiscal year.

        | =Arguments= | =Description= |
        | weekday_offset | Week-day offset string, refer `Week Day Offset Notation`. |

        *Returns*: Fiscal week number (integer 1-52)

        Examples:
        | ${week_num}=    Calculate Fiscal Week Number From Week Day Offset    8_0
        | Log    Week offset 8_0 corresponds to fiscal week: ${week_num}
        | ${week_num}=    Calculate Fiscal Week Number From Week Day Offset    1_3
        """
        fiscal_week_start_day = int(self.get_config_value("FISCAL_WEEK_START_DAY", 1))
        # Get a global/suite/test variable; returns default if not set
        is_planning_week_enabled = BuiltIn().get_variable_value("${PLANNING_WEEK_ENABLED}", False)

        if is_planning_week_enabled:
            base_date = self.get_config_value("PLANNING_WEEK_BASE_DATE", None)
            return date_helper.calculate_fiscal_week_number_from_week_day_offset(
                weekday_offset, fiscal_week_start_day, base_date
            )
        else:
            return date_helper.calculate_fiscal_week_number_from_week_day_offset(
                weekday_offset, fiscal_week_start_day
            )
