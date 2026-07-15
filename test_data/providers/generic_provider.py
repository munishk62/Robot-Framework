"""
Generic auto-discovering data provider that dynamically creates keywords for any entity.
This provider eliminates the need to create individual provider classes for each entity.
"""

import json
from json import JSONDecodeError
from robot.api.deco import keyword
from test_data.constants import date_helper
from test_data.constants import time_helper
from test_data.providers.base_provider import BaseDataProvider

# Import the logger utility
from utils.logger import get_logger

# Get logger for this module
logger = get_logger(__name__)


class GenericDataProvider(BaseDataProvider):
    """
    Generic provider that auto-discovers entities and creates dynamic keywords.


    For any entity (e.g., 'shift'), if there's a folder at:
    test_data/entities/shift/base_templates.json


    This provider will automatically create a keyword: 'Get Shift Data'
    """


    def __init__(self):
        # Initialize with a dummy domain - we'll override this per entity
        super().__init__("generic")
        logger.debug("Initializing GenericDataProvider")
        self.discovered_entities = {}
        self._discover_entities()
        self._register_dynamic_keywords()
        self.fiscal_week_start_day = int(
            self.env_manager.get_config_value("FISCAL_WEEK_START_DAY", 1)
        )
        logger.debug(f"Initializing GenericDataProvider completed")

    def _discover_entities(self):
        """Discover all entities by scanning the templates directory."""
        templates_root = self.test_data_dir / "entities"
        logger.debug(f"Scanning templates directory: {templates_root}")
        if not templates_root.exists():
            logger.warning(f"Templates directory does not exist: {templates_root}")
            return


        for entity_dir in templates_root.iterdir():
            if entity_dir.name in ["day_off", "time_off"]:
                continue  # skip where we have specific providers already
            if entity_dir.is_dir():
                base_template_path = entity_dir / "base_templates.json"
                config_path = entity_dir / "entity_config.json"

                if base_template_path.exists():
                    try:
                        entity_info = {
                            "name": entity_dir.name,
                            "templates_path": base_template_path,
                            "overrides_dir": entity_dir / "overrides",
                            "config": self._load_entity_config(config_path),
                            "templates": self._load_entity_templates(base_template_path),
                        }
                        self.discovered_entities[entity_dir.name] = entity_info
                        logger.debug(f"✅ Discovered entity: {entity_dir.name}")
                    except (OSError, JSONDecodeError, KeyError, ValueError) as exc:
                        logger.exception(
                            "⚠️ Failed to load entity '%s': %s",
                            entity_dir.name,
                            exc,
                        )
                        logger.warning(
                            "   Skipping %s - other entities will continue to load",
                            entity_dir.name,
                        )
                        continue

    def _load_entity_config(self, config_path):
        """Load entity-specific configuration."""
        default_config = {
            "constant_classes": [],
            "date_fields": [],
            "time_fields": [],  # New: fields that should be converted from minutes to time strings
            "required_processing": [],
            "template_references": {},  # New: maps field names to entity names for template resolution
        }


        if config_path.exists():
            with open(config_path, "r") as file:
                user_config = json.load(file)
                default_config.update(user_config)


        return default_config


    def _load_entity_templates(self, template_path):
        """Load templates for a specific entity."""
        # Special handling for HRBA - load environment-specific config
        if "hrba_api_upload" in str(template_path):
            return self._load_hrba_env_specific_templates(template_path)

        with open(template_path, "r") as file:
            return json.load(file)

    def _load_hrba_env_specific_templates(self, base_template_path):
        """
        Load environment-specific HRBA templates from hrba_configs folder.

        Maps environment to corresponding config file:
        - QA29_B0 -> qa29_b0_config.json
        - WAG_SB -> wag_config.json
        - etc.

        Falls back to base_templates.json if env-specific config not found.
        """
        current_env = self.env_manager.get_current_environment()
        logger.debug(f"Loading HRBA templates for environment: {current_env}")

        # Derive config file name from environment name
        # Convert environment name to lowercase and replace underscores
        # Examples: QA29_B0 -> qa29_b0, WAG_SB -> wag, TB_SB -> tb
        env_lower = current_env.lower()

        # Remove common suffixes like _sb, _pp, _dryrun to get base name
        base_env_name = env_lower
        for suffix in ['_sb', '_pp', '_dryrun']:
            if base_env_name.endswith(suffix):
                base_env_name = base_env_name.replace(suffix, '')
                break

        config_file_name = f"{base_env_name}_config.json"

        # Path to HRBA config file directly in hrba_api_upload folder
        # Config files are at: test_data/entities/hrba_api_upload/qa29_b0_config.json
        env_config_path = base_template_path.parent / config_file_name

        logger.debug(f"Looking for HRBA config at: {env_config_path}")

        if env_config_path.exists():
            logger.info(f"✅ Loading environment-specific HRBA config: {config_file_name}")
            with open(env_config_path, "r") as file:
                return json.load(file)
        else:
            # Fail fast with clear error instead of silently falling back
            # base_templates.json is just a placeholder and lacks required field_order
            available_configs = [
                f.stem for f in base_template_path.parent.glob("*_config.json")
            ]
            error_message = (
                f"\n{'='*80}\n"
                f"❌ HRBA Configuration Error: Missing environment-specific config\n"
                f"{'='*80}\n"
                f"Environment: {current_env}\n"
                f"Expected file: {env_config_path}\n"
                f"\n"
                f"Available HRBA configs:\n"
                f"  {', '.join(available_configs) if available_configs else 'None'}\n"
                f"\n"
                f"Action Required:\n"
                f"  1. Create {config_file_name} in test_data/entities/hrba_api_upload/\n"
                f"  2. Copy from a similar environment (e.g., qa29_b0_config.json)\n"
                f"  3. Update field values for {current_env} environment\n"
                f"\n"
                f"Note: Only HRBA-related keywords will fail. Other entity keywords will work normally.\n"
                f"{'='*80}\n"
            )
            logger.error(error_message)
            raise FileNotFoundError(
                f"HRBA config not found for environment '{current_env}'. "
                f"Expected: {config_file_name} in {base_template_path.parent}. "
                f"Available configs: {', '.join(available_configs) if available_configs else 'None'}. "
                f"Only HRBA keywords will be unavailable - other entities will work normally."
            )


    def _register_dynamic_keywords(self):
        """Dynamically register keywords for discovered entities."""
        for entity_name, entity_info in self.discovered_entities.items():
            # Create a dynamic keyword function
            keyword_name = f"get_{entity_name}_data"
            keyword_func = self._create_keyword_function(entity_name, entity_info)


            # Add the @keyword decorator and register it
            keyword_func = keyword(keyword_func)
            setattr(self, keyword_name, keyword_func)


            # Also register the more readable version
            readable_name = f"Get {entity_name.replace('_', ' ').title()} Data"
            setattr(self, readable_name.replace(" ", ""), keyword_func)

    def _create_keyword_function(self, entity_name, entity_info):
        """Create a keyword function for a specific entity."""


        def keyword_function(test_id=None, template_name="default", **overrides):
            f"""
            Returns test data for a {entity_name} test case.
            
            Args:
                test_id: Optional test ID to return data for a specific test case
                template_name: Name of the template to use (default is 'default')
                **overrides: Any field values to override in the base template
                
            Returns:
                Dict: Test data object with all required fields for {entity_name}
            """
            return self._get_entity_data(
                entity_name, entity_info, test_id, template_name, **overrides
            )
        return keyword_function

    def _get_entity_data(
        self,
        entity_name,
        entity_info,
        test_id=None,
        template_name="default",
        **overrides,
    ):
        """Core logic to get data for any entity."""
        templates = entity_info["templates"]
        config = entity_info["config"]

        # Start with the base template
        if template_name not in templates:
            template_name = "default"

        base_data = templates[template_name].copy()

        # Apply test-specific overrides if a test ID is provided
        if test_id:
            test_overrides = self._get_entity_test_override(
                entity_name, entity_info, test_id
            )
            base_data.update(test_overrides)


        # Apply any additional overrides passed to the function
        base_data.update(overrides)
        # Process date placeholders if configured
        if config.get("date_fields"):
            # if template has _date_format field use that format for date processing
            if "_date_format" in base_data:
                base_data = self._process_entity_date_placeholders(
                    base_data, config["date_fields"], base_data["_date_format"]
                )
            else:
                base_data = self._process_entity_date_placeholders(
                    base_data, config["date_fields"]
                )

        # Resolve template references if configured (do this before time/constant processing)
        if config.get("template_references"):
            base_data = self._resolve_template_references(
                base_data, config["template_references"]
            )

        # Process time fields if configured (convert minutes to time strings) - AFTER template resolution

        if config.get("time_fields"):
            if "_am_pm_format" in base_data:
                base_data = self._process_entity_time_fields(
                    base_data, config["time_fields"], base_data["_am_pm_format"]
                )
            else:
                base_data = self._process_entity_time_fields(
                    base_data, config["time_fields"]
                )
        # Resolve logical constants if configured
        if config.get("constant_classes"):
            base_data = self._resolve_constant_values(
                base_data, config["constant_classes"]
            )

        # Add metadata
        base_data["test_id"] = test_id or "GENERIC"
        base_data["environment"] = self.env_manager.get_current_environment()
        base_data["entity_type"] = entity_name

        return base_data


    def _get_entity_test_override(self, entity_name, entity_info, test_id):
        """Load test-specific overrides for an entity."""
        test_override_path = entity_info["overrides_dir"] / f"{test_id}.json"

        if test_override_path.exists():
            with open(test_override_path, "r") as file:
                return json.load(file)


        return {}

    def _process_entity_date_placeholders(
        self, data, date_fields, date_format="%Y-%m-%d"
    ):
        """Replace date placeholders with actual dates for specified fields."""
        print(f"Processing generic date placeholders for fields: {date_fields}")
        # When planning week is enabled, anchor offsets to PLANNING_WEEK_BASE_DATE so entity
        # date placeholders stay consistent with the TestDataLibrary keywords (which already
        # honor it). Without this, offsets resolve from the current date and diverge from the
        # planning-week dates used elsewhere in the schedule flow.
        base_date = None
        try:
            from robot.libraries.BuiltIn import BuiltIn

            if BuiltIn().get_variable_value("${PLANNING_WEEK_ENABLED}", False):
                base_date = self.env_manager.get_config_value(
                    "PLANNING_WEEK_BASE_DATE", None
                )
        except Exception:
            base_date = None
        for field in date_fields:
            if field in data and isinstance(data[field], str):
                try:
                    data[field] = (
                        date_helper.calculate_week_start_date_from_weekday_offset(
                            data[field],
                            self.fiscal_week_start_day,
                            date_format,
                            base_date,
                        )
                    )
                except Exception as e:
                    # If parsing fails, leave the field as-is
                    print(
                        f"Warning: Could not process date field {field} with value {data[field]}: {e}"
                    )

        return data

    def _process_entity_time_fields(self, data, time_fields, am_pm_format="AM/PM"):
        """
        Convert time values from minutes to time strings for specified fields.

        This method processes time fields that contain integer minute values and converts
        them to formatted time strings (either 12-hour or 24-hour format) based on the
        TIME_FORMAT_12_HRS configuration setting.

        The method recursively processes nested data structures (dicts and lists) to find
        and convert all time fields specified in the configuration.

        Args:
            data: The data dictionary to process (can contain nested dicts and lists)
            time_fields: List of field names that contain time values in minutes
                        Example: ["startTime", "endTime", "duration"]

        Returns:
            The data with time fields converted to formatted time strings

        Example:
            Input: {"startTime": 480, "duration": 540, "other_field": "value"}
            Config: time_fields=["startTime", "duration"], TIME_FORMAT_12_HRS=True
            Output: {"startTime": "08:00 AM", "duration": "09:00 AM", "other_field": "value"}
        """
        logger.debug(f"Processing time fields: {time_fields}")

        # Get time format preference from environment config
        time_format_12hrs = self.env_manager.get_config_value(
            "TIME_FORMAT_12_HRS", False
        )
        if isinstance(time_format_12hrs, str):
            time_format_12hrs = time_format_12hrs.lower() in ("true", "1", "yes")

        logger.debug(f"Using 12-hour format: {time_format_12hrs}")

        # Recursively process the data structure
        return self._process_time_in_structure(
            data, time_fields, time_format_12hrs, am_pm_format
        )

    def _process_time_in_structure(
        self, obj, time_fields, time_format_12hrs, am_pm_format, depth=0
    ):
        """
        Recursively process time fields in nested data structures.

        Args:
            obj: Object to process (dict, list, or primitive)
            time_fields: List of field names to convert
            time_format_12hrs: Boolean indicating if 12-hour format should be used
            am_pm_format: String indicating the AM/PM format to use
            depth: Current recursion depth (for safety)

        Returns:
            Processed object with time fields converted to time strings
        """
        # Safety check to prevent infinite recursion
        if depth > 2:
            logger.warning(
                f"Time field processing depth exceeded 2 levels, stopping recursion"
            )
            return obj

        if isinstance(obj, dict):
            processed_dict = {}

            for key, value in obj.items():
                # Check if this key is a time field that needs conversion
                if key in time_fields and isinstance(value, int):
                    try:
                        # Convert minutes to time string
                        processed_dict[key] = time_helper.convert_minutes_to_timeformat(
                            value,
                            time_format_12hrs=time_format_12hrs,
                            am_pm_format=am_pm_format,
                        )
                        logger.debug(
                            f"Converted time field {key}: {value} minutes -> {processed_dict[key]}"
                        )
                    except Exception as e:
                        logger.error(f"Error converting time field {key}={value}: {e}")
                        processed_dict[key] = value
                else:
                    # Not a time field, recursively process the value
                    processed_dict[key] = self._process_time_in_structure(
                        value, time_fields, time_format_12hrs, am_pm_format, depth + 1
                    )

            return processed_dict

        elif isinstance(obj, list):
            # Process each item in the list
            return [
                self._process_time_in_structure(
                    item, time_fields, time_format_12hrs, am_pm_format, depth + 1
                )
                for item in obj
            ]

        else:
            # Primitive type, return as-is
            return obj

    def _resolve_template_references(self, data, template_references):
        """
        Resolve template references in data by looking up templates from other entities.

        This method scans the data structure for fields that contain template references
        (e.g., "shift_pattern": "standard_9hr") and replaces them with actual template data
        from the referenced entity. Only 1 level of resolution is performed to avoid circular dependencies.

        Args:
            data: The data dictionary to process
            template_references: Dict mapping field names to entity names
                Example: {"shift_pattern": "shift_pattern", "task_template": "task"}

        Returns:
            The data with template references resolved

        Example:
            Input: {"shifts_to_add": [{"dayNo": "0", "shift_pattern": "standard_9hr"}]}
            Config: {"shift_pattern": "shift_pattern"}
            Output: {"shifts_to_add": [{"dayNo": "0", "startTime": 480, "duration": 540}]}
        """
        logger.debug(
            f"Resolving template references with config: {template_references}"
        )

        # Recursively process the data structure
        return self._resolve_in_structure(data, template_references)

    def _resolve_in_structure(self, obj, template_references, depth=0):
        """
        Recursively resolve template references in nested data structures.

        Args:
            obj: Object to process (dict, list, or primitive)
            template_references: Mapping of field names to entity names
            depth: Current recursion depth (for safety)

        Returns:
            Processed object with template references resolved
        """
        # Safety check to prevent infinite recursion
        if depth > 2:
            logger.warning(
                f"Template reference resolution depth exceeded 2 levels, stopping recursion"
            )
            return obj

        if isinstance(obj, dict):
            resolved_dict = {}

            for key, value in obj.items():
                # Check if this key is a template reference field
                if key in template_references and isinstance(value, str):
                    # This is a template reference - resolve it
                    entity_name = template_references[key]
                    template_name = value

                    try:
                        # Get the referenced template data
                        if entity_name not in self.discovered_entities:
                            logger.warning(
                                f"Referenced entity '{entity_name}' not found for field '{key}'"
                            )
                            resolved_dict[key] = value
                            continue

                        entity_info = self.discovered_entities[entity_name]
                        templates = entity_info["templates"]

                        if template_name not in templates:
                            logger.warning(
                                f"Template '{template_name}' not found in entity '{entity_name}' for field '{key}'"
                            )
                            resolved_dict[key] = value
                            continue

                        # Get the template data (shallow copy to avoid modifying original)
                        template_data = templates[template_name].copy()

                        # Merge the template data into the current dict (excluding the reference field itself)
                        # This replaces the reference with the actual data
                        logger.debug(
                            f"Resolved template reference: {key}={template_name} -> {template_data}"
                        )

                        # Instead of adding the key, we merge the template data directly
                        resolved_dict.update(template_data)

                    except Exception as e:
                        logger.error(
                            f"Error resolving template reference {key}={value}: {e}"
                        )
                        resolved_dict[key] = value
                else:
                    # Not a template reference, recursively process the value
                    resolved_dict[key] = self._resolve_in_structure(
                        value, template_references, depth + 1
                    )

            return resolved_dict

        elif isinstance(obj, list):
            # Process each item in the list
            return [
                self._resolve_in_structure(item, template_references, depth + 1)
                for item in obj
            ]

        else:
            # Primitive type, return as-is
            return obj

    # Additional convenience methods for Robot Framework
    @keyword
    def get_available_entities(self):
        """Returns a list of all discovered entities."""
        return list(self.discovered_entities.keys())


    @keyword
    def get_entity_templates(self, entity_name):
        """Returns available templates for a specific entity."""
        if entity_name in self.discovered_entities:
            return list(self.discovered_entities[entity_name]["templates"].keys())
        return []


    @keyword
    def validate_entity_exists(self, entity_name):
        """Validates that an entity exists and is properly configured."""
        if entity_name not in self.discovered_entities:
            raise ValueError(
                f"Entity '{entity_name}' not found. Available entities: {list(self.discovered_entities.keys())}"
            )
        return True


# For backward compatibility and direct usage, create specific instances
class ShiftDataProvider(GenericDataProvider):
    """Example of how the generic provider can be specialized if needed."""


    def __init__(self):
        super().__init__()
        if "shift" not in self.discovered_entities:
            raise ValueError(
                "Shift entity not found. Please ensure test_data/entities/shift/base_templates.json exists."
            )


# Make the generic provider available as a convenient alias
DataProvider = GenericDataProvider
